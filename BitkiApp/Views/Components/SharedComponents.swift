import SwiftUI
import PhotosUI

struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) private var dismiss
    var sourceType: UIImagePickerController.SourceType = .photoLibrary

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView

        init(_ parent: ImagePickerView) {
            self.parent = parent
        }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

struct PhotoSourcePicker: View {
    @Binding var selectedImage: UIImage?
    @State private var showCamera = false
    @State private var showGallery = false

    var body: some View {
        VStack(spacing: 16) {
            Button {
                showCamera = true
            } label: {
                Label("Kamera ile Çek", systemImage: "camera.fill")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(PlantiumTheme.primaryGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }

            Button {
                showGallery = true
            } label: {
                Label("Galeriden Seç", systemImage: "photo.on.rectangle")
                    .font(.headline)
                    .foregroundStyle(PlantiumTheme.primaryGreen)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(PlantiumTheme.lightGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .fullScreenCover(isPresented: $showCamera) {
            ImagePickerView(image: $selectedImage, sourceType: .camera)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showGallery) {
            ImagePickerView(image: $selectedImage, sourceType: .photoLibrary)
                .ignoresSafeArea()
        }
    }
}

struct LoadingOverlay: View {
    let message: String

    var body: some View {
        ZStack {
            Color.black.opacity(0.4).ignoresSafeArea()

            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.3)
                    .tint(.white)

                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.white)
            }
            .padding(32)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
    }
}

struct ConfidenceBadge: View {
    let confidence: Double

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: confidence >= APIConfig.confidenceThreshold ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
            Text("%\(Int(confidence)) güven")
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(confidence >= APIConfig.confidenceThreshold ? .green : .orange)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            (confidence >= APIConfig.confidenceThreshold ? Color.green : Color.orange)
                .opacity(0.12)
        )
        .clipShape(Capsule())
    }
}

struct HealthScoreBadge: View {
    let score: Int

    private var color: Color {
        switch score {
        case 80...100: return .green
        case 50..<80: return .orange
        default: return .red
        }
    }

    var body: some View {
        Text("\(score)")
            .font(.caption.weight(.bold))
            .foregroundStyle(color)
            .padding(6)
            .background(color.opacity(0.12))
            .clipShape(Circle())
    }
}

struct PlantiumNavBar: View {
    let onSettings: () -> Void
    let onPremium: () -> Void

    var body: some View {
        ZStack {
            HStack {
                settingsButton
                Spacer()
                premiumButton
            }

            brandMark
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background {
            ZStack(alignment: .bottom) {
                Rectangle()
                    .fill(.background)
                    .background(.ultraThinMaterial)

                LinearGradient(
                    colors: [
                        PlantiumTheme.primaryGreen.opacity(0.08),
                        PlantiumTheme.accentGold.opacity(0.04),
                        Color.clear,
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(height: 1)
            }
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
            .ignoresSafeArea(edges: .top)
        }
    }

    private var brandMark: some View {
        HStack(spacing: 7) {
            ZStack {
                Circle()
                    .fill(PlantiumTheme.primaryGreen.opacity(0.12))
                    .frame(width: 28, height: 28)

                Image(systemName: "leaf.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(PlantiumTheme.primaryGreen)
            }

            Text("Plantium")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(PlantiumTheme.textPrimary)
        }
    }

    private var settingsButton: some View {
        Button(action: onSettings) {
            Image(systemName: "gearshape.fill")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(PlantiumTheme.textSecondary)
                .frame(width: 42, height: 42)
                .background(Color.white)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color.black.opacity(0.05), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }

    private var premiumButton: some View {
        Button(action: onPremium) {
            Image(systemName: "crown.fill")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(
                    LinearGradient(
                        colors: [
                            PlantiumTheme.accentGold,
                            Color(red: 0.75, green: 0.60, blue: 0.30),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.35), lineWidth: 1)
                )
                .shadow(color: PlantiumTheme.accentGold.opacity(0.45), radius: 10, x: 0, y: 4)
        }
        .buttonStyle(.plain)
    }
}
