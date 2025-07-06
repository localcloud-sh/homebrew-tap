# homebrew-tap/Formula/localcloud.rb

class Localcloud < Formula
  desc "AI Development at Zero Cost - Run AI models locally with no API costs"
  homepage "https://localcloud.ai"
  version "0.2.2"
  license "Apache-2.0"

  # URLs for different architectures
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/localcloud-sh/localcloud/releases/download/v#{version}/localcloud-v#{version}-darwin-arm64.tar.gz"
    sha256 "0876e29a76db3d7cdf25249aea8b72b4b1fae532eba090f600f947d693952b9e"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/localcloud-sh/localcloud/releases/download/v#{version}/localcloud-v#{version}-darwin-amd64.tar.gz"
    sha256 "fbf53a093f87368c7ccdb57253dadfc55922ef84e6f932e0bce88b81367e47e3"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/localcloud-sh/localcloud/releases/download/v#{version}/localcloud-v#{version}-linux-amd64.tar.gz"
    sha256 "2a3b94439ff4d7b740e725b71e7dbcf16079ff18069acbdd33e6ecdd91c3790a"
  elsif OS.linux? && Hardware::CPU.arm?
    url "https://github.com/localcloud-sh/localcloud/releases/download/v#{version}/localcloud-v#{version}-linux-arm64.tar.gz"
    sha256 "e4a5e4322c75cd8b7eb110528fdb8d25ce46fa819dab1fdd68938ce3fbd68954"
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