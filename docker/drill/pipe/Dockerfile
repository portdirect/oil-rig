FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%base:%%DOCKER_TAG%%

RUN set -x \
    && apt-get update \
    && apt-get install  --no-install-recommends -y \
        docker.io \
        curl \
    && curl -ssL -o > /usr/bin/docker-compose https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-Linux-x86_64 \
    && chmod +x /usr/bin/docker-compose
