import Foundation

protocol NFCReading: AnyObject {
    var isAvailable: Bool { get }
    func beginScan(completion: @escaping (Result<NFCCardRecord, NFCScanError>) -> Void)
}

enum NFCScanError: LocalizedError, Equatable {
    case unavailable
    case busy
    case connectionFailed(String)
    case readingFailed(String)

    var errorDescription: String? {
        switch self {
        case .unavailable:
            "此设备不支持应用内 NFC 扫描。请使用支持 NFC 的 iPhone 真机。"
        case .busy:
            "已有一次 NFC 扫描正在进行。"
        case let .connectionFailed(message):
            "无法连接卡片：\(message)"
        case let .readingFailed(message):
            "读取失败：\(message)"
        }
    }
}
