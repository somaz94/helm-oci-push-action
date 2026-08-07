FROM alpine:3.24

ARG HELM_VERSION=latest

# Injected by buildx per target platform, and load-bearing now that this image
# is published multi-arch: the helm tarball below used to be pinned to
# linux-amd64, which a `--platform linux/arm64` build downloads and installs
# without complaint. The build succeeds and the resulting arm64 image carries
# an x86 helm that cannot execute. Helm names its releases with the same
# amd64/arm64 tokens Docker uses, so TARGETARCH substitutes directly.
#
# The default keeps a plain `docker build` working, where TARGETARCH is unset.
ARG TARGETARCH=amd64

RUN apk add --no-cache \
        bash \
        curl \
        git \
        ca-certificates \
        coreutils \
    && if [ "$HELM_VERSION" = "latest" ]; then \
         HELM_VERSION=$(curl -fsSL https://get.helm.sh/helm-latest-version); \
       fi \
    && echo "Installing helm $HELM_VERSION" \
    && curl -fsSL "https://get.helm.sh/helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz" \
       | tar -xz -C /tmp \
    && mv /tmp/linux-${TARGETARCH}/helm /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm \
    && rm -rf /tmp/linux-${TARGETARCH} \
    && helm version --short

WORKDIR /usr/src
COPY entrypoint.sh /usr/src/entrypoint.sh
RUN chmod +x /usr/src/entrypoint.sh

ENTRYPOINT ["/usr/src/entrypoint.sh"]
