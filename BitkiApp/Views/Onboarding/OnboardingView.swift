import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
}

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "camera.viewfinder",
            title: "Bitkilerinizi Tanıyın",
            subtitle: "Fotoğraf çekin, yapay zeka bitkinizi anında tanısın ve bakım bilgilerini otomatik doldursun.",
            color: PlantiumTheme.primaryGreen
        ),
        OnboardingPage(
            icon: "chart.line.uptrend.xyaxis",
            title: "Gelişimi Takip Edin",
            subtitle: "Bitkilerinizin zaman içindeki değişimlerini kaydedin ve sağlık durumlarını karşılaştırın.",
            color: PlantiumTheme.darkGreen
        ),
        OnboardingPage(
            icon: "heart.text.square.fill",
            title: "Sağlıklı Bitkiler",
            subtitle: "AI destekli analizlerle bitkilerinizin ihtiyaçlarını öğrenin ve en iyi bakımı sağlayın.",
            color: PlantiumTheme.accentGold
        )
    ]

    var body: some View {
        ZStack {
            PlantiumTheme.background.ignoresSafeArea()

            VStack(spacing: 0) {
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        onboardingPageView(page)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.4), value: currentPage)

                pageIndicator
                    .padding(.bottom, 16)

                actionButton
                    .padding(.horizontal, 32)
                    .padding(.bottom, 48)
            }
        }
    }

    private func onboardingPageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(page.color.opacity(0.12))
                    .frame(width: 200, height: 200)

                Circle()
                    .fill(page.color.opacity(0.08))
                    .frame(width: 160, height: 160)

                Image(systemName: page.icon)
                    .font(.system(size: 64))
                    .foregroundStyle(page.color)
                    .symbolEffect(.bounce, value: currentPage)
            }
            .transition(.scale.combined(with: .opacity))

            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(PlantiumTheme.textPrimary)
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.body)
                    .foregroundStyle(PlantiumTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 24)
            }

            Spacer()
            Spacer()
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Capsule()
                    .fill(index == currentPage ? PlantiumTheme.primaryGreen : Color.gray.opacity(0.3))
                    .frame(width: index == currentPage ? 24 : 8, height: 8)
                    .animation(.spring(response: 0.3), value: currentPage)
            }
        }
    }

    private var actionButton: some View {
        Button {
            if currentPage < pages.count - 1 {
                withAnimation(.easeInOut(duration: 0.4)) {
                    currentPage += 1
                }
            } else {
                onComplete()
            }
        } label: {
            Text(currentPage < pages.count - 1 ? "Devam Et" : "Başlayalım")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(PlantiumTheme.gradientPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
