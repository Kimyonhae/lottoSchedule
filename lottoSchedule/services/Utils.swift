//
//  Utils.swift
//  lottoSchedule
//
//  Created by 김용해 on 6/28/25.
//

import UIKit

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let r = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let g = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let b = CGFloat(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b, alpha: 1.0)
    }
    
    static func getLottoColor(for num: Int) -> UIColor {
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
