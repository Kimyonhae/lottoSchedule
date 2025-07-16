//
//  LottoResultCellView.swift
//  lottoSchedule
//
//  Created by 김용해 on 7/4/25.
//

import Foundation


import UIKit

final class LottoNumberCell: UITableViewCell {
    static let reuseIdentifier = "LottoNumberCell"

    private let stackView = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupStackView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setupStackView() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.distribution = .equalSpacing

        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }

    func configure(with numbers: [Int], rank: String, matchedNumbers: Set<Int>) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        numbers.forEach { number in
            let numberView = UICommon.getResultLottoNumber(num: number, matchedNumbers: matchedNumbers)
            stackView.addArrangedSubview(numberView)
        }

        let rankLabel = UILabel()
        rankLabel.text = rank
        rankLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        rankLabel.textColor = .darkGray
        rankLabel.textAlignment = .right
        stackView.addArrangedSubview(rankLabel)
    }
}
