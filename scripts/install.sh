#!/usr/bin/env bash
# Universal installer for remote SSH manager
# Author: Italo Almeida

set -euo pipefail

# Check bash version before using arrays
if [[ "${BASH_VERSINFO[0]}" -lt 4 ]]; then
    echo "Error: This installer requires bash 4.0 or higher"
    echo "Your bash version: ${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}.${BASH_VERSINFO[2]}"
    echo ""
    echo "For macOS users:"
    echo "  brew install bash"
    echo "  /usr/local/bin/bash install.sh"
    exit 1
fi

# Only use colors if outputting to terminal
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color
else
    RED=''
    GREEN=''
    YELLOW=''
    NC=''
fi

# Installation directory
INSTALL_DIR="/usr/local/bin"
SCRIPT_NAME="remote"

echo -e "${GREEN}Remote SSH Manager - Universal Installer${NC}"
echo "========================================"
echo ""

# Detect OS
OS="unknown"
DISTRO=""
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="linux"
    if [ -f /etc/alpine-release ]; then
        OS="alpine"
        DISTRO="Alpine Linux"
    elif [ -f /etc/debian_version ]; then
        DISTRO="Debian/Ubuntu"
    elif [ -f /etc/redhat-release ]; then
        DISTRO="RHEL/Fedora"
    elif [ -f /etc/arch-release ]; then
        DISTRO="Arch Linux"
    elif [ -f /etc/SUSE-brand ] || [ -f /etc/SuSE-release ]; then
        DISTRO="openSUSE"
    fi
