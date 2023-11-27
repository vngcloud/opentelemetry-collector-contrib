# FROM gcr.io/distroless/base-debian11
FROM ubuntu:22.04

USER 0

COPY ./vmonitor-agent /vmonitor-agent
COPY ./etc/vmonitor-agent-docker.conf /etc/vmonitor-agent/vmonitor-agent.conf

COPY ./entrypoint.sh /entrypoint.sh

RUN apt update && apt install curl ca-certificates -y && update-ca-certificates

ENTRYPOINT ["/entrypoint.sh"]