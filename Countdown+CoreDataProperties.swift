//
//  Countdown+CoreDataProperties.swift
//  MultiDown
//
//  Created by John Salami on 18/8/20.
//  Copyright © 2020 -. All rights reserved.
//
//

import Foundation
import CoreData


extension Countdown {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Countdown> {
        return NSFetchRequest<Countdown>(entityName: "Countdown")
    }

    @NSManaged public var completion: Date?
    @NSManaged public var title: String?
    @NSManaged public var order: Int32

}
