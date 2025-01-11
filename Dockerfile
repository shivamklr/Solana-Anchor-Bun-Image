# Build stage for all tools
FROM rust:1.75-slim-bookworm AS builder

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

# Install Solana
RUN sh -c "$(curl -sSfL https://release.anza.xyz/stable/install)"

# Install Anchor
RUN cargo install --git https://github.com/coral-xyz/anchor avm --force && \
    avm install latest && \
    avm use latest

# Final stage
# FROM rust:1-slim-bookworm

# COPY --from=builder /usr/local/cargo/bin /usr/local/bin
# COPY --from=builder /root/.nvm/versions/node/ /root/.nvm/versions/node/
# COPY --from=builder /root/.local/share/solana/install/active_release/bin /usr/local/bin
# COPY --from=builder /root/.avm /root/.avm

# RUN apt-get update && apt-get install -y \
#     git \
#     curl \
#     unzip \
#     bzip2 \
#     build-essential \
#     python3 && \
#     apt-get autoclean && \
#     apt-get clean && \
#     apt-get autoremove \
#     && rm -rf /var/lib/apt/lists/*

# # Copy the script from your local directory into the container
# COPY setup-node-path.sh /root/setup-node-path.sh

# # Make it executable and run it
# RUN chmod +x /root/setup-node-path.sh && \
#     /root/setup-node-path.sh

# Verify installations
RUN . /root/.bashrc && \
    solana --version && \
    anchor --version && \
    node --version && \
    npm --version && \
    yarn --version && \
    bun --version

CMD ["/bin/bash"]