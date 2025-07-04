//
//  UICommon.swift
//  lottoSchedule
//
//  Created by 김용해 on 6/29/25.
//

import UIKit

class UICommon {
    // TODO: Grandient 배경 설정
    static func setUpGradientBackground(view: UIView) {
        view.backgroundColor = .clear
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [
            UIColor(hex: "FAE6E6").cgColor,
            UIColor.white.cgColor,
            UIColor(hex: "FAE6E6").cgColor,
        ]
        
        // 영역
        gradientLayer.locations = [
            NSNumber(value: 0.0),
            NSNumber(value: 0.2),
            NSNumber(value: 0.9),
            NSNumber(value: 1.0)
        ]
        
        // 방향 설정 (top → bottom)
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        // 뷰에 추가
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // TODO: Lotto 숫자 각각 한개에 해당
    static func getLottoNumber(num: Int) -> UILabel {
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
        label.backgroundColor = UIColor.getLottoColor(for: num)
        return label
    }
}
