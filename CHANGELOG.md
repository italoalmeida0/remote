# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2024-01-23

### Initial Release

#### Features
- SSH session management with persistent connections
- Resume support for interrupted transfers
- File compression during transfers
- Hash verification for data integrity
- Background job system with progress tracking
- Direct server-to-server transfers
- Secure credential storage with PBKDF2 encryption
- Cross-platform support (Linux, macOS, BSD, Unix)

#### Security
- Input validation and sanitization
- Secure shell escaping with `printf %q`
- Restrictive file permissions (umask 077)
- PBKDF2 with 600k iterations for password encryption
- Automatic cleanup of temporary SSH keys
- Host key verification enabled by default

#### Platform Support
- Linux: All major distributions (Debian, Ubuntu, RHEL, Fedora, Arch, openSUSE, Alpine)
- macOS: Both Intel and Apple Silicon (requires Homebrew packages)
- BSD: FreeBSD, OpenBSD, NetBSD
- Unix: Basic support for Solaris/Illumos

#### Dependencies
- bash >= 4.0
- rsync >= 3.2
- OpenSSH
- OpenSSL >= 1.1
- Optional: sshpass, pv

### Known Limitations
- Direct mode may fail on macOS due to missing `hostname -I`
- Some Unix systems may require additional GNU tools
- Alpine Linux requires coreutils package