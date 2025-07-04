//
//  LottoResult.swift
//  lottoSchedule
//
//  Created by 김용해 on 7/4/25.
//

import Foundation

class LottoResult: Codable {
    let returnValue: String          // Api 결과
    let drwNo: Int?                  // 회차 번호
    let drwNoDate: String?           // 당첨 날짜
    let drwtNo1: Int?                // 당첨번호 1
    let drwtNo2: Int?                // 당첨번호 2
    let drwtNo3: Int?                // 당첨번호 3
    let drwtNo4: Int?                // 당첨번호 4
    let drwtNo5: Int?                // 당첨번호 5
    let drwtNo6: Int?                // 당첨번호 6
    let bnusNo: Int?                 // 보너스 당첨번호
}
                        
