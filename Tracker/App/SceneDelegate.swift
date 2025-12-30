import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)

        if OnboardingStorage.isFinished {
            window.rootViewController = MainTabBarController()
        } else {
            let onboardingVC = OnboardingPageViewController()
            onboardingVC.onFinish = { [weak self] in
                OnboardingStorage.isFinished = true
                self?.window?.rootViewController = MainTabBarController()
            }
            window.rootViewController = onboardingVC
        }

        self.window = window
        window.makeKeyAndVisible()
    }
}

