import SwiftUI

struct InstantAnalysisView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var selectedImage: UIImage?
    @State private var isAnalyzing = false
    @State private var result: InstantAnalysisResult?
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if result == nil {
                        captureSection
                    } else if let analysis = result {
                        resultSection(analysis)
                    }
                }
                .padding(20)
            }
            .background(PlantiumTheme.background)
            .navigationTitle("Anlık Analiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
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

    private var captureSection: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkle.magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(PlantiumTheme.accentGold)

            Text("Herhangi bir bitkinin fotoğrafını çekin ve anında sağlık durumu ile bakım önerileri alın.")
                .font(.subheadline)
                .foregroundStyle(PlantiumTheme.textSecondary)
                .multilineTextAlignment(.center)

            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                Button {
                    Task { await analyze() }
                } label: {
                    Label("Analiz Et", systemImage: "sparkles")
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

    private func resultSection(_ analysis: InstantAnalysisResult) -> some View {
        VStack(spacing: 20) {
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: 180)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(analysis.name)
                            .font(.title2.weight(.bold))
                        if !analysis.species.isEmpty {
                            Text(analysis.species)
                                .font(.subheadline)
                                .foregroundStyle(PlantiumTheme.textSecondary)
                        }
                    }
                    Spacer()
                    ConfidenceBadge(confidence: analysis.confidence)
                }

                Divider()

                Text("Sağlık Değerlendirmesi")
                    .font(.headline)

                Text(analysis.healthAssessment)
                    .font(.subheadline)
                    .foregroundStyle(PlantiumTheme.textSecondary)
                    .lineSpacing(4)
            }
            .padding(16)
            .premiumCard()

            if !analysis.careTips.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Bakım Önerileri")
                        .font(.headline)

                    ForEach(analysis.careTips, id: \.self) { tip in
                        HStack(alignment: .top, spacing: 10) {
                            Image(systemName: "leaf.fill")
                                .foregroundStyle(PlantiumTheme.primaryGreen)
                                .font(.caption)
                            Text(tip)
                                .font(.subheadline)
                        }
                    }
                }
                .padding(16)
                .premiumCard()
            }

            if analysis.confidence < APIConfig.confidenceThreshold {
                HStack(spacing: 10) {
                    Image(systemName: "info.circle.fill")
                        .foregroundStyle(.orange)
                    Text("Düşük güven skoru. Sonuçları doğrulamanızı öneririz.")
                        .font(.caption)
                        .foregroundStyle(PlantiumTheme.textSecondary)
                }
                .padding(12)
                .background(Color.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }

            Button {
                result = nil
                selectedImage = nil
            } label: {
                Text("Yeni Analiz")
                    .font(.headline)
                    .foregroundStyle(PlantiumTheme.primaryGreen)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(PlantiumTheme.lightGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
    }

    private func analyze() async {
        guard let image = selectedImage else { return }
        isAnalyzing = true

        do {
            result = try await OpenAIService.shared.analyzeInstant(from: image)
        } catch {
            errorMessage = error.localizedDescription
        }

        isAnalyzing = false
    }
}

#Preview {
    InstantAnalysisView()
}
