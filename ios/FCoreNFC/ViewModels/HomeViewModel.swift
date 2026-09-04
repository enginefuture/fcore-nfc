import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var isScanning = false
    @Published var scannedCard: NFCCardRecord?
    @Published var errorMessage: String?

    let store: CardStore
    private let reader: NFCReading

    var isNFCAvailable: Bool { reader.isAvailable }

    init(store: CardStore, reader: NFCReading = CoreNFCReader()) {
        self.store = store
        self.reader = reader
    }

    func scan() {
        guard !isScanning else { return }
        isScanning = true
        reader.beginScan { [weak self] result in
            Task { @MainActor in
                guard let self else { return }
                self.isScanning = false
                switch result {
                case let .success(card): self.scannedCard = card
                case let .failure(error): self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func saveScannedCard() {
        guard let scannedCard else { return }
        store.save(scannedCard)
        self.scannedCard = nil
    }
}

