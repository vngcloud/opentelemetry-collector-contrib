// Copyright The OpenTelemetry Authors
// SPDX-License-Identifier: Apache-2.0

package vmonitorexporter // import "github.com/open-telemetry/opentelemetry-collector-contrib/exporter/vmonitorexporter"

import (
	"bytes"
	"compress/gzip"
	"context"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net"
	"net/http"
	"net/url"
	"os"
	"strings"
	"time"

	"github.com/matishsiao/goInfo"
	"github.com/shirou/gopsutil/cpu"
	"github.com/sirupsen/logrus"
	"golang.org/x/oauth2"
	"golang.org/x/oauth2/clientcredentials"

	"github.com/open-telemetry/opentelemetry-collector-contrib/exporter/vmonitorexporter/proxy"
)

const (
	metricPath         = "/intake/v2/series"
	quotaPath          = "/intake/v2/check"
	defaultContentType = "application/json"
	agentVersion       = "1.26.0-2.0.0"
	retryTime          = 128 // = 2^7 => retry max 128*30s
)

var defaultConfig = &VNGCloudvMonitor{
	URL:             "http://localhost:8081",
	Timeout:         10 * time.Second,
	IamURL:          "https://hcm-3.console.vngcloud.vn/iam/accounts-api/v2/auth/token",
	checkQuotaRetry: 30 * time.Second,
}

var sampleConfig = `
  ## URL is the address to send metrics to
  url = "http://localhost:8081"
  insecure_skip_verify = false
  data_format = "vngcloud_vmonitor"
  timeout = "30s"

  # From IAM service
  client_id = ""
  client_secret = ""
`

type Plugin struct {
	Name    string `json:"name"`
	Status  int    `json:"status"`
	Message string `json:"message"`
}

type QuotaInfo struct {
	Checksum string    `json:"checksum"`
	Data     *infoHost `json:"data"`
}

type infoHost struct {
	Plugins     []Plugin        `json:"plugins"`
	PluginsList map[string]bool `json:"-"`

	HashID string `json:"hash_id"`

	Kernel       string `json:"kernel"`
	Core         string `json:"core"`
	Platform     string `json:"platform"`
	OS           string `json:"os"`
	Hostname     string `json:"host_name"`
	CPUs         int    `json:"cpus"`
	ModelNameCPU string `json:"model_name_cpu"`
	Mem          uint64 `json:"mem"`
	IP           string `json:"ip"`
	AgentVersion string `json:"agent_version"`
	UserAgent    string `toml:"user_agent"`
}

type VNGCloudvMonitor struct {
	URL             string        `toml:"url"`
	Timeout         time.Duration `toml:"timeout"`
	ContentEncoding string        `toml:"content_encoding"`
	Insecure        bool          `toml:"insecure_skip_verify"`
	httpProxy       proxy.HTTPProxy
	IamURL          string `toml:"iam_url"`
	ClientID        string `toml:"client_id"`
	ClientSecret    string `toml:"client_secret"`

	// serializer Serializer
	infoHost  *infoHost
	clientIam *http.Client

	checkQuotaRetry time.Duration
	dropCount       int
	dropTime        time.Time
	checkQuotaFirst bool
}

func (h *VNGCloudvMonitor) initHTTPClient() error {
	logrus.Infof("Init client-iam ...\n")
	Oauth2ClientConfig := &clientcredentials.Config{
		ClientID:     h.ClientID,
		ClientSecret: h.ClientSecret,
		TokenURL:     h.IamURL,
	}
	proxyFunc, err := h.httpProxy.Proxy()
	if err != nil {
		return err
	}
	ctx := context.WithValue(context.TODO(), oauth2.HTTPClient, &http.Client{
		Transport: &http.Transport{
			Proxy: proxyFunc,
		},
		Timeout: h.Timeout,
	})
	token, err := Oauth2ClientConfig.TokenSource(ctx).Token()
	if err != nil {
		return fmt.Errorf("failed to get token: %s", err.Error())
	}

	_, err = json.Marshal(token)
	if err != nil {
		return fmt.Errorf("failed to Marshal token: %s", err.Error())
	}
	h.clientIam = Oauth2ClientConfig.Client(ctx)
	logrus.Infof("Init client-iam successfully !\n")
	return nil
}

func (h *VNGCloudvMonitor) getIP(address, port string) (string, error) {
	logrus.Infof("Dial %s %s\n", address, port)
	conn, err := net.DialTimeout("tcp", net.JoinHostPort(address, port), 5*time.Second)
	if err != nil {
		return "", err
	}
	defer conn.Close()
	return strings.Split(conn.LocalAddr().String(), ":")[0], nil
}

func getModelNameCPU() (string, error) {
	a, err := cpu.Info()
	if err != nil {
		return "", err
	}
	return a[0].ModelName, nil
}

