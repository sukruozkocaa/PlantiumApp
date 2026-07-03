import SwiftUI
import SwiftData

struct PlantDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let plant: Plant

    @State private var showCompare = false
    @State private var showDeleteConfirm = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerImage
                infoSection
                careSection
                historySection
                compareButton
            }
            .padding(20)
        }
        .background(PlantiumTheme.background)
        .navigationTitle(plant.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        showDeleteConfirm = true
                    } label: {
                        Label("Bitkiyi Sil", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showCompare) {
            ComparePlantView(plant: plant)
        }
        .alert("Bitkiyi Sil", isPresented: $showDeleteConfirm) {
            Button("Sil", role: .destructive) { deletePlant() }
            Button("İptal", role: .cancel) {}
        } message: {
            Text("Bu bitki ve tüm geçmişi silinecek. Emin misiniz?")
        }
    }

    // MARK: - Sections

    private var headerImage: some View {
        Group {
            if let path = plant.thumbnailPath, let image = ImageStorage.load(path: path) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                ZStack {
                    PlantiumTheme.lightGreen
                    Image(systemName: "leaf.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(PlantiumTheme.primaryGreen)
                }
            }
        }
        .frame(height: 220)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            if !plant.species.isEmpty {
                detailRow(icon: "tag.fill", title: "Tür", value: plant.species)
            }
            if !plant.scientificName.isEmpty {
                detailRow(icon: "text.book.closed", title: "Bilimsel Ad", value: plant.scientificName)
            }
            if plant.identificationConfidence > 0 {
                HStack {
                    detailRow(icon: "checkmark.seal", title: "Tanıma Güveni", value: "%\(Int(plant.identificationConfidence))")
                    Spacer()
                }
            }
            if !plant.plantDescription.isEmpty {
                Text(plant.plantDescription)
                    .font(.subheadline)
                    .foregroundStyle(PlantiumTheme.textSecondary)
                    .lineSpacing(4)
            }
        }
        .padding(16)
        .premiumCard()
    }

    private var careSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Bakım Bilgileri")
                .font(.headline)
                .foregroundStyle(PlantiumTheme.textPrimary)

            if !plant.wateringFrequency.isEmpty {
                detailRow(icon: "drop.fill", title: "Sulama", value: plant.wateringFrequency)
            }
            if !plant.lightRequirement.isEmpty {
                detailRow(icon: "sun.max.fill", title: "Işık", value: plant.lightRequirement)
            }
        }
        .padding(16)
        .premiumCard()
    }

    private var historySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Geçmiş Kayıtlar")
                .font(.headline)
                .foregroundStyle(PlantiumTheme.textPrimary)

            let sorted = plant.snapshots.sorted { $0.capturedAt > $1.capturedAt }

            if sorted.isEmpty {
                Text("Henüz kayıt yok")
                    .font(.subheadline)
                    .foregroundStyle(PlantiumTheme.textSecondary)
            } else {
                ForEach(sorted) { snapshot in
                    SnapshotRow(snapshot: snapshot)
                }
            }
        }
        .padding(16)
        .premiumCard()
    }

    private var compareButton: some View {
        Button {
            showCompare = true
        } label: {
            Label("Yeni Fotoğraf ile Karşılaştır", systemImage: "arrow.triangle.2.circlepath.camera")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(PlantiumTheme.gradientPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }

    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(PlantiumTheme.primaryGreen)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(PlantiumTheme.textSecondary)
                Text(value)
                    .font(.subheadline)
                    .foregroundStyle(PlantiumTheme.textPrimary)
            }
        }
    }

    private func deletePlant() {
        if let path = plant.thumbnailPath {
            ImageStorage.delete(path: path)
        }
        for snapshot in plant.snapshots {
            ImageStorage.delete(path: snapshot.imagePath)
        }
        modelContext.delete(plant)
        dismiss()
    }
}

struct SnapshotRow: View {
    let snapshot: PlantSnapshot

    var body: some View {
        HStack(spacing: 12) {
            if let image = ImageStorage.load(path: snapshot.imagePath) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(snapshot.healthStatus)
                        .font(.subheadline.weight(.medium))
                    HealthScoreBadge(score: snapshot.healthScore)
                }

                Text(snapshot.capturedAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(PlantiumTheme.textSecondary)

                if !snapshot.comparisonSummary.isEmpty {
                    Text(snapshot.comparisonSummary)
                        .font(.caption)
                        .foregroundStyle(PlantiumTheme.textSecondary)
                        .lineLimit(2)
                }
            }

            Spacer()
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        PlantDetailView(plant: Plant(name: "Test", species: "Test"))
    }
    .modelContainer(for: Plant.self, inMemory: true)
}
