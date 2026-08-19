class Flowwatch < Formula
  desc "Lightweight, privacy-focused macOS per-application traffic monitor"
  homepage "https://github.com/JunieXD/FlowWatch"
  license "MIT"
  depends_on macos: :ventura

  if Hardware::CPU.arm?
    url "https://github.com/JunieXD/FlowWatch/releases/download/v0.2.2/flowwatch-aarch64-apple-darwin.tar.gz"
    sha256 "78acf1b5cabb5cf67f2375ebcdbad3359617625dcac3b29ea52faccd7d98b4a3"
  else
    url "https://github.com/JunieXD/FlowWatch/releases/download/v0.2.2/flowwatch-x86_64-apple-darwin.tar.gz"
    sha256 "855d6cf8c2a9942d8d949334dde74e24ba8d8fdd6eb438b2b4a0ea256f016931"
  end

  def install
    bin.install "flowwatch"
  end

  def caveats
    <<~EOS
      安装或升级后，请运行下面的命令安装并启动登录自启服务：
        flowwatch install

      查看采集状态：
        flowwatch doctor
        flowwatch status
    EOS
  end

  test do
    assert_match "flowwatch #{version}", shell_output("#{bin}/flowwatch --version")
    assert_match "macOS 应用流量统计工具", shell_output("#{bin}/flowwatch --help")
  end
end
