# Build stage for all tools
FROM rust:1-slim-bookworm AS builder

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
FROM rust:1-slim-bookworm

COPY --from=builder /usr/local/cargo/bin /usr/local/bin
COPY --from=builder /root/.nvm/versions/node/ /root/.nvm/versions/node/
COPY --from=builder /root/.local/share/solana/install/active_release/bin /usr/local/bin
COPY --from=builder /root/.avm /root/.avm
COPY --from=builder /usr/bin /usr/bin

# Create and run the path setup script
RUN echo '#!/bin/bash \n\
    set -euo pipefail \n\
    \n\
    NODE_VERSIONS_DIR="/root/.nvm/versions/node" \n\
    \n\
    check_directory() { \n\
    if [ ! -d "$NODE_VERSIONS_DIR" ]; then \n\
    echo "Error: Directory $NODE_VERSIONS_DIR does not exist" \n\
    exit 1 \n\
    fi \n\
    } \n\
    \n\
    find_first_node_dir() { \n\
    local first_dir \n\
    first_dir=$(ls -1 "$NODE_VERSIONS_DIR" 2>/dev/null | head -n 1) \n\
    \n\
    if [ -z "$first_dir" ]; then \n\
    echo "Error: No Node.js versions found in $NODE_VERSIONS_DIR" \n\
    exit 1 \n\
    fi \n\
    \n\
    echo "$NODE_VERSIONS_DIR/$first_dir" \n\
    } \n\
    \n\
    add_to_bashrc() { \n\
    local node_bin_path="$1/bin" \n\
    local bashrc="/root/.bashrc" \n\
    \n\
    touch "$bashrc" \n\
    \n\
    if ! grep -q "PATH=$node_bin_path:\$PATH" "$bashrc"; then \n\
    echo "# Added by node-path-script" >> "$bashrc" \n\
    echo "export PATH=$node_bin_path:\$PATH" >> "$bashrc" \n\
    echo "Successfully added Node.js bin directory to PATH in .bashrc" \n\
    else \n\
    echo "PATH entry already exists in .bashrc" \n\
    fi \n\
    } \n\
    \n\
    main() { \n\
    check_directory \n\
    local node_dir \n\
    node_dir=$(find_first_node_dir) \n\
    echo "Found Node.js directory: $node_dir" \n\
    add_to_bashrc "$node_dir" \n\
    } \n\
    \n\
    main' > /usr/local/bin/setup-node-path.sh && \
    chmod +x /usr/local/bin/setup-node-path.sh && \
    /usr/local/bin/setup-node-path.sh

# Source .bashrc in interactive shells
RUN echo 'source /root/.bashrc' >> /root/.bash_profile

# Verify installations
RUN . /root/.bashrc && \
    solana --version && \
    anchor --version && \
    node --version && \
    npm --version && \
    yarn --version && \
    bun --version

CMD ["/bin/bash"]