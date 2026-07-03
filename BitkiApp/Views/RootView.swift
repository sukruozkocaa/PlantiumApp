import SwiftUI
import SwiftData

struct RootView: View {
    @State private var appState = AppState()

    var body: some View {
        Group {
            switch appState.phase {
            case .splash:
                SplashView {
                    appState.finishSplash()
                }
                .transition(.opacity)

            case .onboarding:
                OnboardingView {
                    appState.completeOnboarding()
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))

            case .main:
                HomeView()
                    .transition(.identity)
            }
        }
        .animation(.easeInOut(duration: 0.5), value: appState.phase)
    }
}

#Preview {
    RootView()
        .modelContainer(for: Plant.self, inMemory: true)
}
