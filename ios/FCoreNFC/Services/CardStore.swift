import Combine
import Foundation

@MainActor
final class CardStore: ObservableObject {
    @Published private(set) var cards: [NFCCardRecord] = []

    private let fileManager: FileManager
    private let fileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(fileManager: FileManager = .default, fileURL: URL? = nil) {
        self.fileManager = fileManager
        let baseURL = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        self.fileURL = fileURL ?? baseURL.appendingPathComponent("FCoreNFC/cards.json")
        self.encoder = JSONEncoder()
        self.decoder = JSONDecoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        load()
    }

    func save(_ card: NFCCardRecord) {
        guard !cards.contains(where: { $0.id == card.id }) else { return }
        cards.insert(card, at: 0)
        persist()
    }

    func remove(at offsets: IndexSet) {
        cards.remove(atOffsets: offsets)
        persist()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? decoder.decode([NFCCardRecord].self, from: data) else { return }
        cards = decoded
    }

    private func persist() {
        do {
            try fileManager.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            let data = try encoder.encode(cards)
            try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
        } catch {
            assertionFailure("Unable to persist NFC records: \(error)")
        }
    }
}

