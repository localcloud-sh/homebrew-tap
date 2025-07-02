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

# Create temporary file
TEMP_FILE=$(mktemp)
FORMULA_FILE="Formula/localcloud.rb"

# Copy current formula to temp
cp "$FORMULA_FILE" "$TEMP_FILE"

# Update version
sed -i '' "s/version \".*\"/version \"$VERSION\"/" "$TEMP_FILE"

# Download and calculate SHA256 for each platform
echo "Calculating SHA256 for each platform..."

# Darwin ARM64
URL="https://github.com/localcloud-sh/localcloud/releases/download/v${VERSION}/localcloud-${VERSION}-darwin-arm64.tar.gz"
echo "Downloading darwin-arm64..."
curl -L -o "temp-darwin-arm64.tar.gz" "$URL" 2>/dev/null
SHA_DARWIN_ARM64=$(shasum -a 256 "temp-darwin-arm64.tar.gz" | awk '{print $1}')
rm "temp-darwin-arm64.tar.gz"
echo "darwin-arm64: $SHA_DARWIN_ARM64"

# Darwin AMD64
URL="https://github.com/localcloud-sh/localcloud/releases/download/v${VERSION}/localcloud-${VERSION}-darwin-amd64.tar.gz"
echo "Downloading darwin-amd64..."
curl -L -o "temp-darwin-amd64.tar.gz" "$URL" 2>/dev/null
SHA_DARWIN_AMD64=$(shasum -a 256 "temp-darwin-amd64.tar.gz" | awk '{print $1}')
rm "temp-darwin-amd64.tar.gz"
echo "darwin-amd64: $SHA_DARWIN_AMD64"

# Linux AMD64
URL="https://github.com/localcloud-sh/localcloud/releases/download/v${VERSION}/localcloud-${VERSION}-linux-amd64.tar.gz"
echo "Downloading linux-amd64..."
curl -L -o "temp-linux-amd64.tar.gz" "$URL" 2>/dev/null
SHA_LINUX_AMD64=$(shasum -a 256 "temp-linux-amd64.tar.gz" | awk '{print $1}')
rm "temp-linux-amd64.tar.gz"
echo "linux-amd64: $SHA_LINUX_AMD64"

# Linux ARM64
URL="https://github.com/localcloud-sh/localcloud/releases/download/v${VERSION}/localcloud-${VERSION}-linux-arm64.tar.gz"
echo "Downloading linux-arm64..."
curl -L -o "temp-linux-arm64.tar.gz" "$URL" 2>/dev/null
SHA_LINUX_ARM64=$(shasum -a 256 "temp-linux-arm64.tar.gz" | awk '{print $1}')
rm "temp-linux-arm64.tar.gz"
echo "linux-arm64: $SHA_LINUX_ARM64"

# Replace placeholders
sed -i '' "s/PLACEHOLDER_SHA256_DARWIN_ARM64/$SHA_DARWIN_ARM64/" "$TEMP_FILE"
sed -i '' "s/PLACEHOLDER_SHA256_DARWIN_AMD64/$SHA_DARWIN_AMD64/" "$TEMP_FILE"
sed -i '' "s/PLACEHOLDER_SHA256_LINUX_AMD64/$SHA_LINUX_AMD64/" "$TEMP_FILE"
sed -i '' "s/PLACEHOLDER_SHA256_LINUX_ARM64/$SHA_LINUX_ARM64/" "$TEMP_FILE"

# Move temp file back
mv "$TEMP_FILE" "$FORMULA_FILE"

echo ""
echo "Formula updated successfully!"
echo "Version: $VERSION"
echo ""
echo "SHA256 checksums:"
echo "  darwin-arm64: $SHA_DARWIN_ARM64"
echo "  darwin-amd64: $SHA_DARWIN_AMD64"
echo "  linux-amd64:  $SHA_LINUX_AMD64"
echo "  linux-arm64:  $SHA_LINUX_ARM64"
echo ""
echo "Don't forget to commit and push the changes!"