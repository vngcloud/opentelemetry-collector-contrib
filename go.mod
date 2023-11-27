module github.com/open-telemetry/opentelemetry-collector-contrib

go 1.20

require (
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/alibabacloudlogserviceexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/awscloudwatchlogsexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/awsemfexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/awskinesisexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/awsxrayexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/azuredataexplorerexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/azuremonitorexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/carbonexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/cassandraexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/clickhouseexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/coralogixexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/datadogexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/datasetexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/dynatraceexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/elasticsearchexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/f5cloudexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/fileexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/googlecloudexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/googlecloudpubsubexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/googlemanagedprometheusexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/influxdbexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/instanaexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/jaegerexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/jaegerthrifthttpexporter v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/exporter/kafkaexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/loadbalancingexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/logicmonitorexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/logzioexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/lokiexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/mezmoexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/opencensusexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/parquetexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/prometheusexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/prometheusremotewriteexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/pulsarexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/sapmexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/sentryexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/signalfxexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/skywalkingexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/splunkhecexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/sumologicexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/tanzuobservabilityexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/tencentcloudlogserviceexporter v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/exporter/zipkinexporter v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/extension/asapauthextension v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/extension/awsproxy v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/extension/basicauthextension v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/extension/bearertokenauthextension v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/extension/headerssetterextension v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/extension/healthcheckextension v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/extension/httpforwarder v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/extension/jaegerremotesampling v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/extension/oauth2clientauthextension v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/extension/observer/dockerobserver v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/extension/observer/ecstaskobserver v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/extension/observer/hostobserver v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/extension/observer/k8sobserver v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/extension/oidcauthextension v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/extension/pprofextension v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/extension/sigv4authextension v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/extension/storage v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/processor/attributesprocessor v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/processor/basicstatsprocessor v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/processor/cumulativetodeltaprocessor v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/processor/datadogprocessor v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/processor/deltatorateprocessor v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/processor/filterprocessor v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/processor/groupbyattrsprocessor v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/processor/groupbytraceprocessor v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/processor/k8sattributesprocessor v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/processor/metricsgenerationprocessor v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/processor/metricstransformprocessor v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/processor/probabilisticsamplerprocessor v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/processor/resourcedetectionprocessor v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/processor/resourceprocessor v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/processor/routingprocessor v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/processor/servicegraphprocessor v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/processor/spanmetricsprocessor v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/processor/spanprocessor v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/processor/tailsamplingprocessor v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/processor/transformprocessor v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/nginxreceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/nsxtreceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/opencensusreceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/oracledbreceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/otlpjsonfilereceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/podmanreceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/postgresqlreceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/prometheusreceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/pulsarreceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/purefareceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/purefbreceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/rabbitmqreceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/receivercreator v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/redisreceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/riakreceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/saphanareceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/sapmreceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/signalfxreceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/simpleprometheusreceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/skywalkingreceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/snmpreceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/snowflakereceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/solacereceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/splunkhecreceiver v0.85.0
	github.com/open-telemetry/opentelemetry-collector-contrib/receiver/sqlqueryreceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/sqlserverreceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/sshcheckreceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/statsdreceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/syslogreceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/tcplogreceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/udplogreceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/vcenterreceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/wavefrontreceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/webhookeventreceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/windowseventlogreceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/windowsperfcountersreceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/zipkinreceiver v0.85.0
	// github.com/open-telemetry/opentelemetry-collector-contrib/receiver/zookeeperreceiver v0.85.0
	go.opentelemetry.io/collector v0.85.0
	go.opentelemetry.io/collector/exporter v0.85.0
	go.opentelemetry.io/collector/exporter/loggingexporter v0.85.0
	go.opentelemetry.io/collector/exporter/otlpexporter v0.85.0
	go.opentelemetry.io/collector/exporter/otlphttpexporter v0.85.0
	go.opentelemetry.io/collector/extension v0.85.0
	go.opentelemetry.io/collector/extension/ballastextension v0.85.0
	go.opentelemetry.io/collector/extension/zpagesextension v0.85.0
	go.opentelemetry.io/collector/processor v0.85.0
	go.opentelemetry.io/collector/processor/batchprocessor v0.85.0
	go.opentelemetry.io/collector/processor/memorylimiterprocessor v0.85.0
	go.opentelemetry.io/collector/receiver v0.85.0
	go.opentelemetry.io/collector/receiver/otlpreceiver v0.85.0
)

