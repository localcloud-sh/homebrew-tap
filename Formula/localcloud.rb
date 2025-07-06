# homebrew-tap/Formula/localcloud.rb

class Localcloud < Formula
  desc "AI Development at Zero Cost - Run AI models locally with no API costs"
  homepage "https://localcloud.ai"
  version "0.2.4"
  license "Apache-2.0"

  # URLs for different architectures
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/localcloud-sh/localcloud/releases/download/v#{version}/localcloud-v#{version}-darwin-arm64.tar.gz"
    sha256 "0909be1480fa5726d93b2ec1c28e2e53b3909d8b85cb60bc240baabeddfa217c"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/localcloud-sh/localcloud/releases/download/v#{version}/localcloud-v#{version}-darwin-amd64.tar.gz"
    sha256 "50b80285646f6b06569d258ecca7b92a853494142fea92a20f43d6a53e2f62be"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/localcloud-sh/localcloud/releases/download/v#{version}/localcloud-v#{version}-linux-amd64.tar.gz"
    sha256 "fbf61a8f2af5cde9528d4646f780372daf1187718ab37226a1460e760004c0fa"
  elsif OS.linux? && Hardware::CPU.arm?
    url "https://github.com/localcloud-sh/localcloud/releases/download/v#{version}/localcloud-v#{version}-linux-arm64.tar.gz"
    sha256 "7a748f26489c328a93f20a0e7f3d15f820ee310d62971104d4bfe1efd5dd375a"
  end

  depends_on "docker" => :recommended

  def install
    # Install the binary
    arch = Hardware::CPU.arm? ? "arm64" : "amd64"
    bin.install "localcloud-#{OS.kernel_name.downcase}-#{arch}" => "localcloud"

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
        https://github.com/localcloud-sh/localcloud
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