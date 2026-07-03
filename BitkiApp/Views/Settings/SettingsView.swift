import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var apiKey: String = UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
    @State private var showAPIKey = false
    @State private var saved = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack {
                        if showAPIKey {
                            TextField("sk-...", text: $apiKey)
                                .textContentType(.password)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.never)
                        } else {
                            Text(apiKey.isEmpty ? "API anahtarı girilmedi" : "••••••••••••")
                                .foregroundStyle(apiKey.isEmpty ? .secondary : .primary)
                        }

                        Button {
                            showAPIKey.toggle()
                        } label: {
                            Image(systemName: showAPIKey ? "eye.slash" : "eye")
                                .foregroundStyle(PlantiumTheme.primaryGreen)
                        }
                    }
                } header: {
                    Text("OpenAI API Anahtarı")
                } footer: {
                    Text("Bitki tanıma ve analiz için OpenAI API anahtarı gereklidir. Anahtarınızı platform.openai.com adresinden alabilirsiniz.")
                }

                Section("Uygulama") {
                    HStack {
                        Text("Versiyon")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Güven Eşiği")
                        Spacer()
                        Text("%\(Int(APIConfig.confidenceThreshold))")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Hakkında") {
                    Label("Plantium", systemImage: "leaf.fill")
                    Text("AI destekli bitki tanıma ve takip uygulaması.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Ayarlar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        UserDefaults.standard.set(apiKey, forKey: "openai_api_key")
                        saved = true
                    }
                }
            }
            .alert("Kaydedildi", isPresented: $saved) {
                Button("Tamam") {}
            } message: {
                Text("API anahtarı başarıyla kaydedildi.")
            }
        }
    }
}

#Preview {
    SettingsView()
}
