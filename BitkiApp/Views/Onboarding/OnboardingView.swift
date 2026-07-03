import SwiftUI

struct OnboardingFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

struct OnboardingPage: Identifiable {
    let id = UUID()
    let badge: String
    let title: String
    let subtitle: String
    let features: [OnboardingFeature]
    let accentColor: Color
    let heroKind: OnboardingHeroKind
}

enum OnboardingHeroKind {
    case welcome
    case identify
    case health
    case garden
}

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var currentPage = 0
    @State private var heroAppeared = false

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            badge: "Hoş Geldiniz",
            title: "Bitkileriniz İçin\nAkıllı Asistanınız",
            subtitle: "Plantium, ev bitkilerinizi tanımanızdan sağlıklarını korumaya kadar tüm bakım sürecinizi tek uygulamada birleştirir.",
            features: [
                OnboardingFeature(
                    icon: "leaf.circle.fill",
                    title: "Kişisel Bitki Koleksiyonu",
                    description: "Tüm bitkilerinizi tek bir yerde toplayın ve anında erişin."
                ),
                OnboardingFeature(
                    icon: "sparkles",
                    title: "Yapay Zeka Destekli",
                    description: "Her adımda akıllı öneriler ve otomatik bilgi doldurma."
                ),
                OnboardingFeature(
                    icon: "hand.raised.fill",
                    title: "Kolay Başlangıç",
                    description: "Fotoğraf çekerek dakikalar içinde ilk bitkinizi ekleyin."
                ),
            ],
            accentColor: PlantiumTheme.primaryGreen,
            heroKind: .welcome
        ),
        OnboardingPage(
            badge: "Yapay Zeka Tanıma",
            title: "Fotoğraf Çekin,\nBitkiniz Tanınsın",
            subtitle: "Kamera veya galeriden bir fotoğraf seçin. Yapay zeka türü, bilimsel adı ve bakım ihtiyaçlarını saniyeler içinde belirlesin.",
            features: [
                OnboardingFeature(
                    icon: "camera.viewfinder",
                    title: "Anında Tür Tanıma",
                    description: "Monstera'dan sukulentlere — binlerce türü tanır."
                ),
                OnboardingFeature(
                    icon: "doc.text.fill",
                    title: "Otomatik Form Doldurma",
                    description: "Sulama sıklığı, ışık ihtiyacı ve açıklama kendiliğinden gelir."
                ),
                OnboardingFeature(
                    icon: "checkmark.seal.fill",
                    title: "Güven Skoru",
                    description: "Her tanıma sonucu güven yüzdesiyle birlikte sunulur."
                ),
            ],
            accentColor: PlantiumTheme.darkGreen,
            heroKind: .identify
        ),
        OnboardingPage(
            badge: "Sağlık Analizi",
            title: "Sağlığı Görün,\nSorunları Erken Yakalayın",
            subtitle: "Anlık analiz ve zaman içindeki karşılaştırmalarla bitkilerinizin durumunu net bir şekilde takip edin.",
            features: [
                OnboardingFeature(
                    icon: "sparkle.magnifyingglass",
                    title: "Anlık Sağlık Analizi",
                    description: "Herhangi bir bitkinin fotoğrafından anında sağlık raporu alın."
                ),
                OnboardingFeature(
                    icon: "chart.line.uptrend.xyaxis",
                    title: "Gelişim Karşılaştırması",
                    description: "Farklı tarihlerdeki fotoğrafları yan yana kıyaslayın."
                ),
                OnboardingFeature(
                    icon: "heart.text.square.fill",
                    title: "Sağlık Puanı",
                    description: "0–100 arası puan ile bitkinizin genel durumunu anlayın."
                ),
            ],
            accentColor: PlantiumTheme.accentGold,
            heroKind: .health
        ),
        OnboardingPage(
            badge: "Bahçeniz Hazır",
            title: "Her Şey Net,\nHemen Başlayın",
            subtitle: "Plantium'u açtığınızda ne yapacağınızı bilirsiniz: bitki ekleyin, analiz edin, gelişimini izleyin.",
            features: [
                OnboardingFeature(
                    icon: "plus.circle.fill",
                    title: "İlk Bitkinizi Ekleyin",
                    description: "Ana ekrandan \"Bitki Ekle\" ile koleksiyonunuzu başlatın."
                ),
                OnboardingFeature(
                    icon: "bolt.fill",
                    title: "Anlık Analiz Deneyin",
                    description: "Koleksiyona eklemeden herhangi bir bitkiyi analiz edin."
                ),
                OnboardingFeature(
                    icon: "crown.fill",
                    title: "Premium ile Sınırsız",
                    description: "Sınırsız analiz, gelişmiş takip ve akıllı hatırlatmalar."
                ),
            ],
            accentColor: PlantiumTheme.primaryGreen,
            heroKind: .garden
        ),
    ]

    var body: some View {
        ZStack {
            backgroundLayer

            VStack(spacing: 0) {
                topBar
                    .padding(.horizontal, 24)
                    .padding(.top, 12)

                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        pageContent(page, index: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.45), value: currentPage)

                bottomControls
                    .padding(.horizontal, 24)
                    .padding(.bottom, .zero)
            }
        }
        .onChange(of: currentPage) { _, _ in
            heroAppeared = false
            withAnimation(.spring(response: 0.65, dampingFraction: 0.78).delay(0.05)) {
                heroAppeared = true
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.15)) {
                heroAppeared = true
            }
        }
    }

    // MARK: - Background

    private var backgroundLayer: some View {
        ZStack {
            PlantiumTheme.background.ignoresSafeArea()

            Circle()
                .fill(pages[currentPage].accentColor.opacity(0.10))
                .frame(width: 340, height: 340)
                .blur(radius: 60)
                .offset(x: -80, y: -220)

            Circle()
                .fill(PlantiumTheme.accentGold.opacity(0.08))
                .frame(width: 280, height: 280)
                .blur(radius: 50)
                .offset(x: 120, y: 280)
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "leaf.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(PlantiumTheme.primaryGreen)

                Text("Plantium")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(PlantiumTheme.textPrimary)
            }

            Spacer()

            if currentPage < pages.count - 1 {
                Button("Atla") {
                    onComplete()
                }
                .font(.subheadline.weight(.medium))
                .foregroundStyle(PlantiumTheme.textSecondary)
            }
        }
    }

    // MARK: - Page Content

    private func pageContent(_ page: OnboardingPage, index: Int) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                heroView(for: page)
                    .padding(.top, 30.0)

                VStack(spacing: 14) {
                    Text(page.badge.uppercased())
                        .font(.caption.weight(.bold))
                        .tracking(1.2)
                        .foregroundStyle(page.accentColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(page.accentColor.opacity(0.12))
                        .clipShape(Capsule())

                    Text(page.title)
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(PlantiumTheme.textPrimary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)

                    Text(page.subtitle)
                        .font(.subheadline)
                        .foregroundStyle(PlantiumTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                        .padding(.horizontal, 4)
                }

                VStack(spacing: 10) {
                    ForEach(Array(page.features.enumerated()), id: \.element.id) { featureIndex, feature in
                        featureRow(feature, accent: page.accentColor)
                            .opacity(heroAppeared ? 1 : 0)
                            .offset(y: heroAppeared ? 0 : 16)
                            .animation(
                                .spring(response: 0.55, dampingFraction: 0.8)
                                    .delay(Double(featureIndex) * 0.08),
                                value: heroAppeared
                            )
                    }
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 16)
        }
    }

    private func featureRow(_ feature: OnboardingFeature, accent: Color) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(accent.opacity(0.12))
                    .frame(width: 44, height: 44)

                Image(systemName: feature.icon)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(accent)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(feature.title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(PlantiumTheme.textPrimary)

                Text(feature.description)
                    .font(.caption)
                    .foregroundStyle(PlantiumTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(14)
        .premiumCard()
    }

    // MARK: - Hero Illustrations

    @ViewBuilder
    private func heroView(for page: OnboardingPage) -> some View {
        switch page.heroKind {
        case .welcome:
            welcomeHero(accent: page.accentColor)
        case .identify:
            identifyHero(accent: page.accentColor)
        case .health:
            healthHero(accent: page.accentColor)
        case .garden:
            gardenHero(accent: page.accentColor)
        }
    }

    private func welcomeHero(accent: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(PlantiumTheme.gradientPremium)
                .frame(height: 200)
                .shadow(color: accent.opacity(0.35), radius: 24, x: 0, y: 12)

            Circle()
                .fill(PlantiumTheme.accentGold.opacity(0.2))
                .frame(width: 140, height: 140)
                .blur(radius: 30)
                .offset(x: 80, y: -30)

            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.18))
                        .frame(width: 88, height: 88)

                    Image(systemName: "leaf.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.white)
                        .rotationEffect(.degrees(heroAppeared ? 0 : -12))
                        .scaleEffect(heroAppeared ? 1 : 0.85)
                }

                VStack(alignment: .leading, spacing: 8) {
                    heroMiniCard(icon: "camera.fill", text: "Tanı", color: .white.opacity(0.9))
                    heroMiniCard(icon: "heart.fill", text: "Takip Et", color: .white.opacity(0.9))
                    heroMiniCard(icon: "sparkles", text: "Büyüt", color: PlantiumTheme.accentGold)
                }
            }
            .padding(.horizontal, 28)
        }
        .scaleEffect(heroAppeared ? 1 : 0.94)
        .opacity(heroAppeared ? 1 : 0)
    }

    private func identifyHero(accent: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [accent.opacity(0.15), PlantiumTheme.lightGreen],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(accent.opacity(0.2), lineWidth: 1)
                )

            VStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.white)
                        .frame(width: 120, height: 120)
                        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)

                    Image(systemName: "leaf.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(accent)

                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(accent, lineWidth: 2.5)
                        .frame(width: 130, height: 130)
                        .opacity(heroAppeared ? 1 : 0.4)
                        .scaleEffect(heroAppeared ? 1 : 1.08)
                }

                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.caption.weight(.bold))
                    Text("Monstera Deliciosa · %94 güven")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(accent)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(.white)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
            }
        }
        .scaleEffect(heroAppeared ? 1 : 0.94)
        .opacity(heroAppeared ? 1 : 0)
    }

    private func healthHero(accent: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [accent.opacity(0.18), accent.opacity(0.06)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(accent.opacity(0.25), lineWidth: 1)
                )

            HStack(spacing: 16) {
                VStack(spacing: 10) {
                    ZStack {
                        Circle()
                            .stroke(accent.opacity(0.2), lineWidth: 6)
                            .frame(width: 72, height: 72)

                        Circle()
                            .trim(from: 0, to: heroAppeared ? 0.87 : 0)
                            .stroke(accent, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                            .frame(width: 72, height: 72)
                            .rotationEffect(.degrees(-90))

                        Text("87")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(accent)
                    }

                    Text("Sağlık Puanı")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(PlantiumTheme.textSecondary)
                }

                VStack(alignment: .leading, spacing: 10) {
                    healthStatRow(icon: "drop.fill", label: "Sulama", value: "3 gün sonra", color: .blue)
                    healthStatRow(icon: "sun.max.fill", label: "Işık", value: "Yeterli", color: accent)
                    healthStatRow(icon: "leaf.fill", label: "Durum", value: "Sağlıklı", color: .green)
                }
                .padding(14)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 4)
            }
            .padding(.horizontal, 20)
        }
        .scaleEffect(heroAppeared ? 1 : 0.94)
        .opacity(heroAppeared ? 1 : 0)
    }

    private func gardenHero(accent: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [PlantiumTheme.lightGreen, .white],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(accent.opacity(0.15), lineWidth: 1)
                )

            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    gardenPlantChip(name: "Monstera", icon: "leaf.fill", color: accent)
                    gardenPlantChip(name: "Ficus", icon: "tree.fill", color: PlantiumTheme.darkGreen)
                    gardenPlantChip(name: "Sukulent", icon: "camera.macro", color: PlantiumTheme.accentGold)
                }

                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(accent)
                    Text("Koleksiyonunuz hazır — şimdi ilk bitkinizi ekleyin")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(PlantiumTheme.textSecondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(.white)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
            }
            .padding(.horizontal, 16)
        }
        .scaleEffect(heroAppeared ? 1 : 0.94)
        .opacity(heroAppeared ? 1 : 0)
    }

    private func heroMiniCard(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption.weight(.bold))
            Text(text)
                .font(.caption.weight(.semibold))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 12)
        .padding(.vertical, 7)
        .background(.white.opacity(0.15))
        .clipShape(Capsule())
    }

    private func healthStatRow(icon: String, label: String, value: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
                .frame(width: 16)

            Text(label)
                .font(.caption2)
                .foregroundStyle(PlantiumTheme.textSecondary)

            Spacer()

            Text(value)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(PlantiumTheme.textPrimary)
        }
    }

    private func gardenPlantChip(name: String, icon: String, color: Color) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 52, height: 52)

                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
            }

            Text(name)
                .font(.caption2.weight(.medium))
                .foregroundStyle(PlantiumTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 3)
    }

    // MARK: - Bottom Controls

    private var bottomControls: some View {
        VStack(spacing: 20) {
            pageIndicator

            Button {
                if currentPage < pages.count - 1 {
                    withAnimation(.easeInOut(duration: 0.45)) {
                        currentPage += 1
                    }
                } else {
                    onComplete()
                }
            } label: {
                HStack(spacing: 8) {
                    Text(currentPage < pages.count - 1 ? "Devam Et" : "Bahçeme Başla")
                        .font(.headline)

                    Image(systemName: currentPage < pages.count - 1 ? "arrow.right" : "leaf.fill")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(
                    currentPage == pages.count - 1
                        ? AnyShapeStyle(
                            LinearGradient(
                                colors: [PlantiumTheme.accentGold, Color(red: 0.75, green: 0.60, blue: 0.30)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        : AnyShapeStyle(PlantiumTheme.gradientPrimary)
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(
                    color: (currentPage == pages.count - 1 ? PlantiumTheme.accentGold : PlantiumTheme.primaryGreen)
                        .opacity(0.35),
                    radius: 12,
                    x: 0,
                    y: 6
                )
            }

            Text("\(currentPage + 1) / \(pages.count)")
                .font(.caption2.weight(.medium))
                .foregroundStyle(PlantiumTheme.textSecondary.opacity(0.7))
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? pages[currentPage].accentColor : Color.gray.opacity(0.25))
                    .frame(width: index == currentPage ? 28 : 8, height: 8)
                    .animation(.spring(response: 0.35), value: currentPage)
            }
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
