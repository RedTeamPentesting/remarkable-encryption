FROM ghcr.io/toltec-dev/qt:v2.1

ARG GO_VERSION=1.19.5

RUN cd /root \
    && curl --proto '=https' --tlsv1.2 -sSf \
        https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz \
        -o go${GO_VERSION}.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz \
    && mkdir go \
    && rm go${GO_VERSION}.linux-amd64.tar.gz

ENV PATH="$PATH:/usr/local/go/bin"

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update -y \
    && apt-get install -y --no-install-recommends \
        git wget binutils tar coreutils

RUN mkdir /project

WORKDIR /project

ENV HOME=/project

CMD make
