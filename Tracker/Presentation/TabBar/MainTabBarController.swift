import UIKit

final class MainTabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        buildTabBarControllers()
        setupUI()
    }

    private func setupUI() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .ypWhite
        appearance.shadowColor = .separator

        appearance.stackedLayoutAppearance.selected.iconColor = .ypBlue
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.ypBlue]

        appearance.stackedLayoutAppearance.normal.iconColor = .ypGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.ypGray]

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }

    private func buildTabBarControllers() {
        // Трекеры
        let trackersListVC = TrackersListViewController()
        let trackersNav = UINavigationController(rootViewController: trackersListVC)
        trackersNav.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tab_trackers", comment: ""),
            image: UIImage(resource: .tabBarTrackers),
            selectedImage: nil
        )

        // Статистика
        let statisticsVC = StatisticsViewController()
        let statisticsNav = UINavigationController(rootViewController: statisticsVC)
        statisticsNav.tabBarItem = UITabBarItem(
            title: NSLocalizedString("tab_statistics", comment: ""),
            image: UIImage(resource: .tabBarStats),
            selectedImage: nil
        )

        viewControllers = [trackersNav, statisticsNav]
    }
}

