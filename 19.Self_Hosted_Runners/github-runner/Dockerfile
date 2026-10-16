FROM ubuntu:24.04

ARG RUNNER_VERSION=2.337.0

RUN apt-get update && \
    apt-get install -y \
    curl \
    git \
    jq \
    unzip \
    sudo \
    ca-certificates \
    libicu74 \
    && \
    rm -rf /var/lib/apt/lists/*

RUN useradd -m -s /bin/bash runner && \
    echo "runner ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

WORKDIR /home/runner

RUN curl -L \
    -o actions-runner.tar.gz \
    https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-x64-${RUNNER_VERSION}.tar.gz && \
    tar xzf actions-runner.tar.gz && \
    rm actions-runner.tar.gz && \
    chown -R runner:runner /home/runner

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

USER runner

ENTRYPOINT ["/entrypoint.sh"]