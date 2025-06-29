import UIKit

class LottoCellView: UITableViewCell {
    static let identifier = "LottoCellView"

    private let numberStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let separator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemGray4
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.tintColor = UIColor(hex: "AAAAAA")
        label.text = "2025 6월 29일"
        
        return label
    }()
    
    private let lottoPopButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "ellipsis.circle.fill")
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        btn.configuration = config
        btn.tintColor = UIColor(hex: "AAAAAA")
        btn.widthAnchor.constraint(equalToConstant: 20).isActive = true
        btn.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        return btn
    }()
    
    private let bottomStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.distribution = .fillProportionally
        stack.alignment = .center
        
        return stack
    }()
    
    private let container: UIStackView = {
        let container = UIStackView()
        container.translatesAutoresizingMaskIntoConstraints = false
        container.axis = .vertical
        container.spacing = 8
        container.distribution = .fillProportionally
        container.backgroundColor = .white
        
        container.layer.shadowColor = UIColor(hex: "676767").cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 0)
        container.layer.shadowOpacity = 0.25
        container.layer.shadowRadius = 4
        container.layer.cornerRadius = 12
        
        
        container.isLayoutMarginsRelativeArrangement = true
        container.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 8, right: 16)
        
        return container
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpViews() {
        container.addArrangedSubview(numberStack)
        container.addArrangedSubview(separator)
        
        bottomStackView.addArrangedSubview(dateLabel)
        bottomStackView.addArrangedSubview(lottoPopButton)
        
        container.addArrangedSubview(bottomStackView)
        
        contentView.addSubview(container)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            numberStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 8),
            
            separator.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            separator.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            separator.heightAnchor.constraint(equalToConstant: 1),
            
            bottomStackView.topAnchor.constraint(equalTo: separator.bottomAnchor, constant: 8),
            bottomStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor , constant: 8),
            bottomStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
        ])
    }

    func configure(numbers: [Int], date: String) {
        numberStack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let allNumbers = numbers
        for (index, num) in allNumbers.enumerated() {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "\(num)"
            label.textAlignment = .center
            label.font = .boldSystemFont(ofSize: 14)
            label.textColor = .white
            label.layer.cornerRadius = 20
            label.clipsToBounds = true
            label.widthAnchor.constraint(equalToConstant: 40).isActive = true
            label.heightAnchor.constraint(equalToConstant: 40).isActive = true

            if index < 6 {
                label.backgroundColor = getLottoColor(for: num)
            }

            numberStack.addArrangedSubview(label)
        }
    }

    private func getLottoColor(for num: Int) -> UIColor {
        switch num {
        case 1...10:
            return UIColor.systemYellow
        case 11...20:
            return UIColor.systemBlue
        case 21...30:
            return UIColor.systemGreen
        case 31...40:
            return UIColor.systemTeal
        default:
            return UIColor.systemIndigo
        }
    }
}
