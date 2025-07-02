//
//  FirstRunCheck.swift
//  lottoSchedule
//
//  Created by 김용해 on 6/28/25.
//

import UIKit

class FirstRunCheck {
    static var shared: FirstRunCheck = .init()
    let KEY = "isFirstRun"
    
    private init() {}
    
    var isFirstRun: Bool {
        let hasRunBefore = UserDefaults.standard.bool(forKey: KEY)
        if !hasRunBefore {
            UserDefaults.standard.set(true, forKey: KEY)
        }
        
        return !hasRunBefore
    }
}
