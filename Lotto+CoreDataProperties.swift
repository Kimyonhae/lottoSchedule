//
//  Lotto+CoreDataProperties.swift
//  lottoSchedule
//
//  Created by 김용해 on 6/30/25.
//
//

import Foundation
import CoreData


extension Lotto {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Lotto> {
        return NSFetchRequest<Lotto>(entityName: "Lotto")
    }

    @NSManaged public var date: Date
    @NSManaged public var id: UUID
    @NSManaged public var numbers: NSArray

}

extension Lotto : Identifiable {

}
