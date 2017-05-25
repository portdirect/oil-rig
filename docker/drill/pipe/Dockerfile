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
# Get Docker Compose
    && curl -ssL -o /usr/bin/docker-compose https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-Linux-x86_64 \
    && chmod +x /usr/bin/docker-compose

RUN set -x \
    && apt-get update \
    && apt-get install  --no-install-recommends -y \
        vim

ADD ./assets /

ENTRYPOINT [ "supervisord", "-c", "/etc/oilrig/supvervisord.conf" ]
