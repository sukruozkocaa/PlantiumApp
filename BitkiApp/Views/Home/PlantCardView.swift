import SwiftUI

struct PlantCardView: View {
    let plant: Plant

    var body: some View {
        HStack(spacing: 16) {
            plantImage
                .frame(width: 72, height: 72)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 6) {
                Text(plant.name)
                    .font(.headline)
                    .foregroundStyle(PlantiumTheme.textPrimary)

                if !plant.species.isEmpty {
                    Text(plant.species)
                        .font(.caption)
                        .foregroundStyle(PlantiumTheme.textSecondary)
                }

                HStack(spacing: 8) {
                    Label(plant.healthStatus, systemImage: healthIcon)
                        .font(.caption)
                        .foregroundStyle(healthColor)

                    if let latest = plant.latestSnapshot {
                        HealthScoreBadge(score: latest.healthScore)
                    }
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundStyle(PlantiumTheme.textSecondary.opacity(0.5))
        }
        .padding(14)
        .premiumCard()
    }

    @ViewBuilder
    private var plantImage: some View {
        if let path = plant.thumbnailPath, let image = ImageStorage.load(path: path) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                PlantiumTheme.lightGreen
                Image(systemName: "leaf.fill")
                    .font(.title2)
                    .foregroundStyle(PlantiumTheme.primaryGreen)
            }
        }
    }

    private var healthIcon: String {
        guard let score = plant.latestSnapshot?.healthScore else { return "questionmark.circle" }
        switch score {
        case 80...100: return "heart.fill"
        case 50..<80: return "exclamationmark.circle"
        default: return "heart.slash"
        }
    }

    private var healthColor: Color {
        guard let score = plant.latestSnapshot?.healthScore else { return .gray }
        switch score {
        case 80...100: return .green
        case 50..<80: return .orange
        default: return .red
        }
    }
}

#Preview {
    let plant = Plant(name: "Monstera", species: "Deliciosa", identificationConfidence: 92)
    return PlantCardView(plant: plant)
        .padding()
        .background(PlantiumTheme.background)
}
