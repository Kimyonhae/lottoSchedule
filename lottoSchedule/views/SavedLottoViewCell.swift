//
//  SavedLottoViewCell.swift
//  lottoSchedule
//
//  Created by 김용해 on 7/6/25.
//
import UIKit

final class SavedLottoViewCell: UITableViewCell {
    static let reuseIdentifier = "SavedLottoCell"

    // bottom
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        
        return stackView
    }()
    
    // TODO: 로또 결과 box
    let container: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fill
        stack.backgroundColor = .white
        stack.spacing = 8
        
        stack.layer.shadowColor = UIColor(hex: "676767").cgColor
        stack.layer.shadowOffset = CGSize(width: 0, height: 0)
        stack.layer.shadowOpacity = 0.25
        stack.layer.shadowRadius = 4
        stack.layer.cornerRadius = 12
        
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        
        return stack
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        setupStackView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
        
    private func setupStackView() {
        container.addArrangedSubview(stackView)
        self.contentView.addSubview(container)
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 7),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -7),
        ])
    }

    func configure(numbers: [Int], rank: String) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let rowStack = UIStackView()
        rowStack.axis = .horizontal
        rowStack.spacing = 8
        rowStack.alignment = .center
        rowStack.distribution = .equalSpacing
        rowStack.translatesAutoresizingMaskIntoConstraints = false

        numbers.forEach { number in
            let numberView = UICommon.getLottoNumber(num: number)
            rowStack.addArrangedSubview(numberView)
        }

        let rankLabel = UILabel()
        rankLabel.text = rank
        rankLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        rankLabel.textColor = .darkGray
        rankLabel.textAlignment = .right

        rowStack.addArrangedSubview(rankLabel)
        stackView.addArrangedSubview(rowStack)
    }
    
    override func prepareForReuse() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
    }
}