require (
	bitbucket.org/atlassian/go-asap/v2 v2.6.0 // indirect
	cloud.google.com/go/compute v1.23.0 // indirect
	cloud.google.com/go/compute/metadata v0.2.4-0.20230617002413-005d2dfb6b68 // indirect
	contrib.go.opencensus.io/exporter/prometheus v0.4.2 // indirect
	github.com/DataDog/datadog-agent/pkg/obfuscate v0.48.0-beta.1 // indirect
	github.com/DataDog/datadog-agent/pkg/proto v0.48.0-beta.1 // indirect
	github.com/DataDog/datadog-agent/pkg/remoteconfig/state v0.48.0-beta.1 // indirect
	github.com/DataDog/datadog-agent/pkg/trace v0.48.0-beta.1 // indirect
	github.com/DataDog/datadog-agent/pkg/util/cgroups v0.48.0-beta.1 // indirect
	github.com/DataDog/datadog-agent/pkg/util/log v0.48.0-beta.1 // indirect
	github.com/DataDog/datadog-agent/pkg/util/pointer v0.48.0-beta.1 // indirect
	github.com/DataDog/datadog-agent/pkg/util/scrubber v0.48.0-beta.1 // indirect
	github.com/DataDog/datadog-go/v5 v5.1.1 // indirect
	github.com/DataDog/go-sqllexer v0.0.8 // indirect
	github.com/DataDog/go-tuf v1.0.1-0.5.2 // indirect
	github.com/DataDog/opentelemetry-mapping-go/pkg/otlp/attributes v0.8.0 // indirect
	github.com/DataDog/opentelemetry-mapping-go/pkg/otlp/metrics v0.8.0 // indirect
	github.com/DataDog/opentelemetry-mapping-go/pkg/quantile v0.8.0 // indirect
	github.com/DataDog/sketches-go v1.4.2 // indirect
	github.com/GehirnInc/crypt v0.0.0-20200316065508-bb7000b8a962 // indirect
	github.com/GoogleCloudPlatform/opentelemetry-operations-go/detectors/gcp v1.19.1 // indirect
	github.com/IBM/sarama v1.41.1 // indirect
	github.com/Masterminds/semver/v3 v3.2.0 // indirect
	github.com/Microsoft/go-winio v0.6.1 // indirect
	github.com/SermoDigital/jose v0.9.2-0.20161205224733-f6df55f235c2 // indirect
	github.com/Showmax/go-fqdn v1.0.0 // indirect
	github.com/alecthomas/participle/v2 v2.0.0 // indirect
	github.com/antonmedv/expr v1.15.0 // indirect
	github.com/apache/thrift v0.19.0 // indirect
	github.com/armon/go-metrics v0.4.1 // indirect
	github.com/aws/aws-sdk-go v1.45.2 // indirect
	github.com/aws/aws-sdk-go-v2 v1.21.0 // indirect
	github.com/aws/aws-sdk-go-v2/config v1.18.38 // indirect
	github.com/aws/aws-sdk-go-v2/credentials v1.13.36 // indirect
	github.com/aws/aws-sdk-go-v2/feature/ec2/imds v1.13.11 // indirect
	github.com/aws/aws-sdk-go-v2/internal/configsources v1.1.41 // indirect
	github.com/aws/aws-sdk-go-v2/internal/endpoints/v2 v2.4.35 // indirect
	github.com/aws/aws-sdk-go-v2/internal/ini v1.3.42 // indirect
	github.com/aws/aws-sdk-go-v2/service/internal/presigned-url v1.9.35 // indirect
	github.com/aws/aws-sdk-go-v2/service/sso v1.13.6 // indirect
	github.com/aws/aws-sdk-go-v2/service/ssooidc v1.15.5 // indirect
	github.com/aws/aws-sdk-go-v2/service/sts v1.21.5 // indirect
	github.com/aws/smithy-go v1.14.2 // indirect
	github.com/beorn7/perks v1.0.1 // indirect
	github.com/cenkalti/backoff/v4 v4.2.1 // indirect
	github.com/cespare/xxhash/v2 v2.2.0 // indirect
	github.com/cihub/seelog v0.0.0-20170130134532-f561c5e57575 // indirect
	github.com/containerd/cgroups v1.1.0 // indirect
	github.com/coreos/go-oidc v2.2.1+incompatible // indirect
	github.com/coreos/go-systemd/v22 v22.5.0 // indirect
	github.com/davecgh/go-spew v1.1.2-0.20180830191138-d8f796af33cc // indirect
	github.com/docker/distribution v2.8.2+incompatible // indirect
	github.com/docker/docker v24.0.5+incompatible // indirect
	github.com/docker/go-connections v0.4.1-0.20210727194412-58542c764a11 // indirect
	github.com/docker/go-units v0.5.0 // indirect
	github.com/dustin/go-humanize v1.0.1 // indirect
	github.com/eapache/go-resiliency v1.4.0 // indirect
	github.com/eapache/go-xerial-snappy v0.0.0-20230731223053-c322873962e3 // indirect
	github.com/eapache/queue v1.1.0 // indirect
	github.com/emicklei/go-restful/v3 v3.10.2 // indirect
	github.com/fatih/color v1.15.0 // indirect
	github.com/felixge/httpsnoop v1.0.3 // indirect
	github.com/fsnotify/fsnotify v1.6.0 // indirect
	github.com/go-kit/log v0.2.1 // indirect
	github.com/go-logfmt/logfmt v0.6.0 // indirect
	github.com/go-logr/logr v1.2.4 // indirect
	github.com/go-logr/stdr v1.2.2 // indirect
	github.com/go-ole/go-ole v1.2.6 // indirect
	github.com/go-openapi/jsonpointer v0.20.0 // indirect
	github.com/go-openapi/jsonreference v0.20.2 // indirect
	github.com/go-openapi/swag v0.22.4 // indirect
	github.com/gobwas/glob v0.2.3 // indirect
	github.com/godbus/dbus/v5 v5.1.0 // indirect
	github.com/gofrs/uuid v4.3.1+incompatible // indirect
	github.com/gogo/googleapis v1.4.1 // indirect
	github.com/gogo/protobuf v1.3.2 // indirect
	github.com/golang/groupcache v0.0.0-20210331224755-41bb18bfe9da // indirect
	github.com/golang/mock v1.6.0 // indirect
	github.com/golang/protobuf v1.5.3 // indirect
	github.com/golang/snappy v0.0.4 // indirect
	github.com/google/btree v1.1.2 // indirect
	github.com/google/gnostic-models v0.6.8 // indirect
	github.com/google/go-cmp v0.5.9 // indirect
	github.com/google/gofuzz v1.2.0 // indirect
	github.com/google/pprof v0.0.0-20230705174524-200ffdc848b8 // indirect
	github.com/google/uuid v1.3.1 // indirect
	github.com/grpc-ecosystem/grpc-gateway/v2 v2.17.1 // indirect
	github.com/hashicorp/consul/api v1.24.0 // indirect
	github.com/hashicorp/errwrap v1.1.0 // indirect
	github.com/hashicorp/go-cleanhttp v0.5.2 // indirect
	github.com/hashicorp/go-hclog v1.5.0 // indirect
	github.com/hashicorp/go-immutable-radix v1.3.1 // indirect
	github.com/hashicorp/go-multierror v1.1.1 // indirect
	github.com/hashicorp/go-rootcerts v1.0.2 // indirect
	github.com/hashicorp/go-uuid v1.0.3 // indirect
	github.com/hashicorp/golang-lru v1.0.2 // indirect
	github.com/hashicorp/hcl v1.0.0 // indirect
	github.com/hashicorp/serf v0.10.1 // indirect
	github.com/iancoleman/strcase v0.3.0 // indirect
	github.com/imdario/mergo v0.3.16 // indirect
	github.com/inconshreveable/mousetrap v1.1.0 // indirect
	github.com/influxdata/go-syslog/v3 v3.0.1-0.20210608084020-ac565dc76ba6 // indirect
	github.com/jackc/chunkreader/v2 v2.0.1 // indirect
	github.com/jackc/pgconn v1.14.0 // indirect
	github.com/jackc/pgio v1.0.0 // indirect
	github.com/jackc/pgpassfile v1.0.0 // indirect
	github.com/jackc/pgproto3/v2 v2.3.2 // indirect
	github.com/jackc/pgservicefile v0.0.0-20221227161230-091c0ba34f0a // indirect
	github.com/jackc/pgtype v1.14.0 // indirect
	github.com/jackc/pgx/v4 v4.18.1 // indirect
	github.com/jaegertracing/jaeger v1.48.0 // indirect
	github.com/jcmturner/aescts/v2 v2.0.0 // indirect
	github.com/jcmturner/dnsutils/v2 v2.0.0 // indirect
	github.com/jcmturner/gofork v1.7.6 // indirect
	github.com/jcmturner/gokrb5/v8 v8.4.4 // indirect
	github.com/jcmturner/rpc/v2 v2.0.3 // indirect
	github.com/jmespath/go-jmespath v0.4.0 // indirect
	github.com/josharian/intern v1.0.0 // indirect
	github.com/json-iterator/go v1.1.12 // indirect
	github.com/karrick/godirwalk v1.17.0 // indirect
	github.com/klauspost/compress v1.16.7 // indirect
	github.com/knadh/koanf v1.5.0 // indirect
	github.com/knadh/koanf/v2 v2.0.1 // indirect
	github.com/leodido/ragel-machinery v0.0.0-20181214104525-299bdde78165 // indirect
	github.com/lib/pq v1.10.9 // indirect
	github.com/lufia/plan9stats v0.0.0-20220913051719-115f729f3c8c // indirect
	github.com/magiconair/properties v1.8.7 // indirect
	github.com/mailru/easyjson v0.7.7 // indirect
	github.com/mattn/go-colorable v0.1.13 // indirect
	github.com/mattn/go-isatty v0.0.19 // indirect
	github.com/mattn/go-sqlite3 v1.14.17 // indirect
	github.com/matttproud/golang_protobuf_extensions v1.0.4 // indirect
	github.com/miekg/dns v1.1.55 // indirect
	github.com/mitchellh/copystructure v1.2.0 // indirect
	github.com/mitchellh/go-homedir v1.1.0 // indirect
	github.com/mitchellh/mapstructure v1.5.1-0.20220423185008-bf980b35cac4 // indirect
	github.com/mitchellh/reflectwalk v1.0.2 // indirect
	github.com/modern-go/concurrent v0.0.0-20180306012644-bacd9c7ef1dd // indirect
	github.com/modern-go/reflect2 v1.0.2 // indirect
	github.com/mostynb/go-grpc-compression v1.2.0 // indirect
	github.com/munnerz/goautoneg v0.0.0-20191010083416-a7dc8b61c822 // indirect
	github.com/onsi/ginkgo/v2 v2.11.0 // indirect
	github.com/onsi/gomega v1.27.10 // indirect
	github.com/open-telemetry/opentelemetry-collector-contrib/extension/observer v0.85.0 // indirect
	github.com/open-telemetry/opentelemetry-collector-contrib/internal/aws/ecsutil v0.85.0 // indirect
	github.com/open-telemetry/opentelemetry-collector-contrib/internal/aws/proxy v0.85.0 // indirect
	github.com/open-telemetry/opentelemetry-collector-contrib/internal/common v0.85.0 // indirect
	github.com/open-telemetry/opentelemetry-collector-contrib/internal/coreinternal v0.85.0 // indirect
	github.com/open-telemetry/opentelemetry-collector-contrib/internal/datadog v0.85.0 // indirect
	github.com/open-telemetry/opentelemetry-collector-contrib/internal/docker v0.85.0 // indirect
	github.com/open-telemetry/opentelemetry-collector-contrib/internal/filter v0.85.0 // indirect
	github.com/open-telemetry/opentelemetry-collector-contrib/internal/k8sconfig v0.85.0 // indirect
	github.com/open-telemetry/opentelemetry-collector-contrib/internal/metadataproviders v0.85.0 // indirect
	github.com/open-telemetry/opentelemetry-collector-contrib/pkg/batchpersignal v0.85.0 // indirect
	github.com/open-telemetry/opentelemetry-collector-contrib/pkg/ottl v0.85.0 // indirect
	github.com/open-telemetry/opentelemetry-collector-contrib/pkg/pdatautil v0.85.0 // indirect
	github.com/open-telemetry/opentelemetry-collector-contrib/pkg/stanza v0.85.0 // indirect
	github.com/open-telemetry/opentelemetry-collector-contrib/pkg/translator/jaeger v0.85.0 // indirect
	github.com/opencontainers/go-digest v1.0.0 // indirect
	github.com/opencontainers/image-spec v1.1.0-rc4 // indirect
	github.com/opencontainers/runtime-spec v1.1.0-rc.3 // indirect
	github.com/openshift/api v3.9.0+incompatible // indirect
	github.com/openshift/client-go v0.0.0-20210521082421-73d9475a9142 // indirect
	github.com/opentracing/opentracing-go v1.2.0 // indirect
	github.com/outcaste-io/ristretto v0.2.1 // indirect
	github.com/patrickmn/go-cache v2.1.0+incompatible // indirect
	github.com/pelletier/go-toml/v2 v2.0.8 // indirect
	github.com/philhofer/fwd v1.1.2 // indirect
	github.com/pierrec/lz4/v4 v4.1.18 // indirect
	github.com/pkg/errors v0.9.1 // indirect
	github.com/pmezard/go-difflib v1.0.1-0.20181226105442-5d4384ee4fb2 // indirect
	github.com/power-devops/perfstat v0.0.0-20220216144756-c35f1ee13d7c // indirect
	github.com/pquerna/cachecontrol v0.1.0 // indirect
	github.com/prometheus/client_golang v1.16.0 // indirect
	github.com/prometheus/client_model v0.4.0 // indirect
	github.com/prometheus/common v0.44.0 // indirect
	github.com/prometheus/procfs v0.11.0 // indirect
	github.com/prometheus/statsd_exporter v0.22.7 // indirect
	github.com/rcrowley/go-metrics v0.0.0-20201227073835-cf1acfcdf475 // indirect
	github.com/rogpeppe/go-internal v1.11.0 // indirect
	github.com/rs/cors v1.10.0 // indirect
	github.com/secure-systems-lab/go-securesystemslib v0.7.0 // indirect
	github.com/shirou/gopsutil/v3 v3.23.8 // indirect
	github.com/shoenig/go-m1cpu v0.1.6 // indirect
	github.com/shoenig/test v0.6.6 // indirect
	github.com/shopspring/decimal v1.3.1 // indirect
	github.com/sirupsen/logrus v1.9.0 // indirect
	github.com/spf13/afero v1.9.5 // indirect
	github.com/spf13/cast v1.5.1 // indirect
	github.com/spf13/cobra v1.7.0 // indirect
	github.com/spf13/jwalterweatherman v1.1.0 // indirect
	github.com/spf13/pflag v1.0.5 // indirect
	github.com/spf13/viper v1.16.0 // indirect
	github.com/stretchr/objx v0.5.0 // indirect
	github.com/stretchr/testify v1.8.4 // indirect
	github.com/subosito/gotenv v1.4.2 // indirect
	github.com/tg123/go-htpasswd v1.2.1 // indirect
	github.com/tilinna/clock v1.1.0 // indirect
	github.com/tinylib/msgp v1.1.8 // indirect
	github.com/tklauser/go-sysconf v0.3.12 // indirect
	github.com/tklauser/numcpus v0.6.1 // indirect
	github.com/uber/jaeger-client-go v2.30.0+incompatible // indirect
	github.com/uber/jaeger-lib v2.4.1+incompatible // indirect
	github.com/vincent-petithory/dataurl v1.0.0 // indirect
	github.com/xdg-go/pbkdf2 v1.0.0 // indirect
	github.com/xdg-go/scram v1.1.2 // indirect
	github.com/xdg-go/stringprep v1.0.4 // indirect
	github.com/yusufpapurcu/wmi v1.2.3 // indirect
	go.etcd.io/bbolt v1.3.7 // indirect
	go.opencensus.io v0.24.0 // indirect
	go.opentelemetry.io/collector/component v0.85.0 // indirect
	go.opentelemetry.io/collector/config/configauth v0.85.0 // indirect
	go.opentelemetry.io/collector/config/configcompression v0.85.0 // indirect
	go.opentelemetry.io/collector/config/configgrpc v0.85.0 // indirect
	go.opentelemetry.io/collector/config/confighttp v0.85.0 // indirect
	go.opentelemetry.io/collector/config/confignet v0.85.0 // indirect
	go.opentelemetry.io/collector/config/configopaque v0.85.0 // indirect
	go.opentelemetry.io/collector/config/configtelemetry v0.85.0 // indirect
	go.opentelemetry.io/collector/config/configtls v0.85.0 // indirect
	go.opentelemetry.io/collector/config/internal v0.85.0 // indirect
	go.opentelemetry.io/collector/confmap v0.85.0 // indirect
	go.opentelemetry.io/collector/connector v0.85.0 // indirect
	go.opentelemetry.io/collector/consumer v0.85.0 // indirect
	go.opentelemetry.io/collector/extension/auth v0.85.0 // indirect
	go.opentelemetry.io/collector/featuregate v1.0.0-rcv0014 // indirect
	go.opentelemetry.io/collector/pdata v1.0.0-rcv0014 // indirect
	go.opentelemetry.io/collector/semconv v0.85.0 // indirect
	go.opentelemetry.io/contrib/instrumentation/google.golang.org/grpc/otelgrpc v0.43.0 // indirect
	go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp v0.43.0 // indirect
	go.opentelemetry.io/contrib/propagators/b3 v1.17.0 // indirect
	go.opentelemetry.io/contrib/zpages v0.43.0 // indirect
	go.opentelemetry.io/otel v1.17.0 // indirect
	go.opentelemetry.io/otel/bridge/opencensus v0.40.0 // indirect
	go.opentelemetry.io/otel/exporters/otlp/otlpmetric v0.40.0 // indirect
	go.opentelemetry.io/otel/exporters/otlp/otlpmetric/otlpmetricgrpc v0.40.0 // indirect
	go.opentelemetry.io/otel/exporters/otlp/otlpmetric/otlpmetrichttp v0.40.0 // indirect
	go.opentelemetry.io/otel/exporters/otlp/otlptrace v1.17.0 // indirect
	go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracegrpc v1.17.0 // indirect
	go.opentelemetry.io/otel/exporters/otlp/otlptrace/otlptracehttp v1.17.0 // indirect
	go.opentelemetry.io/otel/exporters/prometheus v0.40.1-0.20230831181707-02616a25c68e // indirect
	go.opentelemetry.io/otel/exporters/stdout/stdoutmetric v0.40.0 // indirect
	go.opentelemetry.io/otel/exporters/stdout/stdouttrace v1.17.0 // indirect
	go.opentelemetry.io/otel/metric v1.17.0 // indirect
	go.opentelemetry.io/otel/sdk v1.17.0 // indirect
	go.opentelemetry.io/otel/sdk/metric v0.40.0 // indirect
	go.opentelemetry.io/otel/trace v1.17.0 // indirect
	go.opentelemetry.io/proto/otlp v1.0.0 // indirect
	go.uber.org/atomic v1.11.0 // indirect
	go.uber.org/multierr v1.11.0 // indirect
	go.uber.org/zap v1.25.0 // indirect
	golang.org/x/crypto v0.13.0 // indirect
	golang.org/x/exp v0.0.0-20230713183714-613f0c0eb8a1 // indirect
	golang.org/x/mod v0.12.0 // indirect
	golang.org/x/net v0.15.0 // indirect
	golang.org/x/oauth2 v0.11.0 // indirect
	golang.org/x/sys v0.12.0 // indirect
	golang.org/x/term v0.12.0 // indirect
	golang.org/x/text v0.13.0 // indirect
	golang.org/x/time v0.3.0 // indirect
	golang.org/x/tools v0.12.0 // indirect
	gonum.org/v1/gonum v0.14.0 // indirect
	google.golang.org/appengine v1.6.7 // indirect
	google.golang.org/genproto/googleapis/api v0.0.0-20230822172742-b8732ec3820d // indirect
	google.golang.org/genproto/googleapis/rpc v0.0.0-20230822172742-b8732ec3820d // indirect
	google.golang.org/grpc v1.58.0 // indirect
	google.golang.org/protobuf v1.31.0 // indirect
	gopkg.in/inf.v0 v0.9.1 // indirect
	gopkg.in/ini.v1 v1.67.0 // indirect
	gopkg.in/square/go-jose.v2 v2.5.1 // indirect
	gopkg.in/yaml.v2 v2.4.0 // indirect
	gopkg.in/yaml.v3 v3.0.1 // indirect
	gotest.tools/v3 v3.5.0 // indirect
	k8s.io/api v0.28.1 // indirect
	k8s.io/apimachinery v0.28.1 // indirect
	k8s.io/client-go v0.28.1 // indirect
	k8s.io/klog/v2 v2.100.1 // indirect
	k8s.io/kube-openapi v0.0.0-20230717233707-2695361300d9 // indirect
	k8s.io/utils v0.0.0-20230711102312-30195339c3c7 // indirect
	sigs.k8s.io/json v0.0.0-20221116044647-bc3834ca7abd // indirect
	sigs.k8s.io/structured-merge-diff/v4 v4.3.0 // indirect
	sigs.k8s.io/yaml v1.3.0 // indirect
)

