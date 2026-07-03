import Foundation
import UIKit

enum OpenAIError: LocalizedError {
    case missingAPIKey
    case invalidImage
    case networkError(String)
    case parseError
    case apiError(String)

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "OpenAI API anahtarı bulunamadı. Ayarlar'dan ekleyin."
        case .invalidImage:
            return "Geçersiz görsel."
        case .networkError(let msg):
            return "Ağ hatası: \(msg)"
        case .parseError:
            return "Yanıt işlenemedi."
        case .apiError(let msg):
            return msg
        }
    }
}

@MainActor
final class OpenAIService {
    static let shared = OpenAIService()

    private init() {}

    var apiKey: String {
        let stored = UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
        if !stored.isEmpty { return stored }
        return APIConfig.openAIAPIKey
    }

    func identifyPlant(from image: UIImage) async throws -> PlantIdentificationResult {
        let base64 = try encodeImage(image)
        let prompt = """
        Bu bitki fotoğrafını analiz et. Sadece JSON formatında yanıt ver, başka metin ekleme:
        {
          "name": "Bitkinin yaygın adı (Türkçe)",
          "species": "Tür/cins bilgisi",
          "scientificName": "Bilimsel adı",
          "description": "Kısa açıklama (2-3 cümle, Türkçe)",
          "wateringFrequency": "Sulama sıklığı önerisi",
          "lightRequirement": "Işık ihtiyacı",
          "confidence": 0-100 arası tanıma güven yüzdesi (sayı)
        }
        Eğer bitki tanımlanamıyorsa confidence değerini 50'nin altında ver.
        """

        let json = try await sendVisionRequest(imageBase64: base64, prompt: prompt)
        return try decode(json, as: PlantIdentificationResult.self)
    }

    func analyzeInstant(from image: UIImage) async throws -> InstantAnalysisResult {
        let base64 = try encodeImage(image)
        let prompt = """
        Bu bitki fotoğrafını hızlı analiz et. Sadece JSON formatında yanıt ver:
        {
          "name": "Bitki adı (Türkçe)",
          "species": "Tür bilgisi",
          "healthAssessment": "Sağlık durumu değerlendirmesi (Türkçe, 2-3 cümle)",
          "careTips": ["Bakım önerisi 1", "Bakım önerisi 2", "Bakım önerisi 3"],
          "confidence": 0-100 arası güven yüzdesi
        }
        """

        let json = try await sendVisionRequest(imageBase64: base64, prompt: prompt)
        return try decode(json, as: InstantAnalysisResult.self)
    }

    func comparePlantHealth(
        currentImage: UIImage,
        previousImage: UIImage?,
        plantName: String,
        previousHealthStatus: String,
        previousNotes: String
    ) async throws -> PlantHealthComparison {
        let currentBase64 = try encodeImage(currentImage)
        let prompt = """
        "\(plantName)" adlı bitkinin sağlık durumunu karşılaştır.
        Önceki durum: \(previousHealthStatus). Notlar: \(previousNotes.isEmpty ? "Yok" : previousNotes)

        Sadece JSON formatında yanıt ver:
        {
          "healthStatus": "Mevcut sağlık durumu (Sağlıklı/Dikkat/Gelişiyor/Kötüleşiyor vb.)",
          "healthScore": 0-100 arası sağlık puanı,
          "changes": ["Gözlemlenen değişiklik 1", "Değişiklik 2"],
          "recommendations": ["Öneri 1", "Öneri 2"],
          "summary": "Genel değerlendirme (Türkçe, 2-3 cümle)"
        }
        """

        if let previousImage {
            let previousBase64 = try encodeImage(previousImage)
            let json = try await sendDualImageRequest(
                currentBase64: currentBase64,
                previousBase64: previousBase64,
                prompt: prompt
            )
            return try decode(json, as: PlantHealthComparison.self)
        } else {
            let json = try await sendVisionRequest(imageBase64: currentBase64, prompt: prompt)
            return try decode(json, as: PlantHealthComparison.self)
        }
    }

    // MARK: - Private

    private func encodeImage(_ image: UIImage) throws -> String {
        guard let data = image.jpegData(compressionQuality: 0.7) else {
            throw OpenAIError.invalidImage
        }
        return data.base64EncodedString()
    }

    private func sendVisionRequest(imageBase64: String, prompt: String) async throws -> String {
        guard !apiKey.isEmpty else { throw OpenAIError.missingAPIKey }

        let body: [String: Any] = [
            "model": APIConfig.openAIModel,
            "messages": [
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": prompt],
                        [
                            "type": "image_url",
                            "image_url": ["url": "data:image/jpeg;base64,\(imageBase64)", "detail": "low"]
                        ]
                    ]
                ]
            ],
            "max_tokens": 800,
            "response_format": ["type": "json_object"]
        ]

        return try await performRequest(body: body)
    }

    private func sendDualImageRequest(
        currentBase64: String,
        previousBase64: String,
        prompt: String
    ) async throws -> String {
        guard !apiKey.isEmpty else { throw OpenAIError.missingAPIKey }

        let body: [String: Any] = [
            "model": APIConfig.openAIModel,
            "messages": [
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": prompt + "\n\nİlk fotoğraf önceki durum, ikinci fotoğraf güncel durum."],
                        [
                            "type": "image_url",
                            "image_url": ["url": "data:image/jpeg;base64,\(previousBase64)", "detail": "low"]
                        ],
                        [
                            "type": "image_url",
                            "image_url": ["url": "data:image/jpeg;base64,\(currentBase64)", "detail": "low"]
                        ]
                    ]
                ]
            ],
            "max_tokens": 800,
            "response_format": ["type": "json_object"]
        ]

        return try await performRequest(body: body)
    }

    private func performRequest(body: [String: Any]) async throws -> String {
        guard let url = URL(string: APIConfig.openAIBaseURL) else {
            throw OpenAIError.networkError("Geçersiz URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        request.timeoutInterval = 60

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw OpenAIError.networkError("Geçersiz yanıt")
        }

        if httpResponse.statusCode != 200 {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJson["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw OpenAIError.apiError(message)
            }
            throw OpenAIError.apiError("HTTP \(httpResponse.statusCode)")
        }

        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let choices = json["choices"] as? [[String: Any]],
            let first = choices.first,
            let message = first["message"] as? [String: Any],
            let content = message["content"] as? String
        else {
            throw OpenAIError.parseError
        }

        return content
    }

    private func decode<T: Decodable>(_ jsonString: String, as type: T.Type) throws -> T {
        guard let data = jsonString.data(using: .utf8) else {
            throw OpenAIError.parseError
        }
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
