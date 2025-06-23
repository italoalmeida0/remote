#!/bin/bash
# Generate SHA256 hash for remote binary
# This should be run before each release

cd "$(dirname "$0")/.." || exit 1

if [ ! -f "bin/remote" ]; then
    echo "Error: bin/remote not found"
    exit 1
fi

# Generate hash
sha256sum bin/remote > bin/remote.sha256

echo "Generated bin/remote.sha256:"
cat bin/remote.sha256
echo ""
echo "Remember to commit and push both files:"
echo "  git add bin/remote bin/remote.sha256"
echo "  git commit -m 'Update binary and hash'"
echo "  git push"