func (h *VNGCloudvMonitor) getHostInfo() (*infoHost, error) {
	getHostPort := func(urlStr string) (string, error) {
		u, err := url.Parse(urlStr)
		if err != nil {
			return "", fmt.Errorf("url invalid %s", urlStr)
		}

		host, port, err := net.SplitHostPort(u.Host)

		if err != nil {
			return "", err
		}

		ipLocal, err := h.getIP(host, port)
		if err != nil {
			return "", err
		}
		return ipLocal, nil
	}

	var ipLocal string
	var err error
	// get ip local

	ipLocal, err = getHostPort(h.URL)

	if err != nil {
		return nil, fmt.Errorf("err getting ip address %s", err.Error())
	}
	// get ip local

	gi, err := goInfo.GetInfo()
	if err != nil {
		return nil, fmt.Errorf("error getting os info: %s", err.Error())
	}

	modelNameCPU, err := getModelNameCPU()

	if err != nil {
		return nil, fmt.Errorf("error getting cpu model name: %s", err.Error())
	}

	defaultHostname := h.infoHost.Hostname
	if defaultHostname == "" {
		defaultHostname, _ = os.Hostname()
	}

	h.infoHost = &infoHost{
		Plugins:      []Plugin{},
		PluginsList:  make(map[string]bool),
		Hostname:     "",
		HashID:       "",
		Kernel:       gi.Kernel,
		Core:         gi.Core,
		Platform:     gi.Platform,
		OS:           gi.OS,
		CPUs:         gi.CPUs,
		ModelNameCPU: modelNameCPU,
		Mem:          0,
		IP:           ipLocal,
		AgentVersion: agentVersion,
		UserAgent:    fmt.Sprintf("%s/%s (%s)", "vMonitorAgent", agentVersion, gi.OS),
	}
	h.setHostname(defaultHostname)
	return h.infoHost, nil
}

func (h *VNGCloudvMonitor) CheckConfig() error {
	u, err := url.Parse(h.URL)
	ok := err == nil && u.Scheme != "" && u.Host != ""
	if !ok {
		return fmt.Errorf("URL Invalid %s", h.URL)
	}
	return nil
}

func (h *VNGCloudvMonitor) Connect() error {

	if err := h.CheckConfig(); err != nil {
		return err
	}

	// h.clientIam = clientIam
	err := h.initHTTPClient()
	if err != nil {
		log.Print(err)
		return err
	}

	_, err = h.getHostInfo()
	if err != nil {
		return err
	}

	return nil
}

func (h *VNGCloudvMonitor) Close() error {
	return nil
}

func (h *VNGCloudvMonitor) Description() string {
	return "Configuration for vMonitor output."
}

func (h *VNGCloudvMonitor) SampleConfig() string {
	// log.Print(sampleConfig)
	return sampleConfig
}

func (h *VNGCloudvMonitor) setHostname(hostname string) {
	hashCode := sha256.New()
	hashCode.Write([]byte(hostname))
	hashedID := hex.EncodeToString(hashCode.Sum(nil))

	h.infoHost.HashID = hashedID
	h.infoHost.Hostname = hostname
}

func (h *VNGCloudvMonitor) WriteBatch(metrics []Metric) error {
	if h.dropCount > 1 && time.Now().Before(h.dropTime) {
		logrus.Infof("Drop %d metrics. Send request again at %s\n", len(metrics), h.dropTime.Format("15:04:05"))
		return nil
	}

	if h.checkQuotaFirst {
		if isDrop, err := h.checkQuota(); err != nil {
			if isDrop {
				logrus.Infof("Drop metrics because of %s\n", err.Error())
				return nil
			}
			return err
		}
	}

	reqBody, err := json.Marshal(metrics)
	if err != nil {
		return err
	}

	return h.write(reqBody)
}

// func (h *VNGCloudvMonitor) Write(metrics Metric) error {
// 	fmt.Println("---------- write")
// 	if h.dropCount > 1 && time.Now().Before(h.dropTime) {
// 		klog.Infof("Drop %d metrics. Send request again at %s", metrics.MetricCount(), h.dropTime.Format("15:04:05"))
// 		return nil
// 	}

// 	if h.checkQuotaFirst {
// 		if isDrop, err := h.checkQuota(); err != nil {
// 			if isDrop {
// 				klog.Infof("Drop metrics because of %s", err.Error())
// 				return nil
// 			}
// 			return err
// 		}
// 	}

// 	reqBody, err := h.serializer.Serialize(metrics)
// 	//return nil
// 	//fmt.Println("reqBody", reqBody)
// 	if err != nil {
// 		return err
// 	}

// 	if err := h.write(reqBody); err != nil {
// 		return err
// 	}

// 	return nil
// }

