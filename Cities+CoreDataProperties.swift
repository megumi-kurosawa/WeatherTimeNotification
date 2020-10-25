//
//  Cities+CoreDataProperties.swift
//  WeatherClock
//
//  Created by 黒沢めぐみ on 2018/10/23.
//  Copyright © 2018年 9630megumi. All rights reserved.
//
//

import Foundation
import CoreData


extension Cities {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cities> {
        return NSFetchRequest<Cities>(entityName: "Cities")
    }

    @NSManaged public var id: Int32
    @NSManaged public var name: String?
    @NSManaged public var country: String?
    @NSManaged public var lat: Double
    @NSManaged public var lon: Double
    @NSManaged public var timeZoneId: String?
    @NSManaged public var alarmIsOn: Bool
    @NSManaged public var alarmDate: Date?
    @NSManaged public var alarmTitle: String?
    @NSManaged public var soundId: Int16
    @NSManaged public var uuidString: String?
}
