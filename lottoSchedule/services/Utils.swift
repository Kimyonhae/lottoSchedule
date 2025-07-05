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

extension String {
    // Int -> 화폐 가치 형변환
    static func formatCurrency(_ amount: Int) -> String {
        let eok = amount / 100000000
        let man = (amount % 100000000) / 10000
        let won = amount % 10000
        
        var components: [String] = []
        if eok > 0 {
            components.append("\(eok)억")
        }
        if man > 0 {
            components.append("\(man)만")
        }
        if won > 0 {
            components.append("\(won)원")
        }
        
        // 아무것도 없으면 "0원"
        return components.isEmpty ? "0원" : components.joined(separator: " ")
    }
}


extension Date {
    static func dateResultFormatter(with dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-M-d"

        let outputFormatter = DateFormatter()
        outputFormatter.locale = Locale(identifier: "ko_KR")
        outputFormatter.dateFormat = "yyyy년 M월 d일"

        if let date = inputFormatter.date(from: dateString) {
            return outputFormatter.string(from: date)
        } else {
            return dateString
        }
    }
}
