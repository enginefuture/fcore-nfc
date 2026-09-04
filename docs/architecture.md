# Architecture

## 原则

- **本地优先**：扫描结果默认只存在内存中，用户点击保存后才写入应用沙盒。
- **读取与解析分离**：平台读取器产生统一的 `NFCCardRecord`，卡种解析器只处理协议数据。
- **最小权限**：当前 iOS target 只声明 Tag Reading capability，不声明 HCE、支付或 Secure Element 权限。
- **明确能力**：UI 区分“可读取”“只可识别”和“需要运营方授权的数字凭证”。

## iOS 模块

```text
SwiftUI Views
      │
HomeViewModel ─── CardStore (JSON / Application Support)
      │
 NFCReading protocol
      │
CoreNFCReader ─── NDEFPayloadDecoder
      │
 Apple Core NFC
```

`NFCReading` 是测试边界，也为后续接入外置读卡器保留替换点。`NFCCardRecord` 只保存公开扫描结果和 NDEF 数据，不表示一份可模拟卡片的镜像。

## 后续阶段

1. 完善 iOS 协议 APDU 传输层及公开公交卡解析器。
2. 增加加密本地存储、导出前脱敏和隐私控制。
3. 创建 Android/Kotlin 模块，使用相同的数据模型与测试向量。
4. 与门禁或公交运营方合作，评估 Apple NFC & SE Platform / HCE entitlement。

