import Foundation
import SwiftData

@Model
final class Plant {
    var id: UUID
    var name: String
    var species: String
    var scientificName: String
    var plantDescription: String
    var wateringFrequency: String
    var lightRequirement: String
    var identificationConfidence: Double
    var createdAt: Date
    var thumbnailPath: String?

    @Relationship(deleteRule: .cascade, inverse: \PlantSnapshot.plant)
    var snapshots: [PlantSnapshot]

    init(
        name: String,
        species: String = "",
        scientificName: String = "",
        plantDescription: String = "",
        wateringFrequency: String = "",
        lightRequirement: String = "",
        identificationConfidence: Double = 0,
        thumbnailPath: String? = nil
    ) {
        self.id = UUID()
        self.name = name
        self.species = species
        self.scientificName = scientificName
        self.plantDescription = plantDescription
        self.wateringFrequency = wateringFrequency
        self.lightRequirement = lightRequirement
        self.identificationConfidence = identificationConfidence
        self.createdAt = Date()
        self.thumbnailPath = thumbnailPath
        self.snapshots = []
    }

    var latestSnapshot: PlantSnapshot? {
        snapshots.sorted { $0.capturedAt > $1.capturedAt }.first
    }

    var healthStatus: String {
        latestSnapshot?.healthStatus ?? "Bilinmiyor"
    }
}

@Model
final class PlantSnapshot {
    var id: UUID
    var imagePath: String
    var capturedAt: Date
    var healthStatus: String
    var healthScore: Int
    var notes: String
    var comparisonSummary: String

    var plant: Plant?

    init(
        imagePath: String,
        healthStatus: String = "Sağlıklı",
        healthScore: Int = 85,
        notes: String = "",
        comparisonSummary: String = ""
    ) {
        self.id = UUID()
        self.imagePath = imagePath
        self.capturedAt = Date()
        self.healthStatus = healthStatus
        self.healthScore = healthScore
        self.notes = notes
        self.comparisonSummary = comparisonSummary
    }
}
