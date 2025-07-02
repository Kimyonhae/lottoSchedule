//
//  ScannerCellView.swift
//  lottoSchedule
//
//  Created by 김용해 on 7/2/25.
//

import UIKit

class ScannerCellView: UITableViewCell {
    static let identifier: String = "QRResultCell"
    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.distribution = .fill
        stack.backgroundColor = .white
        stack.layer.shadowColor = UIColor(hex: "676767").cgColor
        stack.layer.shadowOffset = CGSize(width: 0, height: 0)
        stack.layer.shadowOpacity = 0.25
        stack.layer.shadowRadius = 4
        stack.layer.cornerRadius = 12
        
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

        return stack
    }()
    
    private var numberLabels: [UILabel] = []
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupStackView()
        setupLabels()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupStackView()
        setupLabels()
    }
    
    private func setupStackView() {
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    private func setupLabels() {
        let spacerView: UIView = {
            let spacer = UIView()
            spacer.translatesAutoresizingMaskIntoConstraints = false
            return spacer
        }()
        for _ in 0..<6 {
            let label = UILabel()
            label.textAlignment = .center
            label.textColor = .white
            label.font = .boldSystemFont(ofSize: 16)
            label.layer.cornerRadius = 20
            label.clipsToBounds = true
            label.widthAnchor.constraint(equalToConstant: 40).isActive = true
            label.heightAnchor.constraint(equalToConstant: 40).isActive = true
            stackView.addArrangedSubview(label)
            numberLabels.append(label)
        }
        
        // 마지막에 공백 처리
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacerView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        stackView.addArrangedSubview(spacerView)
    }

    func configure(with numbers: [Int]) {
        let colors: [UIColor] = [.systemYellow, .systemBlue, .systemBlue, .systemGreen, .systemGreen, .systemRed]
        
        for (i, number) in numbers.enumerated() {
            guard i < numberLabels.count else { break }
            let label = numberLabels[i]
            label.text = "\(number)"
            label.backgroundColor = colors[i]
        }
    }
}
