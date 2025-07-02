# homebrew-tap/Formula/localcloud.rb

class Localcloud < Formula
  desc "AI Development at Zero Cost - Run AI models locally with no API costs"
  homepage "https://localcloud.ai"
  version "0.1.1"
  license "Apache-2.0"

  # URLs for different architectures
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/localcloud/localcloud/releases/download/v#{version}/localcloud-#{version}-darwin-arm64.tar.gz"
    sha256 "PLACEHOLDER_SHA256_DARWIN_ARM64"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/localcloud/localcloud/releases/download/v#{version}/localcloud-#{version}-darwin-amd64.tar.gz"
    sha256 "PLACEHOLDER_SHA256_DARWIN_AMD64"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/localcloud/localcloud/releases/download/v#{version}/localcloud-#{version}-linux-amd64.tar.gz"
    sha256 "PLACEHOLDER_SHA256_LINUX_AMD64"
  elsif OS.linux? && Hardware::CPU.arm?
    url "https://github.com/localcloud/localcloud/releases/download/v#{version}/localcloud-#{version}-linux-arm64.tar.gz"
    sha256 "PLACEHOLDER_SHA256_LINUX_ARM64"
  end

  depends_on "docker" => :recommended

  def install
    # Install the binary
    bin.install "localcloud-#{OS.kernel_name.downcase}-#{Hardware::CPU.arch}" => "localcloud"

    # Create symlink for 'lc' command
    bin.install_symlink "localcloud" => "lc"

    # Generate shell completions
    generate_completions_from_executable(bin/"localcloud", "completion")
  end

  def post_install
    # Create necessary directories
    (var/"localcloud").mkpath
    (etc/"localcloud").mkpath
  end

  def caveats
    <<~EOS
      #{name} has been installed. You can run it with:
        localcloud
        lc (shorthand)

      To get started:
        lc init my-project
        cd my-project
        lc setup

      Docker is required to run LocalCloud services.
      If you don't have Docker installed:
        brew install --cask docker

      For more information:
        https://github.com/localcloud/localcloud
    EOS
  end

  test do
    # Test that the binary runs
    assert_match "LocalCloud", shell_output("#{bin}/localcloud --version")
    assert_match "LocalCloud", shell_output("#{bin}/lc --version")

    # Test help command
    assert_match "AI Development at Zero Cost", shell_output("#{bin}/localcloud --help")
  end
end