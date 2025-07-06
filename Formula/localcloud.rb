# homebrew-tap/Formula/localcloud.rb

class Localcloud < Formula
  desc "AI Development at Zero Cost - Run AI models locally with no API costs"
  homepage "https://localcloud.ai"
  version "0.2.5"
  license "Apache-2.0"

  # URLs for different architectures
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/localcloud-sh/localcloud/releases/download/v#{version}/localcloud-v#{version}-darwin-arm64.tar.gz"
    sha256 "7327080a9f8542a617903462ae36d4b87d3ae627aefd69d149f47979b1999ea2"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/localcloud-sh/localcloud/releases/download/v#{version}/localcloud-v#{version}-darwin-amd64.tar.gz"
    sha256 "9305b719008ccea6bb40fd81f16f3641c38dd169dcc5f4fee99bb3eb2762d3b6"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/localcloud-sh/localcloud/releases/download/v#{version}/localcloud-v#{version}-linux-amd64.tar.gz"
    sha256 "1ed9430ef4530c2364b60135b3239ed46e5d57fcf990571a91c3ac18c1bfad45"
  elsif OS.linux? && Hardware::CPU.arm?
    url "https://github.com/localcloud-sh/localcloud/releases/download/v#{version}/localcloud-v#{version}-linux-arm64.tar.gz"
    sha256 "442f5a3e02c4650bb030516e91d1f22871840d91b430ee30e753a0da0256fda1"
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