# homebrew-tap/Formula/localcloud.rb

class Localcloud < Formula
  desc "AI Development at Zero Cost - Run AI models locally with no API costs"
  homepage "https://localcloud.ai"
  version "0.2.1"
  license "Apache-2.0"

  # URLs for different architectures
  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/localcloud-sh/localcloud/releases/download/v#{version}/localcloud-v#{version}-darwin-arm64.tar.gz"
    sha256 "ff3ee7314ad38f9428cb5bd2d82d190df97977ee27d101ed0db58a4b84fb5512"
  elsif OS.mac? && Hardware::CPU.intel?
    url "https://github.com/localcloud-sh/localcloud/releases/download/v#{version}/localcloud-v#{version}-darwin-amd64.tar.gz"
    sha256 "5c39f7cdc4dfbc61f2f25379e15808b28acf2be14708dff58fd394630b5948dd"
  elsif OS.linux? && Hardware::CPU.intel?
    url "https://github.com/localcloud-sh/localcloud/releases/download/v#{version}/localcloud-v#{version}-linux-amd64.tar.gz"
    sha256 "81832e5d22f2d83300e8356290db1992b8c1c0680d833fb786d2b6006700f247"
  elsif OS.linux? && Hardware::CPU.arm?
    url "https://github.com/localcloud-sh/localcloud/releases/download/v#{version}/localcloud-v#{version}-linux-arm64.tar.gz"
    sha256 "fb85e15454c19d08f8fb006dc47d2301059f46ccfd2aba113c06f3c875de8da6"
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