# Remote - Advanced SSH Session Manager

A powerful command-line tool for managing SSH sessions with advanced features like resume support, compression, verification, and secure credential storage.

## Features

- 🔐 **Secure credential storage** with PBKDF2 (600,000 iterations) + AES-256-CBC
- 🔄 **Resume support** for interrupted transfers (enabled by default)
- 📦 **Compression** for faster transfers over slow connections
- ✅ **Hash verification** to ensure data integrity
- 🚀 **Background jobs** with progress tracking
- 🔗 **Direct server-to-server transfers** without local intermediary
- 🛡️ **Security hardened** with extensive input validation and escaping
- 🖥️ **Cross-platform** support (Linux, macOS, BSD)

## Installation

### Quick Install (Universal)

```bash
curl -fsSL https://raw.githubusercontent.com/italoalmeida0/remote/main/scripts/install.sh | bash
```

The installer:
- Installs to `/usr/local/bin` (requires sudo)
- Automatically verifies file integrity using SHA256 when available
- Detects your OS and shows specific dependency instructions

### Manual Install

```bash
git clone https://github.com/italoalmeida0/remote.git
cd remote
./scripts/install.sh         # or use sudo if installing globally
```

## Platform-Specific Installation

### 🐧 Linux Distributions

Most Linux distributions work out-of-the-box. Here's what you might need:

#### Debian/Ubuntu/Mint
```bash
sudo apt update
sudo apt install bash rsync openssl sshpass pv
```

#### Fedora/RHEL 9/AlmaLinux/Rocky Linux
```bash
sudo dnf install bash rsync openssl sshpass pv
```

**Note for RHEL 8/CentOS 8:** Enable rsync 3.2 module:
```bash
sudo dnf module enable rsync:3.2
sudo dnf install rsync
```

#### Arch Linux/Manjaro
```bash
sudo pacman -S bash rsync openssl sshpass pv
```

#### openSUSE
```bash
sudo zypper in bash rsync openssl sshpass pv
```

#### Alpine Linux
```bash
apk add bash coreutils findutils grep openssl rsync sshpass pv
```

### 🍎 macOS

macOS requires some additional tools since it ships with outdated versions:

```bash
# Install required tools
brew install bash rsync openssl@3 pv

# Install sshpass (only if you need saved sessions)
brew install hudochenkov/sshpass/sshpass

# Add Homebrew to PATH (Apple Silicon)
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zprofile  # or ~/.bash_profile

# Or for Intel Macs
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bash_profile

# Run with new bash
/opt/homebrew/bin/bash remote [args]
```

**Why these tools?**
- **bash ≥ 4**: macOS ships with bash 3.2 (GPL v2 license)
- **rsync 3.2.x**: Native rsync is 2.6.x, doesn't support `--info=progress2`
- **openssl@3**: Ensures PBKDF2 support
- **sshpass**: Only needed for `remote save/open` with passwords

**Note:** Direct mode may fail on macOS due to missing `hostname -I`. Use proxy or local mode instead.

### 🐡 BSD Systems (FreeBSD/OpenBSD/NetBSD)

```bash
# FreeBSD
pkg install bash rsync openssl

# OpenBSD
pkg_add bash rsync

# NetBSD
pkgin install bash rsync openssl
```

**Note:** Direct mode may fail due to missing `hostname -I`. Use proxy or local mode instead.

### ☀️ Solaris/Illumos

Add this to the script if not detected:
```bash
elif [[ "$OSTYPE" == "sunos"* ]]; then
    PLATFORM="bsd"
fi
```

Install GNU tools:
```bash
pkg install bash rsync openssl pv
```

## Dependencies

### Required
- `bash` >= 4.0 (for arrays and modern features)
- `ssh` (OpenSSH)
- `rsync` >= 3.1 (for `--info=progress2`, >= 3.2 for `--append-verify`)
- `openssl` >= 1.1 (for PBKDF2)

### Optional but Recommended
- `sha256sum` or `coreutils` (for hash verification)
- `sshpass` (for saved sessions with passwords)
- `pv` (for progress bars in proxy mode)
- `mktemp` (usually pre-installed)
- `coreutils` (required for Alpine/minimal systems)

## Usage

### Basic Commands

```bash
# Open a new SSH session
remote open myserver user@host.com

# Save credentials for easy reconnection
remote save myserver user@host.com password

# List active sessions
remote list

# Execute command on remote
remote exec myserver "ls -la"

# Close session
remote close myserver
```

### File Transfers

```bash
# Download file (with resume support)
remote download myserver /path/to/remote/file.tar.gz

# Upload file
remote upload myserver local-file.tar.gz /remote/path/

# Transfer between servers
remote transfer server1 /path/file server2 /dest/path

# Options
--no-resume   # Disable resume (start from beginning)
--no-verify   # Skip hash verification
--compress    # Enable compression
--quiet       # Reduce output verbosity
```

### Background Jobs

```bash
# List all background transfers
remote progress list

# Check specific job
remote progress job.XYZ123

# Clean completed jobs
remote progress clean
```

## Security Notes

- Credentials are encrypted using AES-256-CBC with PBKDF2
- All inputs are validated and properly escaped
- Temporary SSH keys for direct transfers are auto-cleaned
- Files created with restrictive permissions (umask 077)
- Host key verification enabled by default (use `--trust-host` to skip - ONLY in controlled environments!)

## Transfer Modes

1. **Proxy Mode** (default): Stream through local machine
2. **Direct Mode**: Temporary SSH key for direct server-to-server transfer
3. **Local Mode**: Download to local disk, then upload

## Author

Created by **Italo Almeida**

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you would like to change.

## Troubleshooting

### Common Issues

#### "bash: remote: command not found"
- Ensure `/usr/local/bin` is in your PATH
- Or use the full path: `/usr/local/bin/remote`

#### "remote: line X: local: not in a function" 
- You're using dash/sh instead of bash
- Run with: `bash remote` or `/usr/local/bin/bash remote`

#### "unknown option -pbkdf2"
- Your OpenSSL is too old (< 1.1)
- Update OpenSSL or use a newer system

#### "rsync: unknown option --info=progress2"
- Your rsync is too old (< 3.1)
- Update rsync to 3.2 or newer

#### macOS: "hostname: illegal option -- I"
- Direct mode uses `hostname -I` which doesn't exist on macOS
- Use proxy or local mode instead

#### Alpine/BusyBox: "stat: unrecognized option"
- Install coreutils: `apk add coreutils`

#### "sshpass: command not found"
- This is only needed for saved sessions
- Install it or use SSH keys instead

## Acknowledgments

Special thanks to the security reviewers who helped make this tool production-ready through multiple iterations of hardening.