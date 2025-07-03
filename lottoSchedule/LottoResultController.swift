//
//  LottoResultController.swift
//  lottoSchedule
//
//  Created by 김용해 on 7/3/25.
//

import Foundation
import UIKit

class LottoResultController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpConfigure()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    // TODO: 기본 셋업
    private func setUpConfigure() {
        self.view.backgroundColor = .white
        self.navigationItem.title = "로또 결과"
        self.navigationItem.largeTitleDisplayMode = .never
    }
}
