//
//  ViewController.swift
//  lottoSchedule
//
//  Created by 김용해 on 6/28/25.
//

import UIKit

class MainController: UIViewController {
    private let tableView = UITableView()
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false) // 기존 AppBar Remove
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 초기 lottos 가져오기
        DataManager.shared.updateLottos()
        // Gradient 배경 설정
        UICommon.setUpGradientBackground(view: self.view)
        // 상단 AppBar Navigation
        setUpAppBarNavigation()
        // 중단 TableView lottos
        setUpLottoItems()
        // 하단 Scanner 버튼
        setUpScannerButton()
        if FirstRunCheck.shared.isFirstRun { // first excute!
            let firstVC = FirstRunController()
            firstVC.modalPresentationStyle = .fullScreen
            self.present(firstVC, animated: true)
        }
    }
    
    // TODO: 상단 AppBar Navigation (tag: 1001)
    private func setUpAppBarNavigation() {
        let titleView: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "로또 모음"
            label.font = .systemFont(ofSize: 24, weight: .bold)
            return label
        }()
        
        /// 상단 AppBar 검색과 더 보기 View 함수
        /// - parameters:
        ///  - iconName: icon Symbol Name
        ///  - action: closer Method for touchUpInside
        func getTopbarButton(iconName: String, action: UIAction) -> UIButton {
            let btn = UIButton()
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.widthAnchor.constraint(equalToConstant: 48).isActive = true
            btn.heightAnchor.constraint(equalToConstant: 48).isActive = true
            btn.addAction(action, for: .touchUpInside)
            
            var config = UIButton.Configuration.plain()
            config.image = UIImage(systemName: iconName)
            config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
            btn.configuration = config
            
            return btn
        }
        
        let appBarNavigation: UIStackView = {
            let bar = UIStackView(arrangedSubviews: [
                titleView,
                getTopbarButton(iconName: "magnifyingglass.circle.fill", action: UIAction { _ in
                    print("hello Search!!!")
                }),
                getTopbarButton(iconName: "ellipsis.circle.fill", action: UIAction { _ in
                    print("hello Dot Dot Dot!!")
                }),
            ])
            bar.translatesAutoresizingMaskIntoConstraints = false
            bar.axis = .horizontal
            bar.distribution = .fillProportionally
            bar.tag = 1001
            bar.alignment = .center
            
            return bar
        }()
        
        
        
        self.view.addSubview(appBarNavigation)
        
        NSLayoutConstraint.activate([
            appBarNavigation.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            appBarNavigation.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
            appBarNavigation.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
        ])
    }
    // TODO: 중단 TableView lottos
    private func setUpLottoItems() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(LottoCellView.self, forCellReuseIdentifier: LottoCellView.identifier)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        
        self.view.addSubview(tableView)
        
        if let appBar = self.view.viewWithTag(1001) as? UIStackView {
            NSLayoutConstraint.activate([
                tableView.topAnchor.constraint(equalTo: appBar.bottomAnchor, constant: 10),
                tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15),
                tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15),
                tableView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -100)
            ])
        }
    }
    // TODO: 하단 Scanner 버튼
    private func setUpScannerButton() {
        let buttonWidth: CGFloat = 80
        let scanner: UIButton = {
            let button = UIButton(type: .system)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.backgroundColor = .white
            button.layer.cornerRadius = buttonWidth / 2
            
            button.layer.shadowColor = UIColor(hex: "676767").cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.layer.shadowOpacity = 0.25
            button.layer.shadowRadius = 4
//            button.layer.masksToBounds = false
            
            var config = UIButton.Configuration.plain()
            config.image = UIImage(systemName: "barcode.viewfinder")
            
            config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 32, weight: .regular)
            button.configuration = config
            
            // Touch Action
            button.addAction(UIAction {[weak self] _ in
                guard let self = self else { return }
                let scannerVC = UINavigationController(rootViewController: ScannerViewController())
                scannerVC.modalPresentationStyle = .fullScreen
                self.present(scannerVC, animated: true)
                
            }, for: .touchUpInside)
            
            return button
        }()
        
        self.view.addSubview(scanner)
        
        NSLayoutConstraint.activate([
            scanner.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 20),
            scanner.widthAnchor.constraint(equalToConstant: buttonWidth),
            scanner.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            scanner.heightAnchor.constraint(equalToConstant: buttonWidth)
        ])
    }
}

// 의존 분리를 위한 Delegate
protocol LottoCellViewDelegate: AnyObject {
    func didTapPopButton(sourceView: UIView, lotto: Lotto)
}

// 의존 분리 reloadData를 통해 TableView를 업데이트
protocol PopOverContentViewControllerDelegate: AnyObject {
    func didTapDeleteButton(lotto: Lotto)
}

extension MainController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let lottos = DataManager.shared.lottos
        return lottos.isEmpty ? 0 : lottos.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "이번주"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let lottos = DataManager.shared.lottos
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LottoCellView.identifier, for: indexPath) as? LottoCellView else {
            return UITableViewCell()
        }
        
        cell.backgroundColor = .clear
        cell.selectionStyle = .none
        cell.delegate = self
        
        if !lottos.isEmpty {
            let lotto = lottos[indexPath.row]
            cell.configure(with: lotto)
        }
        return cell
    }
}

// PopOver 구현부
extension MainController: LottoCellViewDelegate {
    func didTapPopButton(sourceView: UIView, lotto: Lotto) {
        let popVC = PopOverContentViewController(lotto: lotto)
        popVC.modalPresentationStyle = .popover
        popVC.preferredContentSize = CGSize(width: 180, height: 100)
        popVC.delegate = self
        
        if let popOverController = popVC.popoverPresentationController {
            popOverController.sourceView = sourceView
            popOverController.sourceRect = sourceView.bounds
            popOverController.permittedArrowDirections = .up
            popOverController.delegate = self
        }
        present(popVC, animated: true)
    }
}

extension MainController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

// PopOver delete method 구현부
extension MainController: PopOverContentViewControllerDelegate {
    func didTapDeleteButton(lotto: Lotto) {
        DataManager.shared.deleteLotto(lotto: lotto)
        DataManager.shared.updateLottos()
        tableView.reloadData()
    }
}
