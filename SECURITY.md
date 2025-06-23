# Security Policy

## Reporting Security Vulnerabilities

If you discover a security vulnerability in this project, please report it by emailing the author directly. 

**Do not** open a public issue for security vulnerabilities.

## Security Features

This tool implements several security measures:

1. **Input Validation**: All user inputs are validated against strict patterns
2. **Shell Escaping**: Uses `printf %q` for proper shell escaping
3. **Secure File Permissions**: umask 077 ensures files are created with restrictive permissions
4. **Encrypted Credentials**: Passwords stored with PBKDF2 (600k iterations) + AES-256-CBC
5. **SSH Key Management**: Temporary keys for direct transfers are auto-cleaned
6. **Host Verification**: SSH host key checking enabled by default

## Security Considerations

- Never use `--trust-host` on untrusted networks
- Saved credentials are encrypted but stored locally - protect your home directory
- Direct transfer mode temporarily grants source server access to destination
- Review the source code before running with elevated privileges

## Hardening Checklist

- [x] Input validation for all parameters
- [x] Protection against command injection
- [x] Secure temporary file handling
- [x] Proper signal handling and cleanup
- [x] No hardcoded credentials
- [x] Secure random generation for salts
- [x] Protection against path traversal
- [x] Rate limiting considerations (PBKDF2 iterations)