import UIKit

final class MainTabBarController: UITabBarController {
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        buildTabBarControllers()
        setupUI()
    }
    
    // MARK: - Setup UI
    
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
    
    // MARK: - Private Methods
    
    private func buildTabBarControllers() {
        let trackersListVC = TrackersListViewController()
        let trackersNavigationVC = UINavigationController(rootViewController: trackersListVC)
        trackersNavigationVC.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(resource: .tabBarTrackers),
            selectedImage: nil
        )
        
        let statisticsVC = StatisticsViewController()
        statisticsVC.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(resource: .tabBarStats),
            selectedImage: nil
        )
        
        viewControllers = [trackersNavigationVC, statisticsVC]
    }
    
}
