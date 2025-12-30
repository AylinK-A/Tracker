import Foundation

enum OnboardingStorage {
    private static let key = "onboardingFinished"

    static var isFinished: Bool {
        get { UserDefaults.standard.bool(forKey: key) }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}

