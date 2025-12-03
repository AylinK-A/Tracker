import UIKit

final class ScheduleCell: UITableViewCell {
    
    // MARK: - Identifier
    
    static let reuseID = "ScheduleCellReuseIdentifier"
    
    // MARK: - Delegate
    
    weak var delegate: ScheduleCellDelegate?
    
    // MARK: - Views
    
    private lazy var hStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, UIView(), daySwitch])
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.alignment = .center
        stackView.distribution = .fill
        return stackView
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypBackground
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .ypBlack
        return label
    }()
    
    private lazy var daySwitch: UISwitch = {
        let toggler = UISwitch()
        toggler.isOn = false
        toggler.onTintColor = .ypBlue
        return toggler
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .ypGray
        return view
    }()
    
    // MARK: - Private Properties
    
    private var cellWeekday: Weekday?
    
    // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super .init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        selectionStyle = .none
        contentView.addSubview(containerView)
        containerView.addSubviews([
            hStackView,
            separatorView
        ])
        
        setupConstraints()
        setupActions()
    }
    
    private func setupConstraints() {
        [
            hStackView,
            containerView,
            titleLabel,
            daySwitch,
            separatorView
        ].disableAutoresizingMasks()
        
        NSLayoutConstraint.activate([
            daySwitch.widthAnchor.constraint(equalToConstant: 51),
            daySwitch.heightAnchor.constraint(equalToConstant: 31),
            
            hStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            hStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            hStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            containerView.heightAnchor.constraint(equalToConstant: 75),
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            separatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    // MARK: - Setup Actions
    
    private func setupActions() {
        daySwitch.addTarget(self, action: #selector(daySwitchChanged), for: .valueChanged)
    }
    
    // MARK: - Actions
    
    @objc private func daySwitchChanged() {
        guard let day = cellWeekday else { return }
        delegate?.weekdayInCell(day: day, isIncluded: daySwitch.isOn)
    }
    
    // MARK: - Public Methods
    
    func configure(weekday: Weekday, isFirst: Bool, isLast: Bool) {
        cellWeekday = weekday
        titleLabel.text = weekday.longString
        
        if isFirst {
            containerView.layer.cornerRadius = 16
            containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        }
        if isLast {
            containerView.layer.cornerRadius = 16
            containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            separatorView.isHidden = true
        }
    }
    
}
