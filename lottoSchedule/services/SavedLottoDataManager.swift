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
    func createLotto(weekltyResult: [Lotto], lottoResultInfo: LottoResultInfo, ranks: [String]) {
        guard let context = self.persistentContainer?.viewContext else { return }
        let lotto = SavedLotto(context: context)
        
        lotto.id = UUID()
        lotto.date = lottoResultInfo.date
        lotto.round = Int32(lottoResultInfo.round)
        lotto.numbers = weekltyResult.map { $0.numbers } as NSArray
        lotto.ranks = ranks as NSArray
        
        try? context.save()
    }
    
    // TODO: READ Lotto
    func readLotto() -> [SavedLotto]? {
        guard let context = persistentContainer?.viewContext else { return nil }
        let req = SavedLotto.fetchRequest()
        do {
            let savedLotto = try context.fetch(req)
            print("savedLotto count: \(savedLotto.count)")
            return savedLotto
        }catch {
            print("context read Error : \(error)")
        }
        
        return nil
    }
    
    //TODO: 기존 savedLottos 배열을 reload
    func updateLottos() {
        self.savedLottos = readLotto() ?? []
    }
}
