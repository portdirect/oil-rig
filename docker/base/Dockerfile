FROM ubuntu:16.04

ENV KUBE_VERSION=v1.6.2 \
    CNI_VERSION=v0.5.2 \
    HELM_VERSION=v2.3.0 \
    DOCKER_COMPOSE_VERSION=1.13.0

RUN set -x \
    && apt-get update \
    && apt-get dist-upgrade -y
