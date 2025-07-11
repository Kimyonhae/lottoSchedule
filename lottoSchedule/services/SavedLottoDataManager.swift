//
//  SavedLottoDataManager.swift
//  lottoSchedule
//
//  Created by 김용해 on 7/5/25.
//

import UIKit
import CoreData

class SavedLottoDataManager {
    static let shared: SavedLottoDataManager = .init()
    var savedLottos: [SavedLotto] = [] // 전역으로 사용할 로또 결과들
    private init() {}
    private var persistentContainer: NSPersistentContainer? {
        (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
    }
    
    // TODO: CREATE Lotto
    func createLotto(weekltyResult: [Lotto], lottoResultInfo: LottoResultInfo, ranks: [String], completion: @escaping (Bool) -> Void) {
        guard let context = self.persistentContainer?.viewContext else { return }
        let lotto = SavedLotto(context: context)
        var isSuccess: Bool = false
        
        defer {
            completion(isSuccess)
        }
        
        do {
            lotto.id = UUID()
            lotto.date = lottoResultInfo.date
            lotto.round = Int32(lottoResultInfo.round)
            lotto.numbers = weekltyResult.map { $0.numbers } as NSArray
            lotto.ranks = ranks as NSArray
            
            try context.save()
            isSuccess = true
        } catch {
            isSuccess = false
            #if DEBUG
                print("Create Lotto Occured Error: \(error)")
            #endif
        }
    }
    
    // TODO: READ Lotto
    func readLotto() -> [SavedLotto]? {
        guard let context = persistentContainer?.viewContext else { return nil }
        let req = SavedLotto.fetchRequest()
        do {
            let savedLotto = try context.fetch(req)
            return savedLotto
        }catch {
            #if DEBUG
                print("context read Error : \(error)")
            #endif
        }
        
        return nil
    }
    
    //TODO: 기존 savedLottos 배열을 reload
    func updateLottos() {
        self.savedLottos = readLotto() ?? []
    }
    
    func deleteLotto(atSection section: Int, row: Int) {
        guard let context = persistentContainer?.viewContext else { return }
        guard section < savedLottos.count,
              var numbers = savedLottos[section].numbers as? [[Int]],
              var ranks = savedLottos[section].ranks as? [String],
              row < numbers.count, row < ranks.count else { return }

        numbers.remove(at: row)
        ranks.remove(at: row)

        savedLottos[section].numbers = numbers as NSArray
        savedLottos[section].ranks = ranks as NSArray

        // 저장소에 반영
        try? context.save()
    }
    
    func deleteLottoSection(at section: Int) {
        guard section < savedLottos.count,
              let context = persistentContainer?.viewContext else { return }
        let lottoToDelete = savedLottos[section]
        context.delete(lottoToDelete)
        
        do {
            try context.save()
        } catch {
            print("Failed to delete section: \(error)")
        }
    }
}
