//
//  CityManager.swift
//  WeatherClock
//
//  Created by 黒沢めぐみ on 2018/10/25.
//  Copyright © 2018年 9630megumi. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import UserNotifications

class CityManager {
    
    var cities: Array<City> = []
    
    init() {
        load()
    }
    
    deinit {
        unload()
    }
    
    /////////////////////////////////////////
    // 各種データ処理                         //
    /////////////////////////////////////////
    
    private func load() {
        // データベースのエンティティを取得する
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        // データを読み出す
        do {
            let fetchRequest:NSFetchRequest = Cities.fetchRequest()
            let cities = try context.fetch(fetchRequest)
            for city in cities {
                // アンラップする
                if let name = city.name, let country = city.country, let timeZoneId = city.timeZoneId, let alarmDate = city.alarmDate, let title = city.alarmTitle, let uuidString = city.uuidString {
                    let spot = City(name: name, country: country, id: Int(city.id), lat: city.lat, lon: city.lon, timeZoneId: timeZoneId, alarmIsOn: city.alarmIsOn, alarmDate: alarmDate)
                    spot.alarmTitle = title
                    spot.soundId = Int(city.soundId)
                    spot.uuidString = uuidString
                    // リストに追加
                    self.cities.append(spot)
                } else {
                    print("データベースに不完全なデータがありました")
                }
            }
        } catch {
            print(error)
        }
    }
    
    private func unload() {
        cities.removeAll()
    }
    
    // 最新のリストをコアデータに保存する
    private func updateCoreData() {
        // データベースのエンティティを取得する
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        // エンティティクラスのインスタンスを作成
        let cities = Cities()
        // データを削除して、新しいデータに書き換える
        cities.update(context, spots: self.cities)
    }
    
    /////////////////////////////////////////
    // リスト準備                            //
    /////////////////////////////////////////
    
    func prepareTimeList() -> Array<Time> {
        var array: Array<Time> = []
        for city in cities {
            let spot = Time(name: city.name, country: city.country, id: city.id, lat: city.lat, lon: city.lon, timeZoneId: city.timeZoneId!)
            array.append(spot)
        }
        return array
    }

    func prepareWeatherList() -> Array<Weather> {
        var array: Array<Weather> = []
        for city in cities {
            let spot = Weather(name: city.name, country: city.country, id: city.id, lat: city.lat, lon: city.lon, timeZoneId: city.timeZoneId!)
            array.append(spot)
        }
        return array
    }

    func prepareAlarmList() -> Array<Event> {
        updateAlarmIsOn()
        var array: Array<Event> = []
        for city in cities {
            let spot = Event(name: city.name, country: city.country, id: city.id, lat: city.lat, lon: city.lon, timeZoneId: city.timeZoneId!)
            spot.alarmIsOn = city.alarmIsOn
            if spot.alarmIsOn {
                spot.alarmDate = city.alarmDate
                spot.alarmTitle = city.alarmTitle
                spot.soundId = city.soundId
                spot.uuidString = city.uuidString
            }
            array.append(spot)
        }
        return array
    }
    
    /////////////////////////////////////////
    // アラーム処理                           //
    /////////////////////////////////////////
    
    func setAlarm(uuidString: String, at index: Int, title: String, soundId: Int, date: Date) {
        cities[index].alarmIsOn = true
        cities[index].uuidString = uuidString
        cities[index].alarmTitle = title
        cities[index].soundId = soundId
        cities[index].alarmDate = date
        updateCoreData()
    }
    
    func cancelAlarm(uuidString: String) {
        for city in cities {
            if city.uuidString == uuidString {
                city.alarmIsOn = false
                city.uuidString = ""
                city.alarmTitle = ""
                city.soundId = 0
                break
            }
        }
        updateCoreData()
    }

    func updateAlarmIsOn() {
        let now = Date()
        var updated = false
        for city in cities {
            if city.alarmIsOn, city.alarmDate <= now {
                city.uuidString = ""
                city.alarmIsOn = false
                city.alarmTitle = ""
                city.soundId = 0
                updated = true
            }
        }
        if updated {
            updateCoreData()
        }
    }

    /////////////////////////////////////////
    // 配列処理                              //
    /////////////////////////////////////////

    func append(city: City) {
        cities.append(city)
        updateCoreData()
    }
    
    func remove(at index: Int) {
        cities.remove(at: index)
        updateCoreData()
    }
    
    func move(at sourceIndex: Int, to destinationIndex: Int) {
        let city = cities[sourceIndex]
        cities.remove(at: sourceIndex)
        cities.insert(city, at: destinationIndex)
        updateCoreData()
    }
}
