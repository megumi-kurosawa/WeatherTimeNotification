//
//  Cities+CoreDataClass.swift
//  WeatherClock
//
//  Created by 黒沢めぐみ on 2018/10/23.
//  Copyright © 2018年 9630megumi. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Cities)
public class Cities: NSManagedObject {

    func update(_ context:NSManagedObjectContext, spots:Array<City>) {
        deleteAll(context)
        saveAll(context, spots: spots)
    }
    
    // コアデータを削除する
    private func deleteAll(_ context:NSManagedObjectContext) {
        do {
            let fetch: NSFetchRequest = Cities.fetchRequest()
            let cities = try context.fetch(fetch)
            // 全消去する
            for city in cities {
                context.delete(city)
            }
        } catch {
            print("データを削除できません")
            print(error)
        }
    }
    
    // コアデータに保存する
    private func saveAll(_ context:NSManagedObjectContext, spots:Array<City>) {
        for spot in spots {
            let city = Cities(context: context)
            city.name = spot.name
            city.country = spot.country
            city.id = Int32(spot.id)
            city.lat = spot.lat
            city.lon = spot.lon
            city.timeZoneId = spot.timeZoneId
            city.alarmIsOn = spot.alarmIsOn
            city.alarmDate = spot.alarmDate
            city.soundId = Int16(spot.soundId)
            city.uuidString = spot.uuidString
            city.alarmTitle = spot.alarmTitle
            
            do {
                try context.save()
            } catch {
                print("データをセーブできません")
                print(error)
            }
        }
    }
}
