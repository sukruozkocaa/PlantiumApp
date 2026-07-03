import Foundation

struct PlantIdentificationResult: Codable, Equatable {
    let name: String
    let species: String
    let scientificName: String
    let description: String
    let wateringFrequency: String
    let lightRequirement: String
    let confidence: Double

    var isConfident: Bool {
        confidence >= APIConfig.confidenceThreshold
    }
}

struct PlantHealthComparison: Codable, Equatable {
    let healthStatus: String
    let healthScore: Int
    let changes: [String]
    let recommendations: [String]
    let summary: String

    var statusColor: String {
        switch healthScore {
        case 80...100: return "healthy"
        case 50..<80: return "warning"
        default: return "critical"
        }
    }
}

struct InstantAnalysisResult: Codable, Equatable {
    let name: String
    let species: String
    let healthAssessment: String
    let careTips: [String]
    let confidence: Double
}
