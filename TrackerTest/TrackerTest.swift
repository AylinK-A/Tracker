import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackersListSnapshotTests: XCTestCase {

    // Включаем только один раз, чтобы записать эталонные изображения
    private let isRecordingSnapshots = false

    override func setUp() {
        super.setUp()
        isRecording = isRecordingSnapshots
    }

    func test_mainScreen_light() {
        let vc = TrackersListViewController()
        let nav = UINavigationController(rootViewController: vc)

        nav.view.frame = CGRect(x: 0, y: 0, width: 375, height: 812)
        nav.view.layoutIfNeeded()

        assertSnapshot(
            matching: nav,
            as: .image(traits: UITraitCollection(userInterfaceStyle: .light))
        )
    }
    
    func test_mainScreen_dark() {
        let vc = TrackersListViewController()
        let nav = UINavigationController(rootViewController: vc)

        nav.view.frame = CGRect(x: 0, y: 0, width: 375, height: 812)
        nav.view.layoutIfNeeded()

        assertSnapshot(
            matching: nav,
            as: .image(traits: UITraitCollection(userInterfaceStyle: .dark))
        )
    }

}

