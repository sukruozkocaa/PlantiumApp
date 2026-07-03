import UIKit

enum ImageStorage {
    private static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    static func save(_ image: UIImage, prefix: String = "plant") -> String? {
        guard let data = image.jpegData(compressionQuality: 0.85) else { return nil }
        let filename = "\(prefix)_\(UUID().uuidString).jpg"
        let url = documentsDirectory.appendingPathComponent(filename)
        do {
            try data.write(to: url)
            return filename
        } catch {
            return nil
        }
    }

    static func load(path: String) -> UIImage? {
        let url = documentsDirectory.appendingPathComponent(path)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        return UIImage(contentsOfFile: url.path)
    }

    static func delete(path: String) {
        let url = documentsDirectory.appendingPathComponent(path)
        try? FileManager.default.removeItem(at: url)
    }
}
