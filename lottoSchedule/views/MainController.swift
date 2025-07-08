//
//  ViewController.swift
//  lottoSchedule
//
//  Created by 김용해 on 6/28/25.
//

import UIKit
import AVFoundation

class MainController: UIViewController {
    private let tableView = UITableView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false) // 기존 AppBar Remove
        tableView.reloadData() // dismiss로 돌아올때 tableView 업데이트
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 알림 권한 - Notification
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(enterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        // 초기 lottos 가져오기
        LottoDataManager.shared.updateLottos()
        // Gradient 배경 설정
        UICommon.setUpGradientBackground(view: self.view)
        // 상단 AppBar Navigation
        setUpAppBarNavigation()
        // 중단 TableView lottos
        setUpLottoItems()
        // 하단 Scanner 버튼
        setUpScannerButton()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !FirstRunCheck.shared.isFirstRun { // first excute!
            let firstVC = FirstRunController()
            firstVC.modalPresentationStyle = .fullScreen
            self.present(firstVC, animated: true)
        }
    }
    
    // selector - foreground 진입시 호출
    @objc func enterForeground() {
        LottoCheckNotification.shared.checkNoticePermission()
        // check Schdules
        LottoCheckNotification.shared.printAllScheduledNotifications()
    }
    
    // TODO: 상단 AppBar Navigation (tag: 1001)
    private func setUpAppBarNavigation() {
        /// 상단 AppBar 검색과 더 보기 View 함수
        /// - parameters:
        ///  - iconName: icon Symbol Name
        ///  - menu: popover menu array
        func getTopbarButton(iconName: String, menu: [MenuItem]? = nil) -> UIButton {
            let btn = UIButton()
            btn.translatesAutoresizingMaskIntoConstraints = false
            btn.widthAnchor.constraint(equalToConstant: 48).isActive = true
            btn.heightAnchor.constraint(equalToConstant: 48).isActive = true
            btn.tintColor = UIColor(hex: "AAAAAA")
            btn.addAction(UIAction {_ in
                if let menu = menu {
                    self.didTapPopButton(sourceView: btn, menu: menu)
                }
            }, for: .touchUpInside)
            
            var config = UIButton.Configuration.plain()
            config.image = UIImage(systemName: iconName)
            config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 24, weight: .regular)
            btn.configuration = config
            
            return btn
        }
        
        let titleView: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = "로또 모음"
            label.font = .systemFont(ofSize: 24, weight: .bold)
            return label
        }()
        
        // popover Button
        let moreButton = getTopbarButton(iconName: "ellipsis.circle.fill", menu: [
            MenuItem(title: "로또 결과", iconName: "square.and.pencil.circle", action: .destinationOnLottoResultController),
            MenuItem(title: "보관함", iconName: "folder.circle", action: .destinationOnSavedLottoController)
        ])
        
        let appBarNavigation: UIStackView = {
            let bar = UIStackView(arrangedSubviews: [
                titleView,
                getTopbarButton(iconName: "magnifyingglass.circle.fill"),
                moreButton
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
            button.tintColor = UIColor(hex: "D44853")
            
            button.layer.shadowColor = UIColor(hex: "676767").cgColor
            button.layer.shadowOffset = CGSize(width: 0, height: 2)
            button.layer.shadowOpacity = 0.25
            button.layer.shadowRadius = 4
            
            var config = UIButton.Configuration.plain()
            config.image = UIImage(systemName: "qrcode.viewfinder")
            
            config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 32, weight: .regular)
            button.configuration = config
            
            // Touch Action
            button.addAction(UIAction {[weak self] _ in
                // Camera Permission Check
                self?.requestCameraPermission { grant in
                    if grant { // 권한이 있는 경우
                        DispatchQueue.main.async {
                            guard let self = self else { return }
                            let scannerVC = UINavigationController(rootViewController: ScannerViewController())
                            
                            scannerVC.modalPresentationStyle = .fullScreen
                            self.present(scannerVC, animated: true)
                        }
                    }
                }
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

// 카메라 권한 설정 및 moreButton의 list 개수 delegate 패턴
protocol LottoCellViewDelegate: AnyObject {
    // moreButton 각 Item list
    func didTapPopButton(sourceView: UIView, lotto: Lotto?, menu: [MenuItem])
    // 카메라 권한
    func requestCameraPermission(completionHandler: @escaping (Bool) -> Void)
}
// 의존 분리 reloadData를 통해 TableView를 업데이트 moreButton에 대한 delegate 패턴
protocol PopOverContentViewControllerDelegate: AnyObject {
    // tableView Custom Cell moreButton - 삭제하기
    func didTapDeleteButton(lotto: Lotto)
    // topAppBar moreButton -> LottoResultController 목적지로 이동
    func didTapLottoDestinationForResult()
    // topAppBar moreButton -> SavedLottoViewController 목적지로 이동
    func didTapLottoDestinationForStorage()
}

// Alert와 관련된 delegate 패턴
protocol AlertContentViewControllerDelegate: AnyObject {
    // call if your Lottos is Empty
    func didTapOnIsEmptyLottos()
}

extension MainController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let lottos = LottoDataManager.shared.lottos
        return lottos.isEmpty ? 0 : lottos.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        "이번주"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let lottos = LottoDataManager.shared.lottos
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

extension MainController: LottoCellViewDelegate {
    // TODO: Camera 요청 권한을 통해 setUpCameraConfigure 실행
    func requestCameraPermission(completionHandler: @escaping (Bool) -> Void) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // 카메라 실행
            print(" 접근 권한이 있음!!")
            completionHandler(true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                completionHandler(granted)
            }
        default:
            // 권한 SettingView Route
            if let appSettingPath = URL(string: UIApplication.openSettingsURLString),UIApplication.shared.canOpenURL(appSettingPath) {
                UIApplication.shared.open(appSettingPath, options: [:], completionHandler: nil)
            }
            print("접근을 허용 안함")
            completionHandler(false)
        }
    }
    
    func didTapPopButton(sourceView: UIView, lotto: Lotto? = nil, menu: [MenuItem]) {
        // 연산 프로퍼티는 인스턴스 생성을 계속해서 popOver가 전체시트로 나옴
        let popVC: PopOverContentViewController = {
            if let lotto = lotto {
                return PopOverContentViewController(lotto: lotto, menu: menu)
            }else {
                return PopOverContentViewController(menu: menu)
            }
        }()
        
        popVC.modalPresentationStyle = .popover
        var height: CGFloat { // 각 항목마다 50씩 높이 추가
            return CGFloat(menu.count * 50)
        }
        popVC.preferredContentSize = CGSize(width: 180, height: height)
        popVC.popDelegate = self
        popVC.alertDelegate = self
        
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

extension MainController: PopOverContentViewControllerDelegate {

    func didTapDeleteButton(lotto: Lotto) {
        LottoDataManager.shared.deleteLotto(lotto: lotto)
        LottoDataManager.shared.updateLottos()
        tableView.reloadData()
    }
    
    func didTapLottoDestinationForResult() {
        let lottoResultVC = UINavigationController(
            rootViewController: LottoResultController()
        )
        lottoResultVC.modalPresentationStyle = .fullScreen
        self.present(lottoResultVC, animated: true)
    }
    
    func didTapLottoDestinationForStorage() {
        let savedLottoVC = UINavigationController(
            rootViewController: SavedLottoViewController()
        )
        savedLottoVC.modalPresentationStyle = .fullScreen
        self.present(savedLottoVC, animated: true)
    }
}

extension MainController: AlertContentViewControllerDelegate {
    func didTapOnIsEmptyLottos() {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: "저장된 로또가 없습니다",
                message: "로또 번호를 먼저 등록해야 당첨 결과를 확인할 수 있어요",
                preferredStyle: .alert
            )
            // add action
            alert.addAction(UIAlertAction(title: "확인", style: .cancel))
            self.present(alert, animated: true)
        }
    }
}
