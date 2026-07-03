import SwiftUI

enum AppPhase {
    case splash
    case onboarding
    case main
}

@MainActor
@Observable
final class AppState {
    var phase: AppPhase = .splash
    var hasCompletedOnboarding: Bool {
        get { UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") }
        set { UserDefaults.standard.set(newValue, forKey: "hasCompletedOnboarding") }
    }

    func finishSplash() {
        phase = hasCompletedOnboarding ? .main : .onboarding
    }

    func completeOnboarding() {
        hasCompletedOnboarding = true
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            phase = .main
        }
    }
}
