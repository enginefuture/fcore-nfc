# iOS NFC 能力边界

## 当前可以实现

- 使用 `NFCTagReaderSession` 发现 ISO 7816、ISO 15693、FeliCa 和受支持的 MIFARE 标签。
- 读取 NDEF 消息与操作系统允许访问的协议数据。
- 向可写 NDEF 标签写入普通内容（后续里程碑）。
- 对公开、无需破解的公交卡数据进行协议解析。

## 当前不能承诺

- 普通第三方应用不能把任意实体门禁卡或公交卡“复制”进 iPhone。
- iOS 不提供 MIFARE Classic Crypto-1 的通用读取/模拟能力。
- UID 并不是完整卡片凭证；保存 UID 不会让 iPhone 变成原卡。
- 受保护扇区、密钥和后台系统账户余额不能通过普通 NDEF 扫描获得。

## 官方数字凭证路径

Apple 的 `CardSession` 可为符合条件的应用提供 ISO 7816 HCE；NFC & SE Platform 可在 Secure Element 中安全配置凭证。两者都受 entitlement、地区、业务资质和用例限制。门禁、校园卡、酒店钥匙或闭环公交通常需要与运营方签订有效合作关系，而不是由终端用户自行复制。

项目在获得对应 entitlement 前不会把模拟按钮做成看似可用的功能。

