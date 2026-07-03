import SwiftUI

enum PlantiumTheme {
    static let primaryGreen = Color(red: 0.18, green: 0.55, blue: 0.34)
    static let darkGreen = Color(red: 0.10, green: 0.35, blue: 0.22)
    static let lightGreen = Color(red: 0.85, green: 0.95, blue: 0.88)
    static let accentGold = Color(red: 0.85, green: 0.72, blue: 0.40)
    static let background = Color(red: 0.97, green: 0.98, blue: 0.96)
    static let cardBackground = Color.white
    static let textPrimary = Color(red: 0.12, green: 0.15, blue: 0.13)
    static let textSecondary = Color(red: 0.45, green: 0.50, blue: 0.47)

    static let gradientPrimary = LinearGradient(
        colors: [primaryGreen, darkGreen],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let gradientPremium = LinearGradient(
        colors: [Color(red: 0.15, green: 0.45, blue: 0.30), Color(red: 0.08, green: 0.28, blue: 0.18)],
        startPoint: .top,
        endPoint: .bottom
    )
}

struct PremiumCardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(PlantiumTheme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 4)
    }
}

extension View {
    func premiumCard() -> some View {
        modifier(PremiumCardStyle())
    }
}
