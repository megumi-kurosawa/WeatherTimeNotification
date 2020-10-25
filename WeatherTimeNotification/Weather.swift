//
//  Weather.swift
//  WeatherClock
//
//  Created by 黒沢めぐみ on 2018/10/18.
//  Copyright © 2018年 9630megumi. All rights reserved.
//

import Foundation

class Weather: City {
    
    // ケルビン(温度の単位)
    static let kelvin: Float = 273.15
    
    // Web APIから取得するJSONデータ用構造体
    private struct WeatherJson: Codable {
        let weather: [Main]?
        struct Main: Codable {
            let main: String
            let description: String
            let icon: String
        }
        let main: Temp
        struct Temp: Codable {
            let temp: Float
        }
        let id: Int
        let name: String
    }
    
    // 天気情報の構造体
    struct WeatherDetail {
        let main: String
        let description: String
        let temperature: Float
        let icon: String
    }
    var weatherDetail: WeatherDetail?

    // delegateを使用する
    convenience init(delegate: URLSessionDelegate, id: Int) {
        self.init(name: "", country: "", id: id, lat: 0.0, lon: 0.0, timeZoneId: "")
        
        requestWebAPI(delegate)
    }
    
    // 最新の天気情報を取得する
    func update() {
        // 天気の情報を取得するURLを作成
        guard let req_url = URL(string: "http://api.openweathermap.org/data/2.5/weather?id=\(id.description)&APPID=0cf5362c8c28488a4777a3150949a7dc") else {
            return
        }
        print(req_url)
        
        // URLリクエストを作成
        let req = URLRequest(url: req_url)
        // タスクに登録するセッションを作成
        let session = URLSession(configuration: .default,
                                 delegate: nil,
                                 delegateQueue: OperationQueue.main)
        // セッションにリクエストをタスクに登録
        let task = session.dataTask(with: req, completionHandler: {
            (data, response, error) in
            
            if data != nil { self.downloadWeatherData(session, data: data!) }
        })
        // ダウンロード開始
        task.resume()
    }

    // セッションに登録したタスクからデータが届いた時に使用する
    func downloadWeatherData(_ session: URLSession, data: Data) {
        
        // セッションを終了
        session.finishTasksAndInvalidate()
        do {
            // JSONデータのデコーダーを生成
            let decorder = JSONDecoder()
            print("デコーダーを生成")
            // 受け取ったJSONデータをパース(解析)して格納
            let json = try decorder.decode(WeatherJson.self, from: data)
            print("データーを解析")
            
            // 天気の情報が取得できているか確認
            if json.weather != nil, json.id != 0 {
                // 取得した情報をアンラップ
                let main: String = json.weather![0].main
                print("main=", main)
                let description: String = json.weather![0].description
                print("description=".description)
                let icon: String = json.weather![0].icon
                print("icon=", icon)
                // 温度の単位をケルビンから摂氏に変更
                let temperature: Float = json.main.temp - Weather.kelvin
                print("temperature=", temperature)
                let weatherDetail = WeatherDetail(main: main, description: description, temperature: temperature, icon: icon)
                self.weatherDetail = weatherDetail
            } else {
                print("天候情報を読み取れません")
            }
        } catch {
            // エラー処理
            print("JSONデータの解析に失敗しました from Weather.swift")
            print(error)
        }
    }
    
    // Web APIに情報をリクエストする
    func requestWebAPI(_ delegate: URLSessionDelegate) {
        // 天気の情報を取得するURLを作成
        guard let req_url = URL(string: "http://api.openweathermap.org/data/2.5/weather?id=\(id.description)&APPID=0cf5362c8c28488a4777a3150949a7dc") else {
            return
        }
        print(req_url)
        
        // URLリクエストを作成
        let req = URLRequest(url: req_url)
        // タスクに登録するセッションを作成
        let session = URLSession(configuration: .default,
                                 delegate: delegate,
                                 delegateQueue: OperationQueue.main)
        // セッションにリクエストをタスクに登録
        let task = session.dataTask(with: req)
        // ダウンロード開始
        task.resume()
    }
}
