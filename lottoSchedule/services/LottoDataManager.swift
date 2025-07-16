//
//  DataManager.swift
//  lottoSchedule
//
//  Created by 김용해 on 6/30/25.
//

import UIKit
import CoreData


class LottoDataManager {
    static let shared = LottoDataManager()
    var lottos: [Lotto] = [] // 전역으로 사용할 Data
    private init() {}
    private var persistentContainer: NSPersistentContainer? {
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    }
    
    // TODO: Create Lotto
    func createLotto(numbers: [Int], round: String) {
        guard let context = self.persistentContainer?.viewContext else { return }
        let lotto = Lotto(context: context)
        
        lotto.id = UUID()
        lotto.date = Date()
        lotto.round = Int32(round.filter{ $0.isNumber })! // 숫자만 필터링
        lotto.numbers = numbers as NSArray
        
        try? context.save()
    }
    
    // TODO: READ Lotto
    func readLotto() -> [Lotto]? {
        guard let context = persistentContainer?.viewContext else { return nil }
        let req = Lotto.fetchRequest()
        do {
            let lotto = try context.fetch(req)
            return lotto
        }catch {
            #if DEBUG
                print("context read Error : \(error)")
            #endif
        }
        
        return nil
    }
    
    // TODO: one for Lotto delete
    func deleteLotto(lotto: Lotto) {
        guard let context = persistentContainer?.viewContext else { return }
        context.delete(lotto)
        try? context.save()
    }
    
    // TODO: All Lottos Delete
    @MainActor
    func deleteAllLottos() async {
        guard let context = persistentContainer?.viewContext else { return }
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Lotto.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        await context.perform {
            do {
                try context.execute(deleteRequest)
                try context.save()
            } catch {
                #if DEBUG
                    print("All delete Failed : \(error.localizedDescription)")
                #endif
            }
        }
    }
    
    //TODO: 기존 lottos 배열을 reload
    func updateLottos() {
        self.lottos = readLotto() ?? []
    }
}
