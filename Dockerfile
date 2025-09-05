FROM rust:1.82 as builder

RUN cargo install typos-cli

FROM debian:bullseye-slim

# Install required tools
RUN apt-get update && \
    apt-get install -y git jq curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Install yq
RUN curl -sSLo /usr/bin/yq https://github.com/mikefarah/yq/releases/download/v4.44.1/yq_linux_amd64 \
    && chmod +x /usr/bin/yq

# Copy typos binary from builder
COPY --from=builder /usr/local/cargo/bin/typos /usr/local/bin/typos
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
