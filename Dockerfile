FROM ghcr.io/toltec-dev/qt:v2.1

RUN cd /root \
    && curl --proto '=https' --tlsv1.2 -sSf \
        https://dl.google.com/go/go1.16.3.linux-amd64.tar.gz \
        -o go1.16.3.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.16.3.linux-amd64.tar.gz \
    && mkdir go \
    && rm go1.16.3.linux-amd64.tar.gz

ENV PATH="$PATH:/usr/local/go/bin"
ENV GOPATH="/root/go"

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt-get update -y \
    && apt-get install -y --no-install-recommends \
        git wget binutils tar coreutils

RUN mkdir /project

WORKDIR /project

CMD make
