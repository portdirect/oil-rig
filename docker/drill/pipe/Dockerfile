FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%base:%%DOCKER_TAG%%

RUN set -x \
    && apt-get update \
    && apt-get install  --no-install-recommends -y \
        iproute2 \
        docker.io \
        curl \
        ca-certificates \
        python-pip \
    && pip --no-cache-dir install --upgrade pip \
    && pip --no-cache-dir install setuptools \
# Get Supervisord
    && pip --no-cache-dir install supervisor \
    && pip --no-cache-dir install supervisor-stdout \
# Get Kubelet
    && curl -sL -o /usr/local/bin/kubelet http://storage.googleapis.com/kubernetes-release/release/v1.6.2/bin/linux/amd64/kubelet \
    && chmod +x /usr/local/bin/kubelet

RUN set -x \
    && apt-get update \
    && apt-get install  --no-install-recommends -y \
        vim

RUN set -x \
    && apt-get install  --no-install-recommends -y \
        socat

ADD ./assets /

ENTRYPOINT [ "supervisord", "-c", "/etc/oilrig/supvervisord.conf" ]