// Replace references to modules that are in this repository with their relateive paths
// so that we always build with current (latest) version of the source code.

replace github.com/open-telemetry/opentelemetry-collector-contrib/internal/aws/awsutil => ./internal/aws/awsutil

replace github.com/open-telemetry/opentelemetry-collector-contrib/internal/aws/containerinsight => ./internal/aws/containerinsight

replace github.com/open-telemetry/opentelemetry-collector-contrib/internal/aws/cwlogs => ./internal/aws/cwlogs

replace github.com/open-telemetry/opentelemetry-collector-contrib/internal/aws/ecsutil => ./internal/aws/ecsutil

replace github.com/open-telemetry/opentelemetry-collector-contrib/internal/aws/k8s => ./internal/aws/k8s

replace github.com/open-telemetry/opentelemetry-collector-contrib/internal/aws/metrics => ./internal/aws/metrics

replace github.com/open-telemetry/opentelemetry-collector-contrib/internal/aws/proxy => ./internal/aws/proxy

replace github.com/open-telemetry/opentelemetry-collector-contrib/internal/aws/xray => ./internal/aws/xray

replace github.com/open-telemetry/opentelemetry-collector-contrib/internal/common => ./internal/common

replace github.com/open-telemetry/opentelemetry-collector-contrib/internal/coreinternal => ./internal/coreinternal

