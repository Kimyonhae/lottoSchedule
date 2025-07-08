//
//  LottoResultViewModel.swift
//  lottoSchedule
//
//  Created by 김용해 on 7/4/25.
//

import Foundation

struct LottoResultInfo {
    var round: Int              // 이번 회차
    var date: String            // 추첨 날짜
    var totSellamnt: Int        // 전체 금액
    var firstAccumamnt: Int     // 1등 총 당첨 금액
    var firstWinamnt: Int       // 1 인당 당첨 금액
}

enum LottoResultError: Error {
    case networkError
    case dataDecodingError
    case invaildResponse
}

final class LottoResultViewModel {
    var weekltyResult: [Lotto] // 현재 배열에 저장된 로또
    var ranks: [String] = []
    var lottoResultInfo: LottoResultInfo?
    var onLottoResultInfoUpdated: (() -> Void)? // LottoResultInfo를 뷰에 업데이트 하기 위한 클로저
    var onRankedUpdated: (([String]) -> Void)? // rank를 뷰에 업데이트 하기 위한 클로저
    var responseFailed: (() -> Void)?
    
    init() {
        self.weekltyResult = LottoDataManager.shared.lottos
    }
    
    // TODO: 회차 별 결과를 가져오는
    func getLottoResult(round: Int, completion: @escaping (Bool, LottoResultError?) -> Void) {
        let urlString: String =
        "https://www.dhlottery.co.kr/common.do?method=getLottoNumber&drwNo=\(round)"
        
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, res, err in
            if let error = err {
                #if DEBUG
                    print("Error : \(error)")
                #endif
                completion(false, .networkError)
            }
            
            if let response = res as? HTTPURLResponse {
                switch response.statusCode {
                    case 200...399:
                        // data가 성공적일 경우
                    if let data = data {
                        let decoder = JSONDecoder()
                        
                        do {
                            let lottoResult = try decoder.decode(LottoResult.self, from: data)
                            self.compareLottoResults(result: lottoResult){ res in // 결과 비교 함수
                                completion(res, .invaildResponse)
                            }
                        } catch {
                            completion(false, .dataDecodingError)
                        }
                    }
                    case 400...599:
                        completion(false, .networkError)
                        return
                    default:
                        completion(false, .networkError)
                        return
                }
            }
        }
        task.resume()
    }
    
    // TODO: 로또 결과를 통해 현재 내 로또들의 당첨 여부를 확인 함수
    func compareLottoResults(result: LottoResult, completion: @escaping (Bool) -> Void) {
        // success 가 아니라면 아직 결과가 나오지 않은 회차
        guard result.returnValue == "success" else {                             // 가장 중요 API 성공 여부
            responseFailed?() // 클로저 전달
            completion(false)
            return
        }
        guard let drwNo = result.drwNo else { completion(false); return }                           // 회차 번호
        guard let drwNoDate = result.drwNoDate else { completion(false); return }                   // 추첨 날짜
        guard let totSellamnt = result.totSellamnt else { completion(false); return }               // 전체 금액
        guard let firstAccumamnt = result.firstAccumamnt else { completion(false); return }         // 1등 총 당첨 금액
        guard let firstWinamnt = result.firstWinamnt else { completion(false); return }             // 1인당 당첨 금액
        guard let bnusNo = result.bnusNo, result.bnusNo != nil else { completion(false); return }   // 보너스 숫자
        let equalLottos = self.weekltyResult.filter { $0.round == drwNo }
        let winnerNumbers: Set<Int> = Set([ // 당첨 Set
            result.drwtNo1,result.drwtNo2,result.drwtNo3,
            result.drwtNo4,result.drwtNo5,result.drwtNo6
        ].compactMap{ $0 })
                
        // data insert
        self.lottoResultInfo = LottoResultInfo(
            round: drwNo,
            date: drwNoDate,
            totSellamnt: totSellamnt,
            firstAccumamnt: firstAccumamnt,
            firstWinamnt: firstWinamnt
        )
        self.onLottoResultInfoUpdated?() // 콜백 실행
        
        // 같은 회차 그룹
        equalLottos.forEach { lotto in
            let lottoSet: Set<Int> = Set(lotto.numbers as! [Int])
            
            let matchLotto = lottoSet.intersection(winnerNumbers) // 공통 집합
            let hasBnus = lottoSet.contains(bnusNo)
            
            var rank: String {
                switch matchLotto.count {
                    case 6:
                        return "1등"
                    case 5:
                        return hasBnus ? "2등" : "3등"
                    case 4:
                        return "4등"
                    case 3:
                        return "5등"
                    default:
                        return "꽝"
                }
            }
            ranks.append(rank) // rank 추가
            #if DEBUG
                print("로또 번호 \(lottoSet), 당첨 번호 : \(matchLotto), 당첨 개수 : \(rank)")
            #endif
        }
        self.onRankedUpdated?(ranks)
        completion(true)
    }
}
