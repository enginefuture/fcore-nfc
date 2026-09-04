import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel: HomeViewModel
    @ObservedObject private var store: CardStore

    init(viewModel: HomeViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _store = ObservedObject(wrappedValue: viewModel.store)
    }

    var body: some View {
        NavigationStack {
            List {
                scannerSection
                capabilitySection
                historySection
            }
            .navigationTitle("FCore NFC")
            .sheet(item: $viewModel.scannedCard) { card in
                ScanResultView(card: card) {
                    viewModel.saveScannedCard()
                }
            }
            .alert(
                "无法完成扫描",
                isPresented: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { if !$0 { viewModel.errorMessage = nil } }
                ),
                actions: { Button("知道了", role: .cancel) {} },
                message: { Text(viewModel.errorMessage ?? "未知错误") }
            )
        }
    }

    private var scannerSection: some View {
        Section {
            VStack(spacing: 18) {
                Image(systemName: "wave.3.right.circle.fill")
                    .font(.system(size: 66))
                    .foregroundStyle(.blue)

                VStack(spacing: 6) {
                    Text("读取你的 NFC 卡片")
                        .font(.title3.bold())
                    Text("扫描结果默认不会保存；确认后才写入本机。")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }

                Button(action: viewModel.scan) {
                    Label(viewModel.isScanning ? "正在等待卡片…" : "开始扫描", systemImage: "sensor.tag.radiowaves.forward")
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isScanning || !viewModel.isNFCAvailable)

                if !viewModel.isNFCAvailable {
                    Text("Simulator 或此设备不支持 Core NFC 扫描。")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
    }

    private var capabilitySection: some View {
        Section("能力说明") {
            Label("可读取系统允许访问的标签和公开数据", systemImage: "checkmark.shield")
            Label("保存 UID 不代表复制了卡片", systemImage: "info.circle")
            Label("模拟门禁/公交凭证需要 Apple 与运营方授权", systemImage: "lock.shield")
        }
        .font(.subheadline)
    }

    @ViewBuilder
    private var historySection: some View {
        Section("本机记录") {
            if store.cards.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "tray")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                    Text("还没有保存的扫描记录")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            } else {
                ForEach(store.cards) { card in
                    NavigationLink {
                        CardDetailView(card: card)
                    } label: {
                        CardRow(card: card)
                    }
                }
                .onDelete(perform: store.remove)
            }
        }
    }
}

private struct CardRow: View {
    let card: NFCCardRecord

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: card.technology.systemImage)
                .frame(width: 36, height: 36)
                .background(Color.blue.opacity(0.12), in: RoundedRectangle(cornerRadius: 9))
                .foregroundStyle(.blue)
            VStack(alignment: .leading, spacing: 3) {
                Text(card.technology.rawValue).font(.headline)
                Text(card.identifierHex.isEmpty ? "无可用标识符" : card.identifierHex)
                    .font(.caption.monospaced())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            Spacer()
        }
    }
}
