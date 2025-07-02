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

# Update the formula
FORMULA_FILE="Formula/localcloud.rb"

# Update version
sed -i '' "s/version \".*\"/version \"$VERSION\"/" "$FORMULA_FILE"

# Download files and update SHA256 for each platform
PLATFORMS=("darwin-arm64" "darwin-amd64" "linux-amd64" "linux-arm64")

for PLATFORM in "${PLATFORMS[@]}"; do
  URL="https://github.com/localcloud-sh/localcloud/releases/download/v${VERSION}/localcloud-${VERSION}-${PLATFORM}.tar.gz"

  echo "Downloading $PLATFORM..."
  if ! curl -L -o "localcloud-${PLATFORM}.tar.gz" "$URL"; then
    echo "Failed to download $PLATFORM"
    exit 1
  fi

  SHA=$(shasum -a 256 "localcloud-${PLATFORM}.tar.gz" | awk '{print $1}')
  rm "localcloud-${PLATFORM}.tar.gz"

  echo "$PLATFORM SHA256: $SHA"

  # Update SHA in formula based on platform
  case $PLATFORM in
    "darwin-arm64")
      sed -i '' "s/sha256 \"[a-f0-9]*\"/sha256 \"$SHA\"/" "$FORMULA_FILE" | head -1
      sed -i '' "s/PLACEHOLDER_SHA256_DARWIN_ARM64/$SHA/" "$FORMULA_FILE"
      ;;
    "darwin-amd64")
      sed -i '' "s/sha256 \"[a-f0-9]*\"/sha256 \"$SHA\"/" "$FORMULA_FILE" | head -2 | tail -1
      sed -i '' "s/PLACEHOLDER_SHA256_DARWIN_AMD64/$SHA/" "$FORMULA_FILE"
      ;;
    "linux-amd64")
      sed -i '' "s/sha256 \"[a-f0-9]*\"/sha256 \"$SHA\"/" "$FORMULA_FILE" | head -3 | tail -1
      sed -i '' "s/PLACEHOLDER_SHA256_LINUX_AMD64/$SHA/" "$FORMULA_FILE"
      ;;
    "linux-arm64")
      sed -i '' "s/sha256 \"[a-f0-9]*\"/sha256 \"$SHA\"/" "$FORMULA_FILE" | tail -1
      sed -i '' "s/PLACEHOLDER_SHA256_LINUX_ARM64/$SHA/" "$FORMULA_FILE"
      ;;
  esac
done

echo "Formula updated successfully!"