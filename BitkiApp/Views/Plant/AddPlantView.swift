import SwiftUI
import SwiftData

struct AddPlantView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var selectedImage: UIImage?
    @State private var name = ""
    @State private var species = ""
    @State private var scientificName = ""
    @State private var plantDescription = ""
    @State private var wateringFrequency = ""
    @State private var lightRequirement = ""
    @State private var confidence: Double = 0
    @State private var isAnalyzing = false
    @State private var identificationFailed = false
    @State private var errorMessage: String?
    @State private var showForm = false
    @State private var step: AddPlantStep = .capture

    enum AddPlantStep {
        case capture, form
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    switch step {
                    case .capture:
                        captureSection
                    case .form:
                        formSection
                    }
                }
                .padding(20)
            }
            .background(PlantiumTheme.background)
            .navigationTitle("Bitki Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
            }
            .overlay {
                if isAnalyzing {
                    LoadingOverlay(message: "Bitki analiz ediliyor...")
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

    // MARK: - Capture

    private var captureSection: some View {
        VStack(spacing: 20) {
            Text("Bitkinizin fotoğrafını çekin veya seçin. AI bitkiyi tanıyıp bilgileri otomatik dolduracak.")
                .font(.subheadline)
                .foregroundStyle(PlantiumTheme.textSecondary)
                .multilineTextAlignment(.center)

            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                Button("Tekrar Seç") {
                    selectedImage = nil
                }
                .font(.subheadline)
                .foregroundStyle(PlantiumTheme.primaryGreen)

                Button {
                    Task { await analyzePlant() }
                } label: {
                    Label("AI ile Tanı", systemImage: "sparkles")
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

    // MARK: - Form

    private var formSection: some View {
        VStack(spacing: 20) {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 160)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            if identificationFailed {
                HStack(spacing: 10) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                    Text("Bitki tanınamadı (%\(Int(confidence)) güven). Lütfen bilgileri manuel girin.")
                        .font(.subheadline)
                        .foregroundStyle(PlantiumTheme.textPrimary)
                }
                .padding(14)
                .background(Color.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            } else if confidence > 0 {
                HStack {
                    ConfidenceBadge(confidence: confidence)
                    Text("Bilgiler otomatik dolduruldu")
                        .font(.caption)
                        .foregroundStyle(PlantiumTheme.textSecondary)
                }
            }

            formField(title: "Bitki Adı", text: $name, placeholder: "Örn: Monstera")
            formField(title: "Tür", text: $species, placeholder: "Örn: Deliciosa")
            formField(title: "Bilimsel Ad", text: $scientificName, placeholder: "Örn: Monstera deliciosa")
            formField(title: "Açıklama", text: $plantDescription, placeholder: "Bitki hakkında kısa bilgi", axis: .vertical)
            formField(title: "Sulama Sıklığı", text: $wateringFrequency, placeholder: "Örn: Haftada 1 kez")
            formField(title: "Işık İhtiyacı", text: $lightRequirement, placeholder: "Örn: Dolaylı güneş ışığı")

            Button {
                savePlant()
            } label: {
                Text("Bitkiyi Kaydet")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(name.isEmpty ? Color.gray : PlantiumTheme.primaryGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .disabled(name.isEmpty)
        }
    }

    private func formField(
        title: String,
        text: Binding<String>,
        placeholder: String,
        axis: Axis = .horizontal
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(PlantiumTheme.textSecondary)

            TextField(placeholder, text: text, axis: axis)
                .lineLimit(axis == .vertical ? 3...6 : 1...1)
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }

    // MARK: - Actions

    private func analyzePlant() async {
        guard let image = selectedImage else { return }
        isAnalyzing = true

        do {
            let result = try await OpenAIService.shared.identifyPlant(from: image)
            confidence = result.confidence

            if result.isConfident {
                name = result.name
                species = result.species
                scientificName = result.scientificName
                plantDescription = result.description
                wateringFrequency = result.wateringFrequency
                lightRequirement = result.lightRequirement
                identificationFailed = false
            } else {
                identificationFailed = true
                name = ""
                species = ""
                scientificName = ""
                plantDescription = ""
                wateringFrequency = ""
                lightRequirement = ""
            }

            withAnimation { step = .form }
        } catch {
            errorMessage = error.localizedDescription
        }

        isAnalyzing = false
    }

    private func savePlant() {
        guard let image = selectedImage,
              let imagePath = ImageStorage.save(image) else { return }

        let plant = Plant(
            name: name,
            species: species,
            scientificName: scientificName,
            plantDescription: plantDescription,
            wateringFrequency: wateringFrequency,
            lightRequirement: lightRequirement,
            identificationConfidence: confidence,
            thumbnailPath: imagePath
        )

        let snapshot = PlantSnapshot(
            imagePath: imagePath,
            healthStatus: "Sağlıklı",
            healthScore: 85,
            notes: "İlk kayıt",
            comparisonSummary: "Bitki sisteme eklendi."
        )
        snapshot.plant = plant
        plant.snapshots.append(snapshot)

        modelContext.insert(plant)
        dismiss()
    }
}

#Preview {
    AddPlantView()
        .modelContainer(for: Plant.self, inMemory: true)
}
