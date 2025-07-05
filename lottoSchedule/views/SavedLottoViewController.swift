//
//  SavedLottoViewController.swift
//  lottoSchedule
//
//  Created by 김용해 on 7/5/25.
//
import UIKit

class SavedLottoViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 기본 셋업
        UICommon.setUpGradientBackground(view: self.view) // 배경색
        // navigation 제목 및 leftButton
        setUpConfigure()
    }
    
    // TODO: 기본 셋업
    private func setUpConfigure() {
        self.navigationItem.title = "보관함"
        self.navigationItem.largeTitleDisplayMode = .never
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeScreen))
    }
    
    @objc func closeScreen() {
        self.dismiss(animated: true)
    }
}
