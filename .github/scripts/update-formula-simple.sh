#!/bin/bash
# homebrew-tap/.github/scripts/update-formula-simple.sh

set -e

VERSION=$1
if [ -z "$VERSION" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

# Remove 'v' prefix if present
VERSION=${VERSION#v}

echo "Updating formula for version $VERSION..."

FORMULA_FILE="Formula/localcloud.rb"

# Check if formula file exists
if [ ! -f "$FORMULA_FILE" ]; then
  echo "Error: Formula file not found at $FORMULA_FILE"
  exit 1
fi

# Update version - Linux compatible sed (no -i '')
sed -i "s/version \".*\"/version \"$VERSION\"/" "$FORMULA_FILE"

# Download and calculate SHA256 for each platform
echo "Calculating SHA256 for each platform..."

# Function to update SHA256 for a specific line
update_sha256() {
  local line_number=$1
  local sha256=$2
  sed -i "${line_number}s/sha256 \".*\"/sha256 \"$sha256\"/" "$FORMULA_FILE"
}

# Darwin ARM64
URL="https://github.com/localcloud-sh/localcloud/releases/download/v${VERSION}/localcloud-${VERSION}-darwin-arm64.tar.gz"
echo "Downloading darwin-arm64..."
if curl -L -o "temp-darwin-arm64.tar.gz" "$URL" 2>/dev/null; then
  SHA_DARWIN_ARM64=$(sha256sum "temp-darwin-arm64.tar.gz" | awk '{print $1}')
  rm "temp-darwin-arm64.tar.gz"
  echo "darwin-arm64: $SHA_DARWIN_ARM64"
  # Find line number and update
  LINE=$(grep -n "darwin-arm64.tar.gz" "$FORMULA_FILE" | cut -d: -f1)
  if [ ! -z "$LINE" ]; then
    NEXT_LINE=$((LINE + 1))
    update_sha256 $NEXT_LINE "$SHA_DARWIN_ARM64"
  fi
fi

# Darwin AMD64
URL="https://github.com/localcloud-sh/localcloud/releases/download/v${VERSION}/localcloud-${VERSION}-darwin-amd64.tar.gz"
echo "Downloading darwin-amd64..."
if curl -L -o "temp-darwin-amd64.tar.gz" "$URL" 2>/dev/null; then
  SHA_DARWIN_AMD64=$(sha256sum "temp-darwin-amd64.tar.gz" | awk '{print $1}')
  rm "temp-darwin-amd64.tar.gz"
  echo "darwin-amd64: $SHA_DARWIN_AMD64"
  # Find line number and update
  LINE=$(grep -n "darwin-amd64.tar.gz" "$FORMULA_FILE" | cut -d: -f1)
  if [ ! -z "$LINE" ]; then
    NEXT_LINE=$((LINE + 1))
    update_sha256 $NEXT_LINE "$SHA_DARWIN_AMD64"
  fi
fi

# Linux AMD64
URL="https://github.com/localcloud-sh/localcloud/releases/download/v${VERSION}/localcloud-${VERSION}-linux-amd64.tar.gz"
echo "Downloading linux-amd64..."
if curl -L -o "temp-linux-amd64.tar.gz" "$URL" 2>/dev/null; then
  SHA_LINUX_AMD64=$(sha256sum "temp-linux-amd64.tar.gz" | awk '{print $1}')
  rm "temp-linux-amd64.tar.gz"
  echo "linux-amd64: $SHA_LINUX_AMD64"
  # Find line number and update
  LINE=$(grep -n "linux-amd64.tar.gz" "$FORMULA_FILE" | cut -d: -f1)
  if [ ! -z "$LINE" ]; then
    NEXT_LINE=$((LINE + 1))
    update_sha256 $NEXT_LINE "$SHA_LINUX_AMD64"
  fi
fi

# Linux ARM64
URL="https://github.com/localcloud-sh/localcloud/releases/download/v${VERSION}/localcloud-${VERSION}-linux-arm64.tar.gz"
echo "Downloading linux-arm64..."
if curl -L -o "temp-linux-arm64.tar.gz" "$URL" 2>/dev/null; then
  SHA_LINUX_ARM64=$(sha256sum "temp-linux-arm64.tar.gz" | awk '{print $1}')
  rm "temp-linux-arm64.tar.gz"
  echo "linux-arm64: $SHA_LINUX_ARM64"
  # Find line number and update
  LINE=$(grep -n "linux-arm64.tar.gz" "$FORMULA_FILE" | cut -d: -f1)
  if [ ! -z "$LINE" ]; then
    NEXT_LINE=$((LINE + 1))
    update_sha256 $NEXT_LINE "$SHA_LINUX_ARM64"
  fi
fi

echo ""
echo "Formula updated successfully!"
echo "Version: $VERSION"