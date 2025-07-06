#!/bin/bash

set -e

VERSION="$1"
REPO="localcloud-sh/localcloud"

if [ -z "$VERSION" ]; then
    echo "Usage: $0 <version>"
    exit 1
fi

# Remove 'v' prefix if present
VERSION="${VERSION#v}"

echo "Updating LocalCloud formula to version $VERSION"

# Base URL for releases
BASE_URL="https://github.com/$REPO/releases/download/v$VERSION"

# Calculate SHA256 for each platform
echo "Calculating SHA256 hashes..."

DARWIN_ARM64_SHA=$(curl -sL "$BASE_URL/localcloud-v$VERSION-darwin-arm64.tar.gz" | shasum -a 256 | cut -d' ' -f1)
DARWIN_AMD64_SHA=$(curl -sL "$BASE_URL/localcloud-v$VERSION-darwin-amd64.tar.gz" | shasum -a 256 | cut -d' ' -f1)
LINUX_AMD64_SHA=$(curl -sL "$BASE_URL/localcloud-v$VERSION-linux-amd64.tar.gz" | shasum -a 256 | cut -d' ' -f1)
LINUX_ARM64_SHA=$(curl -sL "$BASE_URL/localcloud-v$VERSION-linux-arm64.tar.gz" | shasum -a 256 | cut -d' ' -f1)

echo "Darwin ARM64: $DARWIN_ARM64_SHA"
echo "Darwin AMD64: $DARWIN_AMD64_SHA"
echo "Linux AMD64:  $LINUX_AMD64_SHA"
echo "Linux ARM64:  $LINUX_ARM64_SHA"

# Update the formula file
FORMULA_FILE="Formula/localcloud.rb"

echo "Updating formula file..."

# Create a temporary script for complex sed operations
cat > update_formula.rb << 'EOF'
#!/usr/bin/env ruby

version = ARGV[0]
darwin_arm64_sha = ARGV[1]
darwin_amd64_sha = ARGV[2]
linux_amd64_sha = ARGV[3]
linux_arm64_sha = ARGV[4]

content = File.read('Formula/localcloud.rb')

# Update version
content = content.gsub(/version\s+"[^"]*"/, "version \"#{version}\"")

# Update SHA256 hashes
content = content.gsub(/(if OS\.mac\? && Hardware::CPU\.arm\?.*?sha256\s+)"[^"]*"/m, "\\1\"#{darwin_arm64_sha}\"")
content = content.gsub(/(elsif OS\.mac\? && Hardware::CPU\.intel\?.*?sha256\s+)"[^"]*"/m, "\\1\"#{darwin_amd64_sha}\"")
content = content.gsub(/(elsif OS\.linux\? && Hardware::CPU\.intel\?.*?sha256\s+)"[^"]*"/m, "\\1\"#{linux_amd64_sha}\"")
content = content.gsub(/(elsif OS\.linux\? && Hardware::CPU\.arm\?.*?sha256\s+)"[^"]*"/m, "\\1\"#{linux_arm64_sha}\"")

File.write('Formula/localcloud.rb', content)
EOF

# Run the Ruby script to update the formula
ruby update_formula.rb "$VERSION" "$DARWIN_ARM64_SHA" "$DARWIN_AMD64_SHA" "$LINUX_AMD64_SHA" "$LINUX_ARM64_SHA"

# Clean up
rm update_formula.rb

echo "Formula updated successfully!"

# Show the changes
echo "=== CHANGES ==="
git diff Formula/localcloud.rb || true