replace github.com/open-telemetry/opentelemetry-collector-contrib/internal/docker => ./internal/docker

replace github.com/open-telemetry/opentelemetry-collector-contrib/internal/filter => ./internal/filter

replace github.com/open-telemetry/opentelemetry-collector-contrib/internal/k8sconfig => ./internal/k8sconfig

replace github.com/open-telemetry/opentelemetry-collector-contrib/internal/k8stest => ./internal/k8stest

replace github.com/open-telemetry/opentelemetry-collector-contrib/internal/kubelet => ./internal/kubelet

replace github.com/open-telemetry/opentelemetry-collector-contrib/internal/metadataproviders => ./internal/metadataproviders

replace github.com/open-telemetry/opentelemetry-collector-contrib/internal/sharedcomponent => ./internal/sharedcomponent

replace github.com/open-telemetry/opentelemetry-collector-contrib/internal/splunk => ./internal/splunk

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/alibabacloudlogserviceexporter => ./exporter/alibabacloudlogserviceexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/awscloudwatchlogsexporter => ./exporter/awscloudwatchlogsexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/awsemfexporter => ./exporter/awsemfexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/awskinesisexporter => ./exporter/awskinesisexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/awsxrayexporter => ./exporter/awsxrayexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/azuredataexplorerexporter => ./exporter/azuredataexplorerexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/azuremonitorexporter => ./exporter/azuremonitorexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/carbonexporter => ./exporter/carbonexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/clickhouseexporter => ./exporter/clickhouseexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/cassandraexporter => ./exporter/cassandraexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/coralogixexporter => ./exporter/coralogixexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/datadogexporter => ./exporter/datadogexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/datasetexporter => ./exporter/datasetexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/dynatraceexporter => ./exporter/dynatraceexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/f5cloudexporter => ./exporter/f5cloudexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/fileexporter => ./exporter/fileexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/googlecloudexporter => ./exporter/googlecloudexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/googlemanagedprometheusexporter => ./exporter/googlemanagedprometheusexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/googlecloudpubsubexporter => ./exporter/googlecloudpubsubexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/influxdbexporter => ./exporter/influxdbexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/instanaexporter => ./exporter/instanaexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/jaegerexporter => ./exporter/jaegerexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/jaegerthrifthttpexporter => ./exporter/jaegerthrifthttpexporter

replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/kafkaexporter => ./exporter/kafkaexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/loadbalancingexporter => ./exporter/loadbalancingexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/logicmonitorexporter => ./exporter/logicmonitorexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/logzioexporter => ./exporter/logzioexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/lokiexporter => ./exporter/lokiexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/mezmoexporter => ./exporter/mezmoexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/opencensusexporter => ./exporter/opencensusexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/parquetexporter => ./exporter/parquetexporter

replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/prometheusexporter => ./exporter/prometheusexporter

replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/prometheusremotewriteexporter => ./exporter/prometheusremotewriteexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/pulsarexporter => ./exporter/pulsarexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/sapmexporter => ./exporter/sapmexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/sentryexporter => ./exporter/sentryexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/signalfxexporter => ./exporter/signalfxexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/skywalkingexporter => ./exporter/skywalkingexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/splunkhecexporter => ./exporter/splunkhecexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/sumologicexporter => ./exporter/sumologicexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/tanzuobservabilityexporter => ./exporter/tanzuobservabilityexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/tencentcloudlogserviceexporter => ./exporter/tencentcloudlogserviceexporter

replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/elasticsearchexporter => ./exporter/elasticsearchexporter

replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/vmonitorexporter => ./exporter/vmonitorexporter

// replace github.com/open-telemetry/opentelemetry-collector-contrib/exporter/zipkinexporter => ./exporter/zipkinexporter

