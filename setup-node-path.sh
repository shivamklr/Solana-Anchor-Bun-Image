#!/bin/bash

# Set error handling
set -euo pipefail

# Define the Node.js versions directory
NODE_VERSIONS_DIR="/root/.nvm/versions/node"

# Function to check if directory exists
check_directory() {
    if [ ! -d "$NODE_VERSIONS_DIR" ]; then
        echo "Error: Directory $NODE_VERSIONS_DIR does not exist"
        exit 1
    fi
}

# Function to find first directory
find_first_node_dir() {
    local first_dir
    first_dir=$(ls -1 "$NODE_VERSIONS_DIR" 2>/dev/null | head -n 1)
    
    if [ -z "$first_dir" ]; then
        echo "Error: No Node.js versions found in $NODE_VERSIONS_DIR"
        exit 1
    fi
    
    echo "$NODE_VERSIONS_DIR/$first_dir"
}

# Function to check and add PATH to .bashrc
add_to_bashrc() {
    local node_bin_path="$1/bin"
    local bashrc="/root/.bashrc"
    
    # Create .bashrc if it doesn't exist
    touch "$bashrc"
    
    # Check if PATH already exists in .bashrc
    if ! grep -q "PATH=$node_bin_path:\$PATH" "$bashrc"; then
        echo "# Added by node-path-script" >> "$bashrc"
        echo "export PATH=$node_bin_path:\$PATH" >> "$bashrc"
        echo "Successfully added Node.js bin directory to PATH in .bashrc"
    else
        echo "PATH entry already exists in .bashrc"
    fi
}

main() {
    # Check if the versions directory exists
    check_directory
    
    # Find the first Node.js directory
    local node_dir
    node_dir=$(find_first_node_dir)
    echo "Found Node.js directory: $node_dir"
    
    # Add to .bashrc
    add_to_bashrc "$node_dir"
}

# Execute main function
main