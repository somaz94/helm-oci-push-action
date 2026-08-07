# Helm is fetched in its own stage pinned to the BUILD platform, and only the
# binary is copied into the runtime image.
#
# The obvious shape — one stage that curls helm and runs `helm version` to
# check it — cannot survive a multi-arch build. On an amd64 runner the arm64
# variant is produced under QEMU, and the emulated helm binary exits 255, which
# fails the whole build. Downloading here instead means the fetch runs natively
# no matter which architecture is being produced, and nothing arch-specific is
# ever executed at build time.
FROM --platform=$BUILDPLATFORM alpine:3.24 AS helm

ARG HELM_VERSION=latest
# Injected by buildx per target platform. Load-bearing now that this image is
# published multi-arch: this was pinned to linux-amd64, which an arm64 build
# downloads and installs without complaint — the build succeeds and the arm64
# image carries an x86 helm that cannot execute. Helm names its releases with
# the same amd64/arm64 tokens Docker uses, so TARGETARCH substitutes directly.
# The default keeps a plain `docker build` working, where TARGETARCH is unset.
ARG TARGETARCH=amd64

RUN apk add --no-cache curl \
    && if [ "$HELM_VERSION" = "latest" ]; then \
         HELM_VERSION=$(curl -fsSL https://get.helm.sh/helm-latest-version); \
       fi \
    && echo "Installing helm $HELM_VERSION for linux/${TARGETARCH}" \
    && curl -fsSL "https://get.helm.sh/helm-${HELM_VERSION}-linux-${TARGETARCH}.tar.gz" \
       | tar -xz -C /tmp \
    && mv "/tmp/linux-${TARGETARCH}/helm" /out-helm \
    && chmod +x /out-helm

FROM alpine:3.24

RUN apk add --no-cache \
        bash \
        curl \
        git \
        ca-certificates \
        coreutils

COPY --from=helm /out-helm /usr/local/bin/helm

WORKDIR /usr/src
COPY entrypoint.sh /usr/src/entrypoint.sh
RUN chmod +x /usr/src/entrypoint.sh

ENTRYPOINT ["/usr/src/entrypoint.sh"]
