FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%base:%%DOCKER_TAG%%

RUN set -x \
    && apt-get update \
    && apt-get install  --no-install-recommends -y \
        curl \
        ca-certificates \
    && TMP_DIR=$(mktemp -d) \
    && mkdir -p ${TMP_DIR} \
    && cd ${TMP_DIR} \
    && curl -sSL https://dl.k8s.io/${KUBE_VERSION}/kubernetes-server-linux-amd64.tar.gz | tar -zxv --strip-components=1 \
    && for KUBE_COMP in kube-apiserver kubelet kube-controller-manager kube-scheduler kube-proxy; do \
        chmod +x ${TMP_DIR}/server/bin/$KUBE_COMP; \
        mv ${TMP_DIR}/server/bin/$KUBE_COMP /usr/bin/; \
    done \
    && mkdir -p /opt/cni/bin \
    && curl -L https://github.com/containernetworking/cni/releases/download/$CNI_VERSION/cni-amd64-$CNI_VERSION.tgz | tar -zxv -C /opt/cni/bin/ \
    && curl -sSL https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar -zxv --strip-components=1 -C /usr/bin/ \
    && cd / \
    && rm -rf ${TMP_DIR}
