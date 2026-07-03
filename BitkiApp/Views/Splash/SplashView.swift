import SwiftUI

struct SplashView: View {
    let onFinished: () -> Void

    @State private var logoScale: CGFloat = 0.3
    @State private var logoOpacity: Double = 0
    @State private var titleOffset: CGFloat = 30
    @State private var subtitleOpacity: Double = 0
    @State private var leafRotation: Double = -20
    @State private var glowScale: CGFloat = 0.5

    var body: some View {
        ZStack {
            PlantiumTheme.gradientPremium
                .ignoresSafeArea()

            Circle()
                .fill(PlantiumTheme.accentGold.opacity(0.15))
                .frame(width: 280, height: 280)
                .scaleEffect(glowScale)
                .blur(radius: 40)

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 120, height: 120)

                    Image(systemName: "leaf.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(.white)
                        .rotationEffect(.degrees(leafRotation))
                        .scaleEffect(logoScale)
                        .opacity(logoOpacity)
                }

                VStack(spacing: 8) {
                    Text("Plantium")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .offset(y: titleOffset)
                        .opacity(logoOpacity)

                    Text("Bitkilerinizi Akıllıca Takip Edin")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                        .opacity(subtitleOpacity)
                }
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                logoScale = 1.0
                logoOpacity = 1.0
                titleOffset = 0
                leafRotation = 0
                glowScale = 1.2
            }

            withAnimation(.easeOut(duration: 0.6).delay(0.4)) {
                subtitleOpacity = 1.0
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.4)) {
                    onFinished()
                }
            }
        }
    }
}

#Preview {
    SplashView(onFinished: {})
}
