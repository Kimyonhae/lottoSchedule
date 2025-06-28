//
//  ViewController.swift
//  lottoSchedule
//
//  Created by 김용해 on 6/28/25.
//

import UIKit

class MainController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if FirstRunCheck.shared.isFirstRun { // first excute!
            let firstVC = FirstRunController()
            firstVC.modalPresentationStyle = .fullScreen
            self.present(firstVC, animated: true)
        }else {
            self.view.backgroundColor = .red
        }
    }
}

