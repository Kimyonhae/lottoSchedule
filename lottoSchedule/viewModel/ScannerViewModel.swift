    //
//  ScannerViewModel.swift
//  lottoSchedule
//
//  Created by 김용해 on 7/2/25.
//

import Foundation
import SwiftSoup

enum ScannerNetworkError: Error {
    case offline
    case timeout
    case invalidURL
    case secureConnectionFailed
    case invaildQRScanResult
    case unknown(Error)

    var userMessage: String {
        switch self {
        case .offline:
            return "인터넷에 연결되어 있지 않습니다."
        case .timeout:
            return "요청 시간이 초과되었습니다."
        case .invalidURL:
            return "잘못된 요청입니다."
        case .secureConnectionFailed:
            return "보안 연결에 실패했습니다."
        case .invaildQRScanResult:
            return "로또 QR 만 스캔 가능합니다."
        case .unknown:
            return "개발자에게 문의 해주세요"
        }
    }
}

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
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, _, error in
                
            if let err = error as NSError? {
                let networkError: ScannerNetworkError
                switch err.code {
                case NSURLErrorNotConnectedToInternet:
                    networkError = .offline
                case NSURLErrorTimedOut:
                    networkError = .timeout
                case NSURLErrorUnsupportedURL, NSURLErrorBadURL:
                    networkError = .invalidURL
                default:
                    if err.domain == NSURLErrorDomain {
                        networkError = .invaildQRScanResult
                    }else {
                        networkError = .unknown(err)
                    }
                }

                DispatchQueue.main.async {
                    self.scannerDelegate?.scannerDidFail(with: networkError)
                }
                return
            }
            
            guard let data = data else {
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
                let lottoResult = try doc.select("td.result").text() // 결과 있으면 string 없으면 ""
                
                // 필터링 - 미추첨 복권만 CoreData에 등록
//                if !lottoResult.isEmpty {
//                    #if DEBUG
//                        print("현 시점 미추첨 복권이 아닙니다")
//                    #endif
//                    self.scannerDelegate.scannerNotAvailableLotto()
//                    return
//                }
                
                // { 필터링 [6개] , 회차 수 }를 가진 타입으로 변환
                let chunkedList = stride(from: 0, to: numbers.count, by: 6).map {
                    Array(numbers[$0..<min($0 + 6 , numbers.count)])
                }
                
                chunkedList.forEach { numbers in
                    let integerNumbers: [Int] = numbers.map { Int($0)! } // 형변환
                    self.scannerDelegate.scannerCompletion(with: integerNumbers, round: round)
                }
                
            }catch {
                #if DEBUG
                    print("error : \(error)")
                #endif
            }
        }
        
        task.resume()
    }
}

// TODO: Scanner delegate 패턴
protocol ScannerViewDelegate: AnyObject {
    // 6개의 숫자를 coreData 저장 전 ScannerViewController랑 역활을 분리
    func scannerCompletion(with lotto: [Int], round: String)
    // 미추첨 복권이 아닌경우 필터링 함수
    func scannerNotAvailableLotto()
    // 네트워크 Error 대응 
    func scannerDidFail(with error: ScannerNetworkError)
}
