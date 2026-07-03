import Foundation

enum APIConfig {
    /// OpenAI API anahtarınızı buraya girin veya ortam değişkeninden okuyun.
    static var openAIAPIKey: String {
        if let envKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"], !envKey.isEmpty {
            return envKey
        }
        return "" // Kullanıcı Ayarlar ekranından da girebilir
    }

    static let confidenceThreshold: Double = 80.0
    static let openAIModel = "gpt-4o-mini"
    static let openAIBaseURL = "https://api.openai.com/v1/chat/completions"
}
