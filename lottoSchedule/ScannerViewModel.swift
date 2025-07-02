//
//  ScannerViewModel.swift
//  lottoSchedule
//
//  Created by 김용해 on 7/2/25.
//

import Foundation
import SwiftSoup

/// **ScannerViewController의 viewModel**
/// - Parameter :
///     - scanResult: 로또 URL
///     - hasLottoValue: 뷰 분기처리를 위한 상태 값

class ScannerViewModel: ObservableObject {
    @Published var scanResult: String?
    weak var scannerDelegate: ScannerViewDelegate!
    func fetchCrawlingData() {
        
        guard let raw = scanResult,
        let value = raw.components(separatedBy: "?v=").last else { return }

        let finalURLString = "https://m.dhlottery.co.kr/qr.do?method=winQr&v=\(value)"
        guard let url = URL(string: finalURLString) else { return }
        print(url)
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
                
            if let err = error {
                print("error : \(err)")
                return
            }
            
            guard let data = data else {
                print("HTML data parsing 실패")
                return
            }
            
            var html: String? {
                let cfEncoding = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.EUC_KR.rawValue))
                
                return String(data: data, encoding: .init(rawValue: cfEncoding))
            }
            
            do {
                guard let html = html else { return }
                let doc: Document = try SwiftSoup.parse(html)
                let elements = try doc.select("span.clr")
                
                let round = try doc.select("span.key_clr1").text() // 회차 number
                let numbers = try elements.map { try $0.text() }
                
                // { 필터링 [6개] , 회차 수 }를 가진 타입으로 변환
                let chunkedList = stride(from: 0, to: numbers.count, by: 6).map {
                    Array(numbers[$0..<min($0 + 6 , numbers.count)])
                }
                
                chunkedList.forEach { numbers in
                    let integerNumbers: [Int] = numbers.map { Int($0)! } // 형변환
                    self.scannerDelegate.scannerCompletion(with: integerNumbers, round: round)
                }
                
            }catch {
                print("error : \(error)")
            }
        }
        
        task.resume()
    }
}

// TODO: Scanner delegate 패턴
protocol ScannerViewDelegate: AnyObject {
    // 6개의 숫자를 coreData 저장 전 ScannerViewController랑 역활을 분리
    func scannerCompletion(with lotto: [Int], round: String)
}
