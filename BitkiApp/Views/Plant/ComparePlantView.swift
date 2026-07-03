import SwiftUI
import SwiftData

struct ComparePlantView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let plant: Plant

    @State private var selectedImage: UIImage?
    @State private var isAnalyzing = false
    @State private var comparisonResult: PlantHealthComparison?
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if comparisonResult == nil {
                        captureSection
                    } else if let result = comparisonResult {
                        resultSection(result)
                    }
                }
                .padding(20)
            }
            .background(PlantiumTheme.background)
            .navigationTitle("Durum Karşılaştır")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                }
            }
            .overlay {
                if isAnalyzing {
                    LoadingOverlay(message: "Geçmiş ile karşılaştırılıyor...")
                }
            }
            .alert("Hata", isPresented: .init(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("Tamam") { errorMessage = nil }
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private var captureSection: some View {
        VStack(spacing: 20) {
            Text("Bitkinizin güncel fotoğrafını çekin. AI, önceki kayıtlarla karşılaştırarak durumunu değerlendirecek.")
                .font(.subheadline)
                .foregroundStyle(PlantiumTheme.textSecondary)
                .multilineTextAlignment(.center)

            if let previous = plant.latestSnapshot,
               let prevImage = ImageStorage.load(path: previous.imagePath) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Son Kayıt")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(PlantiumTheme.textSecondary)

                    HStack(spacing: 12) {
                        Image(uiImage: prevImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(previous.healthStatus)
                                .font(.subheadline.weight(.medium))
                            Text(previous.capturedAt.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(PlantiumTheme.textSecondary)
                        }
                    }
                }
                .padding(14)
                .premiumCard()
            }

            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                Button {
                    Task { await compareHealth() }
                } label: {
                    Label("Karşılaştır", systemImage: "arrow.triangle.2.circlepath")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(PlantiumTheme.gradientPrimary)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
            } else {
                PhotoSourcePicker(selectedImage: $selectedImage)
            }
        }
    }

    private func resultSection(_ result: PlantHealthComparison) -> some View {
        VStack(spacing: 20) {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            VStack(spacing: 12) {
                HStack {
                    Text(result.healthStatus)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(PlantiumTheme.textPrimary)
                    Spacer()
                    HealthScoreBadge(score: result.healthScore)
                        .font(.title3)
                }

                Text(result.summary)
                    .font(.subheadline)
                    .foregroundStyle(PlantiumTheme.textSecondary)
                    .lineSpacing(4)
            }
            .padding(16)
            .premiumCard()

            if !result.changes.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Gözlemlenen Değişiklikler")
                        .font(.headline)

                    ForEach(result.changes, id: \.self) { change in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundStyle(PlantiumTheme.primaryGreen)
                            Text(change)
                                .font(.subheadline)
                        }
                    }
                }
                .padding(16)
                .premiumCard()
            }

            if !result.recommendations.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Öneriler")
                        .font(.headline)

                    ForEach(result.recommendations, id: \.self) { rec in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "lightbulb.fill")
                                .foregroundStyle(PlantiumTheme.accentGold)
                            Text(rec)
                                .font(.subheadline)
                        }
                    }
                }
                .padding(16)
                .premiumCard()
            }

            Button {
                saveComparison(result)
            } label: {
                Text("Kaydet ve Kapat")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(PlantiumTheme.primaryGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }

    private func compareHealth() async {
        guard let image = selectedImage else { return }
        isAnalyzing = true

        let previous = plant.latestSnapshot
        let previousImage = previous.flatMap { ImageStorage.load(path: $0.imagePath) }

        do {
            let result = try await OpenAIService.shared.comparePlantHealth(
                currentImage: image,
                previousImage: previousImage,
                plantName: plant.name,
                previousHealthStatus: previous?.healthStatus ?? "Bilinmiyor",
                previousNotes: previous?.comparisonSummary ?? ""
            )
            comparisonResult = result
        } catch {
            errorMessage = error.localizedDescription
        }

        isAnalyzing = false
    }

    private func saveComparison(_ result: PlantHealthComparison) {
        guard let image = selectedImage,
              let imagePath = ImageStorage.save(image, prefix: "snapshot") else { return }

        let snapshot = PlantSnapshot(
            imagePath: imagePath,
            healthStatus: result.healthStatus,
            healthScore: result.healthScore,
            notes: result.changes.joined(separator: "; "),
            comparisonSummary: result.summary
        )
        snapshot.plant = plant
        plant.snapshots.append(snapshot)
        plant.thumbnailPath = imagePath

        dismiss()
    }
}

#Preview {
    ComparePlantView(plant: Plant(name: "Test"))
        .modelContainer(for: Plant.self, inMemory: true)
}
