# Solana-Anchor-Bun-Image

A Docker image that provides a complete development environment for Solana and
Anchor development, including Bun as an alternative JavaScript runtime.

## Included Tools

- Rust
- Solana CLI tools
- Anchor Framework
- Node.js (LTS)
- Bun
- Yarn
- Git

## Usage

Pull and run the image from GitHub Container Registry:

```bash
docker pull ghcr.io/shivamklr/solana-anchor-bun:latest
docker run -it ghcr.io/shivamklr/solana-anchor-bun:latest
```

## DevContainer Usage

This image can be used as a development container in Visual Studio Code or
GitHub Codespaces. For example, you can add/modify the following configuration to your
`.devcontainer/devcontainer.json`:

```json
{
    "name": "Solana Development Environment",
    "image": "ghcr.io/shivamklr/solana-anchor-bun:latest",
    "settings": {
        "terminal.integrated.defaultProfile.linux": "bash"
    },
    "extensions": [
        "rust-lang.rust-analyzer",
        "tamasfe.even-better-toml",
        "serayuzgur.crates"
    ]
}
```

This configuration will:

- Use the Solana-Anchor-Bun image
- Install recommended extensions for Rust/Solana development

## Features

- Built on Debian Bookworm Slim
- Multi-stage build for optimized image size
- Pre-installed development essentials

## Build Locally

To build the image locally:

```bash
docker build -t solana-anchor-bun .
```

## GitHub Actions

This repository includes automated builds and publishing to GitHub Container
Registry via GitHub Actions workflow.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
