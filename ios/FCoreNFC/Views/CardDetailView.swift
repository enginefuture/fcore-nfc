import SwiftUI

struct CardDetailView: View {
    let card: NFCCardRecord

    var body: some View {
        List {
            Section("卡片") {
                LabeledContent("协议", value: card.technology.rawValue)
                LabeledContent("扫描时间", value: card.scannedAt.formatted(date: .abbreviated, time: .standard))
                VStack(alignment: .leading, spacing: 6) {
                    Text("标识符").font(.caption).foregroundStyle(.secondary)
                    Text(card.identifierHex.isEmpty ? "不可用" : card.identifierHex)
                        .font(.body.monospaced())
                        .textSelection(.enabled)
                }
            }

            if !card.metadata.isEmpty {
                Section("公开元数据") {
                    ForEach(card.metadata.keys.sorted(), id: \.self) { key in
                        LabeledContent(key, value: card.metadata[key] ?? "")
                    }
                }
            }

            Section("NDEF 记录") {
                if card.ndefRecords.isEmpty {
                    Text("卡片不支持 NDEF，或没有公开 NDEF 记录。")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(card.ndefRecords) { record in
                        VStack(alignment: .leading, spacing: 6) {
                            if let decodedValue = record.decodedValue {
                                Text(decodedValue).textSelection(.enabled)
                            }
                            Text("Type: \(record.typeHex) · TNF: \(record.typeNameFormat)")
                                .font(.caption.monospaced())
                                .foregroundStyle(.secondary)
                            DisclosureGroup("原始 Payload") {
                                Text(record.payloadHex)
                                    .font(.caption.monospaced())
                                    .textSelection(.enabled)
                            }
                        }
                    }
                }
            }

            Section {
                Label("这是一条读取记录，不是可模拟的卡片凭证。", systemImage: "lock.shield")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(card.technology.rawValue)
    }
}

