//
//  LottoResultController.swift
//  lottoSchedule
//
//  Created by 김용해 on 7/3/25.
//
// topContainerStackView tag: 20001
import Foundation
import UIKit

class LottoResultController: UIViewController {
    private var viewModel: LottoResultViewModel
    
    init(viewModel: LottoResultViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // TODO: 로또 결과 box
    lazy var containerView: UIStackView = {
        let stack = UIStackView()
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
    
    // TODO: 회차 UILabel
    let roundLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.text = "제 0000회"
        return label
    }()
    
    // TODO: 하단 저장 버튼
    lazy var saveButton: UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setTitle("저장", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        btn.backgroundColor = UIColor(hex: "D44853")
        btn.layer.cornerRadius = 14
        return btn
    }()
    
    // TODO: 하단 DateLabel
    let dateLabel: UILabel = {
        let date = UILabel()
        date.translatesAutoresizingMaskIntoConstraints = false
        date.text = "잠시 기다려주세요..."
        date.tintColor = UIColor(hex: "AAAAAA")
        date.font = .systemFont(ofSize: 14, weight: .semibold)
        
        return date
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 뷰가 보이기 전 클로저를 전달하기
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel.responseFailed = { [weak self] in
            DispatchQueue.main.async {
                self?.dismiss(animated: true)
            }
        }
        
        // 기본 셋업
        UICommon.setUpGradientBackground(view: self.view) // 배경색
        // navigation 제목 및 leftButton
        setUpConfigure()
        // 당첨 결과 뷰
        setUpLottoResultConfigure()
        // 첫번째 금액
        let (totSellamntLabel,totalMoney) = getLottoInfo(title: "전체 금액", money: "...", superview: containerView)
        // 2번재 금액
        let (firstAccumamntLabel ,firstAccumamnt) = getLottoInfo(title: "1등 총 당첨 금액", money: "...", superview: totalMoney)
        // 3번재 금액
        let (firstWinamnt,_) = getLottoInfo(title: "1인당 1등 당첨 금액", money: "...", superview: firstAccumamnt)
        // 버튼 뷰
        setUpButton()
        // date 정보
        setUpDateView()
        // 값 바인딩
        guard let lottoResultInfo = self.viewModel.lottoResultInfo else { return }
        self.roundLabel.text = "제 \(lottoResultInfo.round)회"
        totSellamntLabel.text = String.formatCurrency(lottoResultInfo.totSellamnt)
        firstAccumamntLabel.text = String.formatCurrency(lottoResultInfo.firstAccumamnt)
        firstWinamnt.text = String.formatCurrency(lottoResultInfo.firstWinamnt)
        self.dateLabel.text = "\(Date.dateResultFormatter(with: lottoResultInfo.date)) 추첨되었습니다"
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
        let descriptionLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = UIColor(hex: "D44853")
            label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            label.text = "스크롤 가능해요"
            label.textAlignment = .right
            
            return label
        }()
        
        // 내부 stackView <- (label - label)
        let topStackView: UIStackView = {
            let stack = UIStackView(arrangedSubviews: [roundLabel, descriptionLabel])
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
        
        // 하단 TableView (lotto - 6)
        lazy var lottoTableView: UITableView = {
            let tableView = UITableView()
            tableView.translatesAutoresizingMaskIntoConstraints = false
            tableView.separatorStyle = .none
            tableView.showsVerticalScrollIndicator = false
            tableView.register(LottoNumberCell.self, forCellReuseIdentifier: LottoNumberCell.reuseIdentifier)
            return tableView
        }()
        
        // viewModel ranks 뷰에 연결
        viewModel.onRankedUpdated = { _ in
            DispatchQueue.main.async {
                lottoTableView.reloadData() // 또는 lottoTableView.reloadData()
            }
        }
        
        lottoTableView.delegate = self
        lottoTableView.dataSource = self
        
        containerView.addArrangedSubview(topStackView)
        containerView.addArrangedSubview(divider)
        containerView.addArrangedSubview(lottoTableView)
        
        self.view.addSubview(containerView)
        
        NSLayoutConstraint.activate([
            // container
            containerView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            containerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            // topStackView
            roundLabel.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.5),
            // divider
            divider.heightAnchor.constraint(equalToConstant: 1),
            //bottomStackView
            lottoTableView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            lottoTableView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    // TODO: 금액 정보 뷰
    private func getLottoInfo(title: String, money: String, superview: UIView) -> (UILabel ,UIStackView) {
        let titleLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            label.text = title
            return label
        }()
        
        // Divider
        let divider: UIView = {
            let view = UIView()
            view.backgroundColor = UIColor.systemGray4
            view.translatesAutoresizingMaskIntoConstraints = false
            return view
        }()
        
        let moneyLabel: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            label.tintColor = UIColor(hex: "AAAAAA")
            label.text = money
            return label
        }()
        
        let infoContainer: UIStackView = {
            let stack = UIStackView()
            stack.translatesAutoresizingMaskIntoConstraints = false
            stack.axis = .vertical
            stack.distribution = .fillProportionally
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
        
        
        infoContainer.addArrangedSubview(titleLabel)
        infoContainer.addArrangedSubview(divider)
        infoContainer.addArrangedSubview(moneyLabel)
        
        self.view.addSubview(infoContainer)
        
        NSLayoutConstraint.activate([
            infoContainer.topAnchor.constraint(equalTo: superview.bottomAnchor, constant: 20),
            infoContainer.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            infoContainer.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            divider.heightAnchor.constraint(equalToConstant: 1),
        ])
        
        return (moneyLabel, infoContainer)
    }
    
    // TODO: 날짜 정보 뷰
    private func setUpDateView() {
        
        self.view.addSubview(dateLabel)
        NSLayoutConstraint.activate([
            dateLabel.bottomAnchor.constraint(equalTo: saveButton.topAnchor, constant: -10),
            dateLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            dateLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
        ])
    }
    
    // TODO: 저장 버튼
    private func setUpButton() {
        saveButton.addAction(UIAction { [weak self] _ in
            if let weekltyResult = self?.viewModel.weekltyResult,
               let lottoResultInfo = self?.viewModel.lottoResultInfo,
               let ranks = self?.viewModel.ranks {
                // 저장된 로또들
                SavedLottoDataManager.shared.createLotto(
                    weekltyResult: weekltyResult,
                    lottoResultInfo: lottoResultInfo,
                    ranks: ranks
                ) { result in
                    if result {
                        // 이번주 로또 지우기
                        LottoDataManager.shared.deleteAllLottos()
                        LottoDataManager.shared.updateLottos()
                    }
                    // 실패
                }
            }
            self?.dismiss(animated: true) // 닫기
        }, for: .touchUpInside)
        
        self.view.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            saveButton.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            saveButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            saveButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
            saveButton.heightAnchor.constraint(equalToConstant: 52)
        ])
    }
    
}

// LottoResult Cell View on delegate
extension LottoResultController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.weekltyResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LottoNumberCell.reuseIdentifier, for: indexPath) as? LottoNumberCell else { return UITableViewCell()
        }
        cell.selectionStyle = .none
        cell.configure(
            with: viewModel.weekltyResult[indexPath.row].numbers as! [Int],
            rank: indexPath.row < viewModel.ranks.count ? viewModel.ranks[indexPath.row] : "결과 없음"
        )
        
        return cell
    }
}
