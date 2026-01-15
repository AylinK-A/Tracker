import UIKit
import AppMetricaCore

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {

        let configuration = AppMetricaConfiguration(apiKey: "3450d637-ebb3-4911-87bf-1a069c5e17b0")
        AppMetrica.activate(with: configuration!)

        return true
    }
}

