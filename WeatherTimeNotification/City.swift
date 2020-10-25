//
//  City.swift
//  WeatherClock
//
//  Created by 黒沢めぐみ on 2018/10/24.
//  Copyright © 2018年 9630megumi. All rights reserved.
//

import Foundation

class City: NSObject {
    
    var name: String!
    var country: String!
    var id: Int!
    var lat: Double!
    var lon: Double!
    var timeZoneId: String?
    var alarmIsOn: Bool = false
    var alarmDate: Date = Date()
    var alarmTitle: String = ""
    var soundId: Int = 0
    var uuidString: String = ""

    // タイムゾーンのJSONファイル読み込み用構造体
    struct Timezone: Codable {
        let timeZoneId: String?
    }

    init(name: String, country: String, id: Int, lat: Double, lon: Double, timeZoneId: String) {
        self.name = name
        self.country = country
        self.id = id
        self.lat = lat
        self.lon = lon
        self.timeZoneId = timeZoneId
        
        super.init()
    }

    init(name: String, country: String, id: Int, lat: Double, lon: Double, timeZoneId: String, alarmIsOn: Bool, alarmDate: Date) {
        self.name = name
        self.country = country
        self.id = id
        self.lat = lat
        self.lon = lon
        self.timeZoneId = timeZoneId
        self.alarmIsOn = alarmIsOn
        self.alarmDate = alarmDate
        
        super.init()
    }

    // delegateを使用する
    convenience init(delegate: URLSessionDelegate, id: Int, name: String, country:String, lat:Double, lon:Double) {
        self.init(name: name, country: country, id: id, lat: lat, lon: lon, timeZoneId: "")
        
        // Web API へのリクエストをする
        requestTimeZoneId(delegate: delegate, lat: lat, lon: lon)
    }
    
    /////////////////////////////////////////
    // Web APIリクエスト処理                  //
    /////////////////////////////////////////
    
    // delegateを使用する
    func requestTimeZoneId(delegate: URLSessionDelegate, lat: Double, lon: Double) {
        // タイムスタンプを取得する
        let timestamp = Date().timeIntervalSince1970
        
        // タイムゾーンの情報を取得するURLを作成
        guard let req_url = URL(string: "https://maps.googleapis.com/maps/api/timezone/json?location=\(lat),\(lon)&timestamp=\(timestamp)&language=us&key=AIzaSyCbFZe0glPIMrUmrriH-8Njlk5b5Uc4mXA") else {
            return
        }
        print(req_url)
        
        // URLリクエストを作成
        let req = URLRequest(url: req_url)
        // タスクに登録するセッションを作成
        let session = URLSession(configuration: .default,
                                 delegate: delegate,
                                 delegateQueue: OperationQueue.main)
        // セッションにリクエストするタスクを登録
        let task = session.dataTask(with: req)
        // ダウンロード開始
        task.resume()
    }
    
    /////////////////////////////////////////
    // URLセッションの処理                    //
    /////////////////////////////////////////
    
    func downloadTimeZoneIdData(_ session: URLSession, didReceive data: Data) {
        
        // セッションを終了
        session.finishTasksAndInvalidate()
        // JSONデータを読み込む
        do {
            // JSONデータのデコーダーを生成
            let decorder = JSONDecoder()
            // 受け取ったJSONデータをパース(解析)して格納
            let json = try decorder.decode(Timezone.self, from: data)
            if let timeZoneId = json.timeZoneId {
                // 結果をタイムゾーンとして保存
                self.timeZoneId = timeZoneId
                print("タイムゾーンを取得しました")
            } else {
                print("タイムゾーンを取得できません")
            }
        } catch {
            print("タイムゾーンを取得できません")
            print(error)
        }
    }
}
