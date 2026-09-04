# FCore NFC

FCore NFC 是一个面向 iOS 与 Android 的开源 NFC 工具项目。项目目标是帮助用户识别自己拥有或获授权使用的 NFC 标签与卡片、查看公开数据，并在平台和发卡方允许的情况下使用官方数字凭证。

> 当前状态：iOS MVP 开发中。Android 尚未开始。

## iOS MVP

- SwiftUI 原生界面，最低支持 iOS 16
- 使用 Core NFC 扫描 ISO 7816、ISO 15693、FeliCa 与 Apple 支持的 MIFARE 标签
- 读取并解析 NDEF 文本、URI 和原始记录
- 展示卡片 UID/标识符、协议与公开元数据
- 由用户明确确认后，将扫描记录保存在应用本地
- 不上传卡片数据，不内置密钥，不尝试绕过卡片安全机制

## 重要的平台边界

读取卡片不等于复制或模拟卡片。普通 iOS 应用不能通用模拟任意门禁卡、公交卡，也不支持 MIFARE Classic 的 Crypto-1 访问。iPhone 上的安全凭证呈现需要 Apple 管理的 HCE 或 NFC & SE Platform entitlement，并且通常要求开发者是发卡方、运营方或其正式合作伙伴。

因此，本项目把能力分为两条路径：

1. **开放读取路径**：使用公开 Core NFC API，读取用户自己的卡片中操作系统允许访问的数据。
2. **授权数字凭证路径**：未来在取得 Apple entitlement 及门禁/公交运营方合作后，接入官方凭证签发与呈现；不会通过复制实体卡密钥来实现。

详见 [iOS 能力边界](docs/ios-capabilities.md) 和 [架构说明](docs/architecture.md)。

## 运行 iOS 工程

要求：Xcode 16 或更高版本、支持 NFC 的真机、Apple Developer 签名。

```bash
open ios/FCoreNFC.xcodeproj
```

在 Xcode 中选择自己的开发团队和真机后运行。NFC 扫描无法在 Simulator 中完成，但工程和单元测试可以在 Simulator 上构建。

命令行验证：

```bash
xcodebuild \
  -project ios/FCoreNFC.xcodeproj \
  -scheme FCoreNFC \
  -sdk iphonesimulator \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  CODE_SIGNING_ALLOWED=NO test
```

## 仓库结构

```text
ios/                 iOS SwiftUI 应用与测试
docs/                架构、平台能力和路线图
```

## 合法与负责任使用

仅扫描你拥有或已获明确授权测试的卡片。请遵守当地法律、服务协议及场所安全政策。不要提交真实 UID、卡片转储、密钥或个人出行记录到 Issue。

## License

[MIT](LICENSE)

