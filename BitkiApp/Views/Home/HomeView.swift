import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Plant.createdAt, order: .reverse) private var plants: [Plant]

    @State private var showAddPlant = false
    @State private var showInstantAnalysis = false
    @State private var showSettings = false
    @State private var showSubscription = false
    @State private var selectedPlantID: UUID?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                PlantiumNavBar(
                    onSettings: { showSettings = true },
                    onPremium: { showSubscription = true }
                )

                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        quickActionsSection
                        plantsSection
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 32)
                }
            }
            .background(PlantiumTheme.background)
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddPlant) {
                AddPlantView()
            }
            .sheet(isPresented: $showInstantAnalysis) {
                InstantAnalysisView()
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showSubscription) {
                SubscriptionView()
            }
            .navigationDestination(for: UUID.self) { id in
                if let plant = plants.first(where: { $0.id == id }) {
                    PlantDetailView(plant: plant)
                }
            }
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 16) {
            Text(greetingText)
                .font(.subheadline)
                .foregroundStyle(PlantiumTheme.textSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            subscribeBanner
        }
    }

    private var subscribeBanner: some View {
        Button {
            showSubscription = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: "crown.fill")
                            .foregroundStyle(PlantiumTheme.accentGold)
                        Text("Plantium Premium")
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                    Text("Sınırsız AI analiz ve gelişmiş takip")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.8))
                }

                Spacer()

                Text("Subscribe Now")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(PlantiumTheme.darkGreen)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(PlantiumTheme.accentGold)
                    .clipShape(Capsule())
            }
            .padding(16)
            .background(PlantiumTheme.gradientPremium)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: PlantiumTheme.darkGreen.opacity(0.3), radius: 12, x: 0, y: 6)
        }
    }

    // MARK: - Quick Actions

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Hızlı İşlemler")
                .font(.headline)
                .foregroundStyle(PlantiumTheme.textPrimary)

            HStack(spacing: 12) {
                QuickActionCard(
                    icon: "plus.circle.fill",
                    title: "Bitki Ekle",
                    subtitle: "AI ile tanı",
                    color: PlantiumTheme.primaryGreen
                ) {
                    showAddPlant = true
                }

                QuickActionCard(
                    icon: "sparkle.magnifyingglass",
                    title: "Anlık Analiz",
                    subtitle: "Hızlı tarama",
                    color: PlantiumTheme.accentGold
                ) {
                    showInstantAnalysis = true
                }
            }
        }
    }

    // MARK: - Plants

    private var plantsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Bitkilerim")
                    .font(.headline)
                    .foregroundStyle(PlantiumTheme.textPrimary)

                Spacer()

                Text("\(plants.count) bitki")
                    .font(.caption)
                    .foregroundStyle(PlantiumTheme.textSecondary)
            }

            if plants.isEmpty {
                emptyPlantsView
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(plants) { plant in
                        PlantCardView(plant: plant)
                            .onTapGesture {
                                selectedPlantID = plant.id
                            }
                    }
                }
            }
        }
    }

    private var emptyPlantsView: some View {
        VStack(spacing: 16) {
            Image(systemName: "leaf.circle")
                .font(.system(size: 48))
                .foregroundStyle(PlantiumTheme.primaryGreen.opacity(0.5))

            Text("Henüz bitki eklemediniz")
                .font(.subheadline)
                .foregroundStyle(PlantiumTheme.textSecondary)

            Button("İlk Bitkini Ekle") {
                showAddPlant = true
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(PlantiumTheme.primaryGreen)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .premiumCard()
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return "Günaydın! Bitkileriniz nasıl?"
        case 12..<18: return "İyi günler! Bitkilerinizi kontrol edin."
        default: return "İyi akşamlar! Bitkileriniz sizi bekliyor."
        }
    }
}

struct QuickActionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(PlantiumTheme.textPrimary)

                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(PlantiumTheme.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .premiumCard()
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Plant.self, inMemory: true)
}