elif [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macos"
    # Check if Apple Silicon or Intel
    if [[ $(uname -m) == "arm64" ]]; then
        DISTRO="macOS (Apple Silicon)"
    else
        DISTRO="macOS (Intel)"
    fi
elif [[ "$OSTYPE" == "freebsd"* ]]; then
    OS="freebsd"
    DISTRO="FreeBSD"
elif [[ "$OSTYPE" == "openbsd"* ]]; then
    OS="openbsd"
    DISTRO="OpenBSD"
elif [[ "$OSTYPE" == "netbsd"* ]]; then
    OS="netbsd"
    DISTRO="NetBSD"
elif [[ "$OSTYPE" == "sunos"* ]]; then
    OS="solaris"
    DISTRO="Solaris/Illumos"
fi

if [ -n "$DISTRO" ]; then
    echo -e "Detected: ${YELLOW}$DISTRO${NC}"
else
    echo -e "Detected OS: ${YELLOW}$OS${NC}"
fi
echo ""

# Check bash version
BASH_VERSION=$(bash --version | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
BASH_MAJOR=$(echo "$BASH_VERSION" | cut -d. -f1)

if [ "$BASH_MAJOR" -lt 4 ]; then
    echo -e "${YELLOW}Warning: Your bash version is $BASH_VERSION${NC}"
    echo "This tool requires bash 4.0 or higher."
    
    if [ "$OS" = "macos" ]; then
        echo ""
        echo "macOS ships with bash 3.2. To install bash 4+:"
        echo -e "${GREEN}brew install bash${NC}"
        echo ""
        echo "After installing, run this script with:"
        echo -e "${GREEN}/usr/local/bin/bash install.sh${NC}"
        echo ""
        echo "Also install newer rsync and other tools:"
        echo -e "${GREEN}brew install rsync openssl@3${NC}"
        exit 1
    fi
fi

# Extra check for macOS rsync version
if [ "$OS" = "macos" ]; then
    # Temporarily add Homebrew to PATH for version checks
    export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
    
    RSYNC_VERSION=$(rsync --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
    RSYNC_MAJOR=$(echo "$RSYNC_VERSION" | cut -d. -f1)
    RSYNC_MINOR=$(echo "$RSYNC_VERSION" | cut -d. -f2)
    
    if [ "$RSYNC_MAJOR" -lt 3 ] || ([ "$RSYNC_MAJOR" -eq 3 ] && [ "$RSYNC_MINOR" -lt 2 ]); then
        echo -e "${YELLOW}Warning: Your rsync version is $RSYNC_VERSION${NC}"
        echo "This tool works best with rsync 3.2 or higher."
        echo "Install newer rsync with:"
        echo -e "${GREEN}brew install rsync${NC}"
        echo ""
    fi
fi

# Check required dependencies
echo "Checking dependencies..."
MISSING_DEPS=()

check_dep() {
    if ! command -v "$1" >/dev/null 2>&1; then
        MISSING_DEPS+=("$1")
        echo -e "  ${RED}✗${NC} $1 - not found"
        return 1
    else
        echo -e "  ${GREEN}✓${NC} $1"
        return 0
    fi
}

check_dep "ssh"
check_dep "rsync"
check_dep "openssl"
check_dep "mktemp"

# Optional dependencies
echo ""
echo "Checking optional dependencies..."
if ! check_dep "sshpass"; then
    echo -e "    ${YELLOW}Note: sshpass is needed for saved sessions${NC}"
fi
if ! check_dep "pv"; then
    echo -e "    ${YELLOW}Note: pv provides progress bars in proxy mode${NC}"
fi

# Exit if required dependencies are missing
if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    echo ""
    echo -e "${RED}Error: Missing required dependencies!${NC}"
    echo ""
    echo "Install them using:"
    
    case "$DISTRO" in
        "Debian/Ubuntu")
            echo "  sudo apt update && sudo apt install ${MISSING_DEPS[*]}"
            ;;
        "RHEL/Fedora")
            echo "  sudo dnf install ${MISSING_DEPS[*]}"
            if [[ " ${MISSING_DEPS[*]} " =~ " rsync " ]]; then
                echo ""
                echo "  Note: For RHEL 8, enable rsync 3.2:"
                echo "  sudo dnf module enable rsync:3.2"
            fi
            ;;
        "Arch Linux")
            echo "  sudo pacman -S ${MISSING_DEPS[*]}"
            ;;
        "openSUSE")
            echo "  sudo zypper in ${MISSING_DEPS[*]}"
            ;;
        "Alpine Linux")
            echo "  sudo apk add ${MISSING_DEPS[*]}"
            if [[ " ${MISSING_DEPS[*]} " =~ " mktemp " ]]; then
                echo "  sudo apk add coreutils"
            fi
            ;;
        "macOS"*)
            echo "  brew install ${MISSING_DEPS[*]}"
            ;;
        "FreeBSD")
            echo "  sudo pkg install ${MISSING_DEPS[*]}"
            ;;
        "OpenBSD")
            echo "  doas pkg_add ${MISSING_DEPS[*]}"
            ;;
        "NetBSD")
            echo "  sudo pkgin install ${MISSING_DEPS[*]}"
            ;;
        "Solaris/Illumos")
            echo "  sudo pkg install ${MISSING_DEPS[*]}"
            ;;
        *)
            # Fallback for unknown distros
            case "$OS" in
                linux)
                    echo "  # Try one of these:"
                    echo "  sudo apt-get install ${MISSING_DEPS[*]}  # Debian-based"
                    echo "  sudo dnf install ${MISSING_DEPS[*]}      # Red Hat-based"
                    echo "  sudo pacman -S ${MISSING_DEPS[*]}        # Arch-based"
                    ;;
                *)
                    echo "  Please install: ${MISSING_DEPS[*]}"
                    ;;
            esac
            ;;
    esac
    exit 1
fi

# Check if running from git repo or curl
if [ -f "bin/remote" ]; then
    # Running from git clone
    REMOTE_SCRIPT="bin/remote"
elif [ -f "../bin/remote" ]; then
    # Running from scripts directory
    REMOTE_SCRIPT="../bin/remote"