replace github.com/open-telemetry/opentelemetry-collector-contrib/extension/asapauthextension => ./extension/asapauthextension

replace github.com/open-telemetry/opentelemetry-collector-contrib/extension/awsproxy => ./extension/awsproxy

replace github.com/open-telemetry/opentelemetry-collector-contrib/extension/basicauthextension => ./extension/basicauthextension

replace github.com/open-telemetry/opentelemetry-collector-contrib/extension/bearertokenauthextension => ./extension/bearertokenauthextension

replace github.com/open-telemetry/opentelemetry-collector-contrib/extension/headerssetterextension => ./extension/headerssetterextension

replace github.com/open-telemetry/opentelemetry-collector-contrib/extension/healthcheckextension => ./extension/healthcheckextension

replace github.com/open-telemetry/opentelemetry-collector-contrib/extension/httpforwarder => ./extension/httpforwarder

replace github.com/open-telemetry/opentelemetry-collector-contrib/extension/oauth2clientauthextension => ./extension/oauth2clientauthextension

replace github.com/open-telemetry/opentelemetry-collector-contrib/extension/observer => ./extension/observer

replace github.com/open-telemetry/opentelemetry-collector-contrib/extension/observer/ecstaskobserver => ./extension/observer/ecstaskobserver

replace github.com/open-telemetry/opentelemetry-collector-contrib/extension/observer/hostobserver => ./extension/observer/hostobserver

replace github.com/open-telemetry/opentelemetry-collector-contrib/extension/observer/k8sobserver => ./extension/observer/k8sobserver

replace github.com/open-telemetry/opentelemetry-collector-contrib/extension/oidcauthextension => ./extension/oidcauthextension

replace github.com/open-telemetry/opentelemetry-collector-contrib/extension/pprofextension => ./extension/pprofextension

replace github.com/open-telemetry/opentelemetry-collector-contrib/extension/sigv4authextension => ./extension/sigv4authextension

replace github.com/open-telemetry/opentelemetry-collector-contrib/extension/storage => ./extension/storage

replace github.com/open-telemetry/opentelemetry-collector-contrib/pkg/batchperresourceattr => ./pkg/batchperresourceattr

replace github.com/open-telemetry/opentelemetry-collector-contrib/pkg/batchpersignal => ./pkg/batchpersignal

replace github.com/open-telemetry/opentelemetry-collector-contrib/pkg/winperfcounters => ./pkg/winperfcounters

replace github.com/open-telemetry/opentelemetry-collector-contrib/pkg/experimentalmetricmetadata => ./pkg/experimentalmetricmetadata

replace github.com/open-telemetry/opentelemetry-collector-contrib/pkg/ottl => ./pkg/ottl

replace github.com/open-telemetry/opentelemetry-collector-contrib/pkg/pdatatest => ./pkg/pdatatest

