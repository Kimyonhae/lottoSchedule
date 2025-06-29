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
}
