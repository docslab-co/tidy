FROM debian:bullseye-slim

# Install required tools quietly
RUN apt-get update -y > /dev/null 2>&1 && \
    apt-get install -y git jq curl ca-certificates > /dev/null 2>&1 && \
    rm -rf /var/lib/apt/lists/*

# Install yq
RUN curl -sSLo /usr/bin/yq https://github.com/mikefarah/yq/releases/download/v4.44.1/yq_linux_amd64 \
    && chmod +x /usr/bin/yq

# Install prebuilt typos binary
RUN curl -sSL -o /usr/local/bin/typos https://github.com/crate-ci/typos/releases/download/v1.13.1/typos-x86_64-unknown-linux-musl \
    && chmod +x /usr/local/bin/typos

# Set working directory so typos sees repo
WORKDIR /github/workspace

# Copy entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
