import UIKit

final class OnboardingPageViewController: UIPageViewController {

    // MARK: - Public
    var onFinish: (() -> Void)?

    // MARK: - Private
    private let pages: [OnboardingPageModel] = [
        OnboardingPageModel(
            backgroundImageName: "onbording2",
            title: "Отслеживайте только\nto, что хотите",
            buttonTitle: "Вот это технологии!"
        ),
        OnboardingPageModel(
            backgroundImageName: "onbording1", 
            title: "Даже если это\nне литры воды и йога",
            buttonTitle: "Вот это технологии!"
        )
    ]

    private lazy var controllers: [OnboardingContentViewController] = {
        pages.map { model in
            let vc = OnboardingContentViewController(model: model)
            vc.onButtonTap = { [weak self] in
                self?.finishOnboarding()
            }
            return vc
        }
    }()

    private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.translatesAutoresizingMaskIntoConstraints = false
        pc.currentPageIndicatorTintColor = .ypBlack
        pc.pageIndicatorTintColor = UIColor.ypBlack.withAlphaComponent(0.2)
        pc.isUserInteractionEnabled = false
        return pc
    }()

    // MARK: - Init
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        dataSource = self
        delegate = self

        setupPageControl()

        pageControl.numberOfPages = controllers.count
        pageControl.currentPage = 0

        if let first = controllers.first {
            setViewControllers([first], direction: .forward, animated: false)
        }
    }

    private func setupPageControl() {
        view.addSubview(pageControl)

        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -120)
        ])
    }

    private func finishOnboarding() {
        OnboardingStorage.isFinished = true
        onFinish?()
    }
}

// MARK: - UIPageViewControllerDataSource
extension OnboardingPageViewController: UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? OnboardingContentViewController,
              let index = controllers.firstIndex(where: { $0 === vc }) else { return nil }
        let prev = index - 1
        return prev >= 0 ? controllers[prev] : nil
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let vc = viewController as? OnboardingContentViewController,
              let index = controllers.firstIndex(where: { $0 === vc }) else { return nil }
        let next = index + 1
        return next < controllers.count ? controllers[next] : nil
    }
}

// MARK: - UIPageViewControllerDelegate
extension OnboardingPageViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        guard completed,
              let current = viewControllers?.first,
              let index = controllers.firstIndex(where: { $0 === current }) else { return }
        pageControl.currentPage = index
    }
}