replace github.com/open-telemetry/opentelemetry-collector-contrib/pkg/pdatautil => ./pkg/pdatautil

replace github.com/open-telemetry/opentelemetry-collector-contrib/pkg/resourcetotelemetry => ./pkg/resourcetotelemetry

replace github.com/open-telemetry/opentelemetry-collector-contrib/pkg/stanza => ./pkg/stanza

replace github.com/open-telemetry/opentelemetry-collector-contrib/pkg/translator/jaeger => ./pkg/translator/jaeger

replace github.com/open-telemetry/opentelemetry-collector-contrib/pkg/translator/loki => ./pkg/translator/loki

replace github.com/open-telemetry/opentelemetry-collector-contrib/pkg/translator/opencensus => ./pkg/translator/opencensus

replace github.com/open-telemetry/opentelemetry-collector-contrib/pkg/translator/prometheus => ./pkg/translator/prometheus

replace github.com/open-telemetry/opentelemetry-collector-contrib/pkg/translator/prometheusremotewrite => ./pkg/translator/prometheusremotewrite

replace github.com/open-telemetry/opentelemetry-collector-contrib/pkg/translator/signalfx => ./pkg/translator/signalfx

replace github.com/open-telemetry/opentelemetry-collector-contrib/pkg/translator/zipkin => ./pkg/translator/zipkin

replace github.com/open-telemetry/opentelemetry-collector-contrib/processor/attributesprocessor => ./processor/attributesprocessor

replace github.com/open-telemetry/opentelemetry-collector-contrib/processor/cumulativetodeltaprocessor => ./processor/cumulativetodeltaprocessor/

replace github.com/open-telemetry/opentelemetry-collector-contrib/processor/datadogprocessor => ./processor/datadogprocessor

replace github.com/open-telemetry/opentelemetry-collector-contrib/processor/deltatorateprocessor => ./processor/deltatorateprocessor/

replace github.com/open-telemetry/opentelemetry-collector-contrib/processor/filterprocessor => ./processor/filterprocessor

replace github.com/open-telemetry/opentelemetry-collector-contrib/processor/groupbyattrsprocessor => ./processor/groupbyattrsprocessor

replace github.com/open-telemetry/opentelemetry-collector-contrib/processor/groupbytraceprocessor => ./processor/groupbytraceprocessor

replace github.com/open-telemetry/opentelemetry-collector-contrib/processor/k8sattributesprocessor => ./processor/k8sattributesprocessor/

replace github.com/open-telemetry/opentelemetry-collector-contrib/processor/metricsgenerationprocessor => ./processor/metricsgenerationprocessor/

replace github.com/open-telemetry/opentelemetry-collector-contrib/processor/metricstransformprocessor => ./processor/metricstransformprocessor/

replace github.com/open-telemetry/opentelemetry-collector-contrib/processor/basicstatsprocessor => ./processor/basicstatsprocessor/

replace github.com/open-telemetry/opentelemetry-collector-contrib/processor/probabilisticsamplerprocessor => ./processor/probabilisticsamplerprocessor/

replace github.com/open-telemetry/opentelemetry-collector-contrib/processor/resourcedetectionprocessor => ./processor/resourcedetectionprocessor/

replace github.com/open-telemetry/opentelemetry-collector-contrib/processor/resourceprocessor => ./processor/resourceprocessor/

replace github.com/open-telemetry/opentelemetry-collector-contrib/processor/routingprocessor => ./processor/routingprocessor/

replace github.com/open-telemetry/opentelemetry-collector-contrib/processor/servicegraphprocessor => ./processor/servicegraphprocessor/

replace github.com/open-telemetry/opentelemetry-collector-contrib/processor/spanmetricsprocessor => ./processor/spanmetricsprocessor/

replace github.com/open-telemetry/opentelemetry-collector-contrib/processor/spanprocessor => ./processor/spanprocessor/

replace github.com/open-telemetry/opentelemetry-collector-contrib/processor/tailsamplingprocessor => ./processor/tailsamplingprocessor

replace github.com/open-telemetry/opentelemetry-collector-contrib/processor/transformprocessor => ./processor/transformprocessor

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/activedirectorydsreceiver => ./receiver/activedirectorydsreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/aerospikereceiver => ./receiver/aerospikereceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/apachereceiver => ./receiver/apachereceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/apachesparkreceiver => ./receiver/apachesparkreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/awscloudwatchreceiver => ./receiver/awscloudwatchreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/awscontainerinsightreceiver => ./receiver/awscontainerinsightreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/awsecscontainermetricsreceiver => ./receiver/awsecscontainermetricsreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/awsfirehosereceiver => ./receiver/awsfirehosereceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/awsxrayreceiver => ./receiver/awsxrayreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/azureblobreceiver => ./receiver/azureblobreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/azureeventhubreceiver => ./receiver/azureeventhubreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/azuremonitorreceiver => ./receiver/azuremonitorreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/bigipreceiver => ./receiver/bigipreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/carbonreceiver => ./receiver/carbonreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/chronyreceiver => ./receiver/chronyreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/cloudfoundryreceiver => ./receiver/cloudfoundryreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/collectdreceiver => ./receiver/collectdreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/couchdbreceiver => ./receiver/couchdbreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/datadogreceiver => ./receiver/datadogreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/flinkmetricsreceiver => ./receiver/flinkmetricsreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/dockerstatsreceiver => ./receiver/dockerstatsreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/elasticsearchreceiver => ./receiver/elasticsearchreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/expvarreceiver => ./receiver/expvarreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/filelogreceiver => ./receiver/filelogreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/googlecloudspannerreceiver => ./receiver/googlecloudspannerreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/googlecloudpubsubreceiver => ./receiver/googlecloudpubsubreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/haproxyreceiver => ./receiver/haproxyreceiver

replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/hostmetricsreceiver => ./receiver/hostmetricsreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/httpcheckreceiver => ./receiver/httpcheckreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/influxdbreceiver => ./receiver/influxdbreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/iisreceiver => ./receiver/iisreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/jaegerreceiver => ./receiver/jaegerreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/jmxreceiver => ./receiver/jmxreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/journaldreceiver => ./receiver/journaldreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/k8sclusterreceiver => ./receiver/k8sclusterreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/k8seventsreceiver => ./receiver/k8seventsreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/k8sobjectsreceiver => ./receiver/k8sobjectsreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/fluentforwardreceiver => ./receiver/fluentforwardreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/kafkametricsreceiver => ./receiver/kafkametricsreceiver

replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/kafkareceiver => ./receiver/kafkareceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/kubeletstatsreceiver => ./receiver/kubeletstatsreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/lokireceiver => ./receiver/lokireceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/memcachedreceiver => ./receiver/memcachedreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/mongodbreceiver => ./receiver/mongodbreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/mongodbatlasreceiver => ./receiver/mongodbatlasreceiver

replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/mysqlreceiver => ./receiver/mysqlreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/nginxreceiver => ./receiver/nginxreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/nsxtreceiver => ./receiver/nsxtreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/opencensusreceiver => ./receiver/opencensusreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/oracledbreceiver => ./receiver/oracledbreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/otlpjsonfilereceiver => ./receiver/otlpjsonfilereceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/podmanreceiver => ./receiver/podmanreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/postgresqlreceiver => ./receiver/postgresqlreceiver

replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/prometheusreceiver => ./receiver/prometheusreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/pulsarreceiver => ./receiver/pulsarreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/purefareceiver => ./receiver/purefareceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/purefbreceiver => ./receiver/purefbreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/rabbitmqreceiver => ./receiver/rabbitmqreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/receivercreator => ./receiver/receivercreator

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/redisreceiver => ./receiver/redisreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/riakreceiver => ./receiver/riakreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/saphanareceiver => ./receiver/saphanareceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/sapmreceiver => ./receiver/sapmreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/signalfxreceiver => ./receiver/signalfxreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/simpleprometheusreceiver => ./receiver/simpleprometheusreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/skywalkingreceiver => ./receiver/skywalkingreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/snmpreceiver => ./receiver/snmpreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/solacereceiver => ./receiver/solacereceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/splunkhecreceiver => ./receiver/splunkhecreceiver

replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/sqlqueryreceiver => ./receiver/sqlqueryreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/sqlserverreceiver => ./receiver/sqlserverreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/sshcheckreceiver => ./receiver/sshcheckreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/statsdreceiver => ./receiver/statsdreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/syslogreceiver => ./receiver/syslogreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/tcplogreceiver => ./receiver/tcplogreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/udplogreceiver => ./receiver/udplogreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/vcenterreceiver => ./receiver/vcenterreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/wavefrontreceiver => ./receiver/wavefrontreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/windowseventlogreceiver => ./receiver/windowseventlogreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/webhookeventreceiver => ./receiver/webhookeventreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/windowsperfcountersreceiver => ./receiver/windowsperfcountersreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/zipkinreceiver => ./receiver/zipkinreceiver

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/zookeeperreceiver => ./receiver/zookeeperreceiver

replace github.com/open-telemetry/opentelemetry-collector-contrib/extension/observer/dockerobserver => ./extension/observer/dockerobserver

replace github.com/open-telemetry/opentelemetry-collector-contrib/internal/datadog => ./internal/datadog

replace github.com/open-telemetry/opentelemetry-collector-contrib/extension/jaegerremotesampling => ./extension/jaegerremotesampling

// see https://github.com/google/gnostic/issues/262
replace github.com/googleapis/gnostic v0.5.6 => github.com/googleapis/gnostic v0.5.5

// see https://github.com/open-telemetry/opentelemetry-collector-contrib/pull/12322#issuecomment-1185029670
replace github.com/docker/go-connections v0.4.1-0.20210727194412-58542c764a11 => github.com/docker/go-connections v0.4.0

retract (
	v0.76.2
	v0.76.1
	v0.65.0
	v0.37.0 // Contains dependencies on v0.36.0 components, which should have been updated to v0.37.0.
)

// see https://github.com/distribution/distribution/issues/3590
exclude github.com/docker/distribution v2.8.0+incompatible

// see https://github.com/DataDog/agent-payload/issues/218
exclude github.com/DataDog/agent-payload/v5 v5.0.59

// see https://github.com/mattn/go-ieproxy/issues/45
replace github.com/mattn/go-ieproxy => github.com/mattn/go-ieproxy v0.0.1

// openshift removed all tags from their repo, use the pseudoversion from the release-3.9 branch HEAD
replace github.com/openshift/api v3.9.0+incompatible => github.com/openshift/api v0.0.0-20180801171038-322a19404e37

// It appears that the v0.2.0 tag was modified.  Replacing with v0.2.1
replace github.com/outcaste-io/ristretto v0.2.0 => github.com/outcaste-io/ristretto v0.2.1

// v0.47.x and v0.48.x are incompatible, prefer to use v0.48.x
replace github.com/DataDog/datadog-agent/pkg/proto => github.com/DataDog/datadog-agent/pkg/proto v0.48.0-beta.1

replace github.com/DataDog/datadog-agent/pkg/trace => github.com/DataDog/datadog-agent/pkg/trace v0.48.0-beta.1

// replace github.com/open-telemetry/opentelemetry-collector-contrib/receiver/snowflakereceiver => ./receiver/snowflakereceiver
