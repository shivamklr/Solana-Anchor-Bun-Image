# Build stage for all tools
FROM rust:1.79-slim-bookworm AS builder

ARG SOLANA_CLI=v1.18.26
ARG ANCHOR_CLI=v0.30.1

# Avoid timezone prompts and set environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    TZ=UTC \
    NVM_DIR=/root/.nvm \
    PATH="/root/.local/share/solana/install/active_release/bin:${PATH}"

# Install dependencies in a single layer
RUN apt-get update && apt-get install -y \
    git \
    curl \
    unzip \
    bzip2 \
    build-essential \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Install nvm and Node.js tools in a single layer
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash && \
    . $NVM_DIR/nvm.sh && \
    nvm install --lts && \
    nvm use --lts && \
    nvm alias default node && \
    npm install -g bun yarn

# Install Solana tools.
RUN sh -c "$(curl -sSfL https://release.anza.xyz/${SOLANA_CLI}/install)"

# Install anchor.
RUN cargo install --git https://github.com/coral-xyz/anchor --tag ${ANCHOR_CLI} anchor-cli --locked

# Final stage
FROM rust:1.79-slim-bookworm 

COPY --from=builder /usr/local/cargo/bin /usr/local/bin
COPY --from=builder /root/.nvm/versions/node/ /root/.nvm/versions/node/
COPY --from=builder /root/.local/share/solana/install/active_release/bin /usr/local/bin
COPY --from=builder /usr/bin /usr/bin

# Copy the script from your local directory into the container
COPY setup-node-path.sh /root/setup-node-path.sh

# Make it executable and run it
RUN chmod +x /root/setup-node-path.sh && \
    /root/setup-node-path.sh

# Verify installations
RUN . /root/.bashrc && \
    solana --version && \
    anchor --version && \
    node --version && \
    npm --version && \
    yarn --version && \
    bun --version

# Build a dummy program to bootstrap the BPF SDK (doing this speeds up builds).
RUN . /root/.bashrc && mkdir -p /test && cd test && anchor init dummy && cd dummy && anchor build

RUN rm -rf /test

CMD ["/bin/bash"]