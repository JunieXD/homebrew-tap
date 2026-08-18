# JunieXD Homebrew Tap

JunieXD 项目的 Homebrew Formula。目前提供 [FlowWatch](https://github.com/JunieXD/FlowWatch)。

## 安装 FlowWatch

```sh
brew install JunieXD/tap/flowwatch
flowwatch install
```

`brew upgrade flowwatch` 更新 Homebrew 中的程序后，再运行一次 `flowwatch install`，即可更新后台采集服务并保留全部历史数据和设置。

```sh
flowwatch doctor
flowwatch status
```

Formula 每 6 小时检查一次 FlowWatch 的最新正式 Release，并从发布的 `SHA256SUMS` 生成两个 macOS 架构的校验值。
JunieXD 项目的 Homebrew Formula
