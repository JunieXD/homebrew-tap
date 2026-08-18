#!/bin/sh

set -eu

TAG="${1:-}"
CHECKSUMS="${2:-}"
OUTPUT="${3:-Formula/flowwatch.rb}"
case "$TAG" in
    v[0-9]*.[0-9]*.[0-9]*) VERSION="${TAG#v}" ;;
    *) echo "版本标签无效：${TAG}" >&2; exit 2 ;;
esac
if [ ! -f "$CHECKSUMS" ]; then
    echo "找不到校验和文件：${CHECKSUMS}" >&2
    exit 2
fi

read_hash() {
    asset="$1"
    value="$(awk -v asset="$asset" '
        NF == 2 {
            name = $2
            sub(/^\*/, "", name)
            if (name == asset) print tolower($1)
        }
    ' "$CHECKSUMS")"
    case "$value" in
        *"
"* | *[!0-9a-f]* | "")
            echo "SHA256SUMS 中必须且只能包含一个 ${asset} 条目。" >&2
            exit 2
            ;;
    esac
    if [ "${#value}" -ne 64 ]; then
        echo "${asset} 的 SHA-256 无效。" >&2
        exit 2
    fi
    printf '%s' "$value"
}

ARM64_SHA256="$(read_hash flowwatch-aarch64-apple-darwin.tar.gz)"
X86_64_SHA256="$(read_hash flowwatch-x86_64-apple-darwin.tar.gz)"
mkdir -p "$(dirname -- "$OUTPUT")"
TEMPORARY="${OUTPUT}.new.$$"
cleanup() {
    rm -f "$TEMPORARY"
}
trap cleanup EXIT HUP INT TERM
cat > "$TEMPORARY" <<FORMULA
class Flowwatch < Formula
  desc "Lightweight, privacy-focused macOS per-application traffic monitor"
  homepage "https://github.com/JunieXD/FlowWatch"
  license "MIT"
  depends_on macos: :ventura

  if Hardware::CPU.arm?
    url "https://github.com/JunieXD/FlowWatch/releases/download/v${VERSION}/flowwatch-aarch64-apple-darwin.tar.gz"
    sha256 "${ARM64_SHA256}"
  else
    url "https://github.com/JunieXD/FlowWatch/releases/download/v${VERSION}/flowwatch-x86_64-apple-darwin.tar.gz"
    sha256 "${X86_64_SHA256}"
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
FORMULA
mv "$TEMPORARY" "$OUTPUT"
trap - EXIT HUP INT TERM