else
    # Running from curl, download the script
    echo ""
    echo "Downloading remote script..."
    TEMP_FILE=$(mktemp)
    REMOTE_URL="https://raw.githubusercontent.com/italoalmeida0/remote/main/bin/remote"
    HASH_URL="https://raw.githubusercontent.com/italoalmeida0/remote/main/bin/remote.sha256"
    
    # Download the script
    if ! curl -fsSL "$REMOTE_URL" -o "$TEMP_FILE"; then
        echo -e "${RED}Error: Failed to download remote script${NC}"
        exit 1
    fi
    
    # Try to verify hash if available
    if curl -fsSL "$HASH_URL" -o "$TEMP_FILE.sha256" 2>/dev/null; then
        echo "Verifying integrity..."
        if command -v sha256sum >/dev/null 2>&1; then
            if ! (cd "$(dirname "$TEMP_FILE")" && sha256sum -c "$(basename "$TEMP_FILE.sha256")" >/dev/null 2>&1); then
                echo -e "${RED}Error: Integrity check failed!${NC}"
                echo "The downloaded file doesn't match the expected hash."
                rm -f "$TEMP_FILE" "$TEMP_FILE.sha256"
                exit 1
            fi
            echo -e "${GREEN}✓ Integrity verified${NC}"
        else
            echo -e "${YELLOW}Warning: sha256sum not found, skipping integrity check${NC}"
        fi
        rm -f "$TEMP_FILE.sha256"
    else
        echo -e "${YELLOW}Note: No hash file available for verification${NC}"
    fi
    
    # Make executable
    chmod 755 "$TEMP_FILE"
    REMOTE_SCRIPT="$TEMP_FILE"
fi

# Check if we need sudo
NEED_SUDO=false
if [ ! -w "$INSTALL_DIR" ]; then
    NEED_SUDO=true
fi

# Install the script
echo ""
echo "Installing to $INSTALL_DIR/$SCRIPT_NAME..."

if [ "$NEED_SUDO" = true ]; then
    echo -e "${YELLOW}Note: sudo required for installation to $INSTALL_DIR${NC}"
    sudo cp "$REMOTE_SCRIPT" "$INSTALL_DIR/$SCRIPT_NAME"
    sudo chmod 755 "$INSTALL_DIR/$SCRIPT_NAME"
else
    cp "$REMOTE_SCRIPT" "$INSTALL_DIR/$SCRIPT_NAME"
    chmod 755 "$INSTALL_DIR/$SCRIPT_NAME"
fi

# Clean up temp file if used
if [ -n "${TEMP_FILE:-}" ] && [ -f "$TEMP_FILE" ]; then
    rm -f "$TEMP_FILE"
fi

# Verify installation
if command -v remote >/dev/null 2>&1; then
    echo ""
    echo -e "${GREEN}✓ Installation successful!${NC}"
    echo ""
    echo "You can now use the 'remote' command. Try:"
    echo "  remote list"
    echo "  remote open myserver user@host.com"
    echo "  remote"  # Shows usage
    echo ""
    
    # Special instructions for macOS
    if [ "$OS" = "macos" ]; then
        echo -e "${YELLOW}macOS Users: Important Notes${NC}"
        echo "- If you see 'command not found', ensure Homebrew is in PATH"
        echo "- For saved sessions, install sshpass:"
        echo "  brew install hudochenkov/sshpass/sshpass"
        echo "- Direct mode may not work due to missing 'hostname -I'"
        echo ""
    fi
    
    echo "For more information, visit:"
    echo "https://github.com/italoalmeida0/remote"
else
    echo ""
    echo -e "${RED}Installation may have succeeded, but 'remote' is not in PATH${NC}"
    echo "Add $INSTALL_DIR to your PATH or use the full path:"
    echo "  $INSTALL_DIR/$SCRIPT_NAME"
    
    if [ "$OS" = "macos" ]; then
        echo ""
        echo "macOS users: Also ensure Homebrew binaries are in PATH:"
        echo "  export PATH=\"/opt/homebrew/bin:\$PATH\"  # Apple Silicon"
        echo "  export PATH=\"/usr/local/bin:\$PATH\"     # Intel"
    fi
fi