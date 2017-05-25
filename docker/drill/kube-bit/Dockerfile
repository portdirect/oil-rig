FROM %%DOCKER_NAMESPACE%%/%%DOCKER_PREFIX%%base:%%DOCKER_TAG%%

RUN set -x \
    && apt-get update \
    && apt-get install  --no-install-recommends -y \
        curl \
        ca-certificates \
# Get Kubernetes Binaries
    && TMP_DIR=$(mktemp -d) \
    && mkdir -p ${TMP_DIR} \
    && curl -sSL https://dl.k8s.io/${KUBE_VERSION}/kubernetes-server-linux-amd64.tar.gz | tar -zxv --strip-components=1 -C ${TMP_DIR} \
    && for KUBE_COMP in kube-apiserver kubelet kube-controller-manager kube-scheduler kube-proxy; do \
          chmod +x ${TMP_DIR}/server/bin/$KUBE_COMP; \
          mv ${TMP_DIR}/server/bin/$KUBE_COMP /usr/bin/; \
       done \
# Get CNI Binaries
    && mkdir -p /opt/cni/bin \
    && curl -L https://github.com/containernetworking/cni/releases/download/$CNI_VERSION/cni-amd64-$CNI_VERSION.tgz | tar -zxv -C /opt/cni/bin/ \
    && curl -sSL https://storage.googleapis.com/kubernetes-helm/helm-${HELM_VERSION}-linux-amd64.tar.gz | tar -zxv --strip-components=1 -C /usr/bin/ \
    && rm -rf ${TMP_DIR} \
# Get etcd(v3) Binaries
    && TMP_DIR=$(mktemp -d) \
    && mkdir -p ${TMP_DIR} \
    && curl -ssL https://storage.googleapis.com/etcd/${ETCD3_VERSION}/etcd-${ETCD3_VERSION}-linux-amd64.tar.gz  | tar -zxv --strip-components=1 -C ${TMP_DIR} \
    && for COMP in etcd etcdctl; do \
          cp ${TMP_DIR}/${COMP} /usr/bin/${COMP}; \
       done \
    && rm -rf ${TMP_DIR} \
# Get etcd(v2) Binaries
    && TMP_DIR=$(mktemp -d) \
    && mkdir -p ${TMP_DIR} \
    && curl -ssL https://storage.googleapis.com/etcd/${ETCD2_VERSION}/etcd-${ETCD2_VERSION}-linux-amd64.tar.gz  | tar -zxv --strip-components=1 -C ${TMP_DIR} \
    && for COMP in etcd etcdctl; do \
          cp ${TMP_DIR}/${COMP} /usr/bin/${COMP}-2; \
       done \
    && rm -rf ${TMP_DIR}
