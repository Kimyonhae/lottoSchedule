//
//  ViewController.swift
//  lottoSchedule
//
//  Created by 김용해 on 6/28/25.
//

import UIKit

class MainController: UIViewController {
    private let tableView = UITableView()
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            appBarNavigation.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 10),
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
            button.addAction(UIAction { _ in
                print("Scanner Button Clicked!!")
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

extension MainController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LottoCellView.identifier, for: indexPath) as? LottoCellView else {
            return UITableViewCell()
        }
        let numbers = [1, 23, 43, 34, 11, 8]
        cell.configure(numbers: numbers, date: "6월 27일 금요일")
        return cell
    }
}