func (h *VNGCloudvMonitor) write(reqBody []byte) error {
	var reqBodyBuffer io.Reader = bytes.NewBuffer(reqBody)
	if h.ContentEncoding == "gzip" {
		rc := CompressWithGzip(reqBodyBuffer)
		defer rc.Close()
		reqBodyBuffer = rc
	}

	req, err := http.NewRequest(http.MethodPost, fmt.Sprintf("%s%s", h.URL, metricPath), reqBodyBuffer)
	if err != nil {
		return err
	}

	req.Header.Set("Content-Type", defaultContentType)
	req.Header.Set("checksum", h.infoHost.HashID)
	req.Header.Set("User-Agent", h.infoHost.UserAgent)

	if h.ContentEncoding == "gzip" {
		req.Header.Set("Content-Encoding", "gzip")
	}

	resp, err := h.clientIam.Do(req)
	if err != nil {
		if er := h.initHTTPClient(); er != nil {
			logrus.Infof("Drop metrics because can't init IAM: %s\n", er.Error())
			return nil
		}
		return fmt.Errorf("IAM request fail: %s", err.Error())
	}
	defer resp.Body.Close()
	dataRsp, err := io.ReadAll(resp.Body)

	if err != nil {
		return err
	}

	logrus.Infof("Request-ID: %s with body length %d byte and response body %s\n", resp.Header.Get("Api-Request-ID"), len(reqBody), dataRsp)

	if isDrop, err := h.handleResponse(resp.StatusCode, dataRsp); err != nil {
		if isDrop {
			logrus.Infof("Drop metrics because of %s\n", err.Error())
			return nil
		}
		return err
	}
	return nil
}

func (h *VNGCloudvMonitor) handleResponse(respCode int, dataRsp []byte) (bool, error) {

	switch respCode {
	case 201:
		return false, nil
	case 401:
		return true, fmt.Errorf("IAM Unauthorized. Please check your service account")
	case 403:
		return true, fmt.Errorf("IAM Forbidden. Please check your permission")
	case 428:
		if isDrop, err := h.checkQuota(); err != nil {
			return isDrop, fmt.Errorf("can not check quota: %s", err.Error())
		}
	case 409:
		h.doubleCheckTime()
		return true, fmt.Errorf("CONFLICT. Please check your quota again")
	}
	return false, fmt.Errorf("status Code: %d, message: %s", respCode, dataRsp)
}

func (h *VNGCloudvMonitor) checkQuota() (bool, error) {
	logrus.Debugln("Start check quota ...")
	h.checkQuotaFirst = true

	quotaStruct := &QuotaInfo{
		Checksum: h.infoHost.HashID,
		Data:     h.infoHost,
	}
	quotaJSON, err := json.Marshal(quotaStruct)
	if err != nil {
		return false, fmt.Errorf("can not marshal quota struct: %s", err.Error())
	}

	req, err := http.NewRequest(http.MethodPost, fmt.Sprintf("%s%s", h.URL, quotaPath), bytes.NewBuffer(quotaJSON))
	if err != nil {
		return false, fmt.Errorf("error create new request: %s", err.Error())
	}
	req.Header.Set("checksum", h.infoHost.HashID)
	req.Header.Set("Content-Type", defaultContentType)
	req.Header.Set("User-Agent", h.infoHost.UserAgent)
	resp, err := h.clientIam.Do(req)

	if err != nil {
		return false, fmt.Errorf("send request checking quota failed: (%s)", err.Error())
	}
	defer resp.Body.Close()
	dataRsp, err := io.ReadAll(resp.Body)

	if err != nil {
		return false, fmt.Errorf("error occurred when reading response body: (%s)", err.Error())
	}

	isDrop := false
	// handle check quota
	switch resp.StatusCode {
	case 200:
		logrus.Infof("Request-ID: %s. Checking quota success. Continue send metric.\n", resp.Header.Get("Api-Request-ID"))
		h.dropCount = 1
		h.dropTime = time.Now()
		h.checkQuotaFirst = false
		return false, nil

	case 401, 403:
		isDrop = true
	case 409:
		isDrop = true
		h.doubleCheckTime()
	}
	return isDrop, fmt.Errorf("Request-ID: %s. Checking quota fail (%d - %s)", resp.Header.Get("Api-Request-ID"), resp.StatusCode, dataRsp)
}

func (h *VNGCloudvMonitor) doubleCheckTime() {
	if h.dropCount < retryTime {
		h.dropCount *= 2
	}
	h.dropTime = time.Now().Add(time.Duration(h.dropCount * int(h.checkQuotaRetry)))
}

func CompressWithGzip(data io.Reader) io.ReadCloser {
	pipeReader, pipeWriter := io.Pipe()
	gzipWriter := gzip.NewWriter(pipeWriter)

	// Start copying from the uncompressed reader to the output reader
	// in the background until the input reader is closed (or errors out).
	go func() {
		// This copy will block until "data" reached EOF or an error occurs
		_, err := io.Copy(gzipWriter, data)

		// Close the compression writer and make sure we do not overwrite
		// the copy error if any.
		gzipErr := gzipWriter.Close()
		if err == nil {
			err = gzipErr
		}

		// Subsequent reads from the output reader (connected to "pipeWriter"
		// via pipe) will return the copy (or closing) error if any to the
		// instance reading from the reader returned by the CompressWithGzip
		// function. If "err" is nil, the below function will correctly report
		// io.EOF.
		_ = pipeWriter.CloseWithError(err)
	}()

	// Return a reader which then can be read by the caller to collect the
	// compressed stream.
	return pipeReader
}
