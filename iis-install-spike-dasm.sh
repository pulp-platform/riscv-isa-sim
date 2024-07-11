#!/bin/bash

# Function to detect OS
detect_os() {
    if command -v lsb_release >/dev/null 2>&1; then
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    else
        echo "lsb_release command not found. Please install it first."
        exit 1
    fi
}

# Function to get the latest release version from GitHub
get_latest_version() {
    latest_version=$(curl -s https://api.github.com/repos/pulp-platform/riscv-isa-sim/releases/latest | grep -oP '"tag_name": "\Ksnitch-v\K[^"]+')
    if [ -z "$latest_version" ]; then
        echo "Failed to fetch the latest version"
        exit 1
    fi
    echo "$latest_version"
}

# Function to install the binary
install_binary() {
    local url=$1
    local tarball=$(basename $url)

    wget $url
    if [ $? -ne 0 ]; then
        echo "Failed to download $tarball"
        exit 1
    fi

    tar xzf $tarball
    if [ $? -ne 0 ]; then
        echo "Failed to extract $tarball"
        exit 1
    fi
    rm $tarball

    echo "$tarball installed successfully."
}

# Main script logic
if [ -z "$1" ]; then
    VERSION=$(get_latest_version)
    echo "Installing latest version: v$VERSION"
else
    VERSION=$1
fi

detect_os

case $OS in
    "AlmaLinux")
        if [[ $VER == 8* ]]; then
            URL="https://github.com/pulp-platform/riscv-isa-sim/releases/download/snitch-v$VERSION/snitch-spike-dasm-$VERSION-x86_64-linux-gnu-almalinux8.7.tar.gz"
        else
            echo "Unsupported AlmaLinux version: $VER"
            exit 1
        fi
        ;;
    "CentOS")
        if [[ $VER == 7* ]]; then
            URL="https://github.com/pulp-platform/riscv-isa-sim/releases/download/snitch-v$VERSION/snitch-spike-dasm-$VERSION-x86_64-linux-gnu-centos7.4.1708.tar.gz"
        else
            echo "Unsupported CentOS version: $VER"
            exit 1
        fi
        ;;
    *)
        echo "Unsupported operating system: $OS"
        exit 1
        ;;
esac

install_binary $URL
