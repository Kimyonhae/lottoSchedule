//
//  DataManager.swift
//  lottoSchedule
//
//  Created by 김용해 on 6/30/25.
//

import UIKit
import CoreData

class DataManager {
    static let shared = DataManager()
    var lottos: [Lotto] = [] // 전역으로 사용할 Data
    private init() {}
    private var persistentContainer: NSPersistentContainer? {
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    }
    
    func createLotto(numbers: [Int]) {
        guard let context = self.persistentContainer?.viewContext else { return }
        let lotto = Lotto(context: context)
        
        lotto.id = UUID()
        lotto.date = Date()
        lotto.numbers = numbers as NSArray
        
        try? context.save()
    }
    
    func readLotto() -> [Lotto]? {
        guard let context = persistentContainer?.viewContext else { return nil }
        let req = Lotto.fetchRequest()
        do {
            let lotto = try context.fetch(req)
            return lotto
        }catch {
            print("context read Error : \(error)")
        }
        
        return nil
    }
    
    func deleteLotto(lotto: Lotto) {
        guard let context = persistentContainer?.viewContext else { return }
        print("hello..? delete...?")
        context.delete(lotto)
        try? context.save()
    }
    
    //TODO: 기존 lottos 배열을 reload
    func updateLottos() {
        self.lottos = readLotto() ?? []
    }
}
