import UIKit

class LottoCellView: UITableViewCell {
    weak var delegate: LottoCellViewDelegate?
    static let identifier = "LottoCellView"
    var lotto: Lotto?
    private let numberStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .equalSpacing
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private let divider: UIView = {
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
        
        return label
    }()
    
    private lazy var lottoPopButton: UIButton = {
        // data list
        let menu = [
//            MenuItem(title: "수정하기", iconName: "pencil.circle", action: .update), 구현 시 활성화
            MenuItem(title: "삭제하기", iconName: "trash.circle", action: .delete)
        ]
        
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "ellipsis.circle.fill")
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular)
        btn.configuration = config
        btn.tintColor = UIColor(hex: "AAAAAA")
        btn.addAction(UIAction { [weak self] _ in
            guard let self = self else { return }
            if let lotto = self.lotto {
                self.delegate?.didTapPopButton(sourceView: btn, lotto: lotto, menu: menu)
            }
        }, for: .touchUpInside)
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
        container.distribution = .fill
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
        container.addArrangedSubview(divider)
        
        bottomStackView.addArrangedSubview(dateLabel)
        bottomStackView.addArrangedSubview(lottoPopButton)
        
        container.addArrangedSubview(bottomStackView)
        
        contentView.addSubview(container)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 4),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -4),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            divider.heightAnchor.constraint(equalToConstant: 1),
        ])
    }

    func configure(with lotto: Lotto) {
        self.lotto = lotto
        lotto.numbers?.forEach {
            numberStack.addArrangedSubview(UICommon.getLottoNumber(num: $0 as! Int))
        }
        getDateFormatter(date: lotto.date ?? .now)
    }
    
    //TODO: Date 포멧 함수
    private func getDateFormatter(date: Date) {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "M월 d일"
        
        let dateString = formatter.string(from: date)
        dateLabel.text = dateString
    }
    
    // 초기화
    override func prepareForReuse() {
        dateLabel.text = nil
        numberStack.subviews.forEach{ $0.removeFromSuperview() }
    }
}
