# Build stage
FROM golang:1-alpine AS builder

WORKDIR /app

COPY . /app

RUN chmod +x /app/share/scripts/build-welang.sh \
    && mkdir -p /app/go/bin \
    && /app/share/scripts/build-welang.sh /app/go/bin/wego

# COPY ./share/we-lang/ /app

RUN apk add --no-cache git gcc musl-dev sqlite-dev

RUN go install github.com/mattn/go-colorable && \
    go install github.com/klauspost/lctime && \
    go install github.com/mattn/go-runewidth && \
    cd /app && go build .

# Application stage
FROM python:3.11-slim

WORKDIR /app

ENV LLVM_CONFIG=/usr/bin/llvm-config

COPY requirements.txt /app/requirements.txt

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    build-essential \
    autoconf \
    automake \
    g++ \
    gcc \
    git \
    file \
    libjpeg-dev \
    make \
    zlib1g-dev \
    python3-venv \
    python3-pip \
    libtool \
    pkg-config \
    libonig-dev \
    libopenblas-dev \
    liblapack-dev \
    libffi-dev \
    libxml2-dev \
    ca-certificates \
    lolcat \
    supervisor && \
    mkdir -p /app/cache /var/log/supervisor /etc/supervisor/conf.d && \
    chmod -R o+rw /var/log/supervisor /var/run && \
    python3 -m venv /opt/venv && \
    /opt/venv/bin/pip install --upgrade pip setuptools wheel && \
    /opt/venv/bin/pip install -r requirements.txt --no-cache-dir && \
    /opt/venv/bin/pip install git+https://github.com/chubin/pyphoon.git && \
    apt-get remove -y --purge build-essential autoconf automake g++ gcc make && \
    apt-get autoremove -y && rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/wttr.in /app/bin/wttr.in
COPY --from=builder /app/go/bin/wego /app/go/bin/wego
COPY ./bin /app/bin
COPY ./lib /app/lib
COPY ./share /app/share
COPY share/docker/supervisord.conf /etc/supervisor/supervisord.conf

RUN mkdir /app/data \
    && mkdir /app/logs

ENV WTTR_MYDIR="/app"
ENV WTTR_GEOLITE="/app/GeoLite2-City.mmdb"
ENV WTTR_WEGO="/app/go/bin/wego"
ENV WTTR_LISTEN_HOST="0.0.0.0"
ENV WTTR_LISTEN_PORT="8002"
ENV PATH="/opt/venv/bin:/app/go/bin:/usr/games:$PATH"

EXPOSE 8002

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/supervisord.conf"]
