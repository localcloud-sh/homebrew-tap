# homebrew-tap/Formula/localcloud.rb

class Localcloud < Formula
  desc "AI Development at Zero Cost - Run AI models locally with no API costs"
  homepage "https://localcloud.ai"
  version "0.2.3"
  license "Apache-2.0"

  # URLs for different architectures
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/localcloud-sh/localcloud/releases/download/v#{version}/localcloud-v#{version}-darwin-arm64.tar.gz"
    sha256 "3c4eeced28ee2d363c1843f6dd677e96407ea5d8ce28c52c22a9c0fe28e05e6a"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/localcloud-sh/localcloud/releases/download/v#{version}/localcloud-v#{version}-darwin-amd64.tar.gz"
    sha256 "60e16e13cc909ed97d921b831b210f832d7459b9d1657472cf05928d3b231018"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/localcloud-sh/localcloud/releases/download/v#{version}/localcloud-v#{version}-linux-amd64.tar.gz"
    sha256 "02fa46fb44bd2491ab791e69f0f58b6b61995487fc5866a30021c35081b1ab48"
  elsif OS.linux? && Hardware::CPU.arm?
    url "https://github.com/localcloud-sh/localcloud/releases/download/v#{version}/localcloud-v#{version}-linux-arm64.tar.gz"
    sha256 "b664b4c906298f6824efb20f158e03a9242f92c934c2854e4b68794050556ce9"
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