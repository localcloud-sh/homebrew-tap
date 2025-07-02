#!/bin/bash
# homebrew-tap/.github/scripts/update-formula.sh

set -e

VERSION=$1
if [ -z "$VERSION" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

# Remove 'v' prefix if present
VERSION=${VERSION#v}

echo "Updating formula for version $VERSION..."

# Download files and calculate SHA256
declare -A SHAS
PLATFORMS=("darwin-arm64" "darwin-amd64" "linux-amd64" "linux-arm64")

for PLATFORM in "${PLATFORMS[@]}"; do
  URL="https://github.com/localcloud/localcloud/releases/download/v${VERSION}/localcloud-${VERSION}-${PLATFORM}.tar.gz"

  echo "Downloading $PLATFORM..."
  curl -L -o "localcloud-${PLATFORM}.tar.gz" "$URL"

  SHA=$(shasum -a 256 "localcloud-${PLATFORM}.tar.gz" | awk '{print $1}')
  SHAS[$PLATFORM]=$SHA

  rm "localcloud-${PLATFORM}.tar.gz"

  echo "$PLATFORM SHA256: $SHA"
done

# Update the formula
FORMULA_FILE="Formula/localcloud.rb"

# Update version
sed -i '' "s/version \".*\"/version \"$VERSION\"/" "$FORMULA_FILE"

# Update SHA256 hashes
sed -i '' "s/PLACEHOLDER_SHA256_DARWIN_ARM64/${SHAS[darwin-arm64]}/" "$FORMULA_FILE"
sed -i '' "s/PLACEHOLDER_SHA256_DARWIN_AMD64/${SHAS[darwin-amd64]}/" "$FORMULA_FILE"
sed -i '' "s/PLACEHOLDER_SHA256_LINUX_AMD64/${SHAS[linux-amd64]}/" "$FORMULA_FILE"
sed -i '' "s/PLACEHOLDER_SHA256_LINUX_ARM64/${SHAS[linux-arm64]}/" "$FORMULA_FILE"

# If not placeholders, update existing SHAs
sed -i '' "s/sha256 \"[a-f0-9]\{64\}\" # darwin-arm64/sha256 \"${SHAS[darwin-arm64]}\" # darwin-arm64/" "$FORMULA_FILE"
sed -i '' "s/sha256 \"[a-f0-9]\{64\}\" # darwin-amd64/sha256 \"${SHAS[darwin-amd64]}\" # darwin-amd64/" "$FORMULA_FILE"
sed -i '' "s/sha256 \"[a-f0-9]\{64\}\" # linux-amd64/sha256 \"${SHAS[linux-amd64]}\" # linux-amd64/" "$FORMULA_FILE"
sed -i '' "s/sha256 \"[a-f0-9]\{64\}\" # linux-arm64/sha256 \"${SHAS[linux-arm64]}\" # linux-arm64/" "$FORMULA_FILE"

echo "Formula updated successfully!"