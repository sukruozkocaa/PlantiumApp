import SwiftUI

struct SubscriptionView: View {
    @Environment(\.dismiss) private var dismiss

    private let features = [
        ("infinity", "Sınırsız AI Analiz", "Günlük limit olmadan bitki tanıma ve sağlık analizi"),
        ("chart.xyaxis.line", "Gelişmiş Takip", "Detaylı büyüme grafikleri ve karşılaştırma geçmişi"),
        ("bell.badge.fill", "Akıllı Hatırlatmalar", "Sulama ve bakım bildirimleri"),
        ("cloud.fill", "Bulut Yedekleme", "Bitkilerinizi güvenle yedekleyin"),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    headerSection
                    featuresSection
                    pricingSection
                }
                .padding(24)
            }
            .background(PlantiumTheme.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(PlantiumTheme.textSecondary)
                    }
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(PlantiumTheme.accentGold.opacity(0.2))
                    .frame(width: 100, height: 100)

                Image(systemName: "crown.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(PlantiumTheme.accentGold)
            }

            Text("Plantium Premium")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(PlantiumTheme.textPrimary)

            Text("Bitkileriniz için en iyi bakım deneyimi")
                .font(.subheadline)
                .foregroundStyle(PlantiumTheme.textSecondary)
        }
        .padding(.top, 16)
    }

    private var featuresSection: some View {
        VStack(spacing: 14) {
            ForEach(features, id: \.0) { icon, title, desc in
                HStack(spacing: 14) {
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundStyle(PlantiumTheme.primaryGreen)
                        .frame(width: 36)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.subheadline.weight(.semibold))
                        Text(desc)
                            .font(.caption)
                            .foregroundStyle(PlantiumTheme.textSecondary)
                    }

                    Spacer()
                }
                .padding(14)
                .premiumCard()
            }
        }
    }

    private var pricingSection: some View {
        VStack(spacing: 16) {
            VStack(spacing: 4) {
                Text("₺49,99 / ay")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(PlantiumTheme.textPrimary)

                Text("7 gün ücretsiz deneme")
                    .font(.caption)
                    .foregroundStyle(PlantiumTheme.textSecondary)
            }

            Button {
                // StoreKit entegrasyonu buraya eklenecek
            } label: {
                Text("Subscribe Now")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [PlantiumTheme.accentGold, Color(red: 0.75, green: 0.60, blue: 0.30)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: PlantiumTheme.accentGold.opacity(0.4), radius: 12, x: 0, y: 6)
            }

            Text("İstediğiniz zaman iptal edebilirsiniz.")
                .font(.caption2)
                .foregroundStyle(PlantiumTheme.textSecondary)
        }
        .padding(.top, 8)
    }
}

#Preview {
    SubscriptionView()
}
