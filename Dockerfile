FROM alpine:3.23

ARG HELM_VERSION=latest

RUN apk add --no-cache \
        bash \
        curl \
        git \
        ca-certificates \
        coreutils \
    && if [ "$HELM_VERSION" = "latest" ]; then \
         HELM_VERSION=$(curl -fsSL https://api.github.com/repos/helm/helm/releases/latest \
                          | grep '"tag_name"' | head -n1 | cut -d'"' -f4); \
       fi \
    && echo "Installing helm $HELM_VERSION" \
    && curl -fsSL "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" \
       | tar -xz -C /tmp \
    && mv /tmp/linux-amd64/helm /usr/local/bin/helm \
    && chmod +x /usr/local/bin/helm \
    && rm -rf /tmp/linux-amd64 \
    && helm version --short

WORKDIR /usr/src
COPY entrypoint.sh /usr/src/entrypoint.sh
RUN chmod +x /usr/src/entrypoint.sh

ENTRYPOINT ["/usr/src/entrypoint.sh"]
