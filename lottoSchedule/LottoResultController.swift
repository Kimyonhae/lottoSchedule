//
//  LottoResultController.swift
//  lottoSchedule
//
//  Created by 김용해 on 7/3/25.
//

import Foundation
import UIKit

class LottoResultController: UIViewController {
    private var viewModel: LottoResultViewModel = .init()
    override func viewDidLoad() {
        super.viewDidLoad()
        // 기본 셋업
        UICommon.setUpGradientBackground(view: self.view) // 배경색
        setUpConfigure()
        // 당첨 결과 뷰
        setUpLottoResultConfigure()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // TODO: 기본 셋업
    private func setUpConfigure() {
        self.navigationItem.title = "로또 결과"
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeScreen))
    }
    
    // TODO: dismiss method
    @objc func closeScreen() {
        self.dismiss(animated: true)
    }
    // TODO: 당첨 결과 뷰
    private func setUpLottoResultConfigure() {
        
        let roundLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            label.text = "제 1168회"
            return label
        }()
        
        let rankLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            label.textAlignment = .right
            label.text = "1등"
            
            return label
        }()
        
        // 내부 stackView <- (label - label)
        let topStackView: UIStackView = {
            let stack = UIStackView(arrangedSubviews: [roundLabel, rankLabel])
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.spacing = 8
            stack.axis = .horizontal
            return stack
        }()
        
        // Divider
        let divider: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.systemGray4
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        // TODO: Lotto 숫자 각각 한개에 해당
        func getLottoNumber(num: Int) -> UILabel {
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
        
        // 하단 stackView (lotto - 6)
        let bottomStackView: UIStackView = {
            let stack = UIStackView(
                arrangedSubviews: [
                    getLottoNumber(num: 12),
                    getLottoNumber(num: 13),
                    getLottoNumber(num: 14),
                    getLottoNumber(num: 15),
                    getLottoNumber(num: 16),
                    getLottoNumber(num: 17),
                ]
            )
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.axis = .horizontal
            stack.spacing = 8
            stack.distribution = .equalCentering
            stack.alignment = .center
            
            return stack
        }()
        
        let containerView: UIStackView = {
            let stack = UIStackView(arrangedSubviews: [topStackView,divider,bottomStackView])
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.axis = .vertical
            stack.distribution = .fill
            stack.backgroundColor = .white
            stack.spacing = 8
            
            stack.layer.shadowColor = UIColor(hex: "676767").cgColor
            stack.layer.shadowOffset = CGSize(width: 0, height: 0)
            stack.layer.shadowOpacity = 0.25
            stack.layer.shadowRadius = 4
            stack.layer.cornerRadius = 12

            stack.isLayoutMarginsRelativeArrangement = true
            stack.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 8, right: 16)
            
            return stack
        }()
        
        self.view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            // container
            containerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            

            roundLabel.widthAnchor.constraint(equalTo: topStackView.widthAnchor, multiplier: 0.8),
            // divider
            divider.heightAnchor.constraint(equalToConstant: 1),
            
            //bottomStackView
            bottomStackView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            bottomStackView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
}


final class LottoResultViewModel: ObservableObject {
    var weekltyResult: [Lotto] // 현재 배열에 저장된 로또
    
    init() {
        self.weekltyResult = DataManager.shared.lottos
        if let firstRound = weekltyResult.first?.round {
            self.getLottoResult(round: Int(firstRound)) // Test
        }
        print("weekltyResult : \(weekltyResult)")
    }
    
    // TODO: 회차 별 결과를 가져오는
    func getLottoResult(round: Int) {
        let urlString: String = "https://www.dhlottery.co.kr/common.do?method=getLottoNumber&drwNo=\(round)"
        
        guard let url = URL(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: URLRequest(url: url)) { data, res, err in
            if let error = err {
                print("error 발생 : \(error)")
            }
            
            if let response = res as? HTTPURLResponse {
                switch response.statusCode {
                    case 200...399:
                        print("통신 성공 : \(response.statusCode)")
                        
                        // data가 성공적일 경우
                    if let data = data {
                        let decoder = JSONDecoder()
                        
                        do {
                            let lottoResult = try decoder.decode(LottoResult.self, from: data)
                            print(lottoResult)
                            self.compareLottoResults(result: lottoResult) // 결과 비교 함수
                        } catch {
                            print("json parsing 실패 : \(error)")
                        }
                    }
                    case 400...599:
                        print("통신 실패 : \(response.statusCode)")
                        return
                    default:
                        print("통신 실패 : \(response.statusCode)")
                        return
                }
            }
        }
        task.resume()
    }
    
    // TODO: 로또 결과를 통해 현재 내 로또들의 당첨 여부를 확인 함수
    func compareLottoResults(result: LottoResult) {
        // success 가 아니라면 아직 결과가 나오지 않은 회차
        guard result.returnValue == "success" else { return }
        guard let drwNo = result.drwNo else { return } // 회차 번호
        guard let bnusNo = result.bnusNo, result.bnusNo != nil else { return } // 보너스 숫자
        let equalsLottos = self.weekltyResult.filter { $0.round == drwNo }
        let winnerNumbers: Set<Int> = Set([ // 당첨 Set
            result.drwtNo1,result.drwtNo2,result.drwtNo3,
            result.drwtNo4,result.drwtNo5,result.drwtNo6
        ].compactMap{ $0 })
        
        equalsLottos.forEach { lotto in
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
            
            print("로또 번호 \(lottoSet), 당첨 번호 : \(matchLotto), 당첨 개수 : \(rank)")
        }
    }
}
