import SwiftUI

struct ScanResultView: View {
    @Environment(\.dismiss) private var dismiss
    let card: NFCCardRecord
    let onSave: () -> Void

    var body: some View {
        NavigationStack {
            CardDetailView(card: card)
                .navigationTitle("扫描结果")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("不保存") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("保存到本机") {
                            onSave()
                            dismiss()
                        }
                    }
                }
        }
    }
}

