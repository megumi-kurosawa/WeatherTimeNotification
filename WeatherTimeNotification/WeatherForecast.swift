//
//  WeatherForecast.swift
//  WeatherClock
//
//  Created by 黒沢めぐみ on 2018/11/19.
//  Copyright © 2018年 9630megumi. All rights reserved.
//

import Foundation

class WeatherForecast {
    
    private let timeZoneId: String!
    
    private struct ThreeHourWeatherForecast: Codable {
        let list: [ThreeHourWeather]
        struct ThreeHourWeather: Codable {
            let main: Main
            struct Main: Codable {
                let temp: Float
            }
            let weather: [Weather]
            struct Weather: Codable {
                let main: String
                let description: String
                let icon: String
            }
            let dt_txt: String
        }
    }
    struct ThreeHourWeatherDetail {
        let date: Date
        let main: String
        let description: String
        let icon: String
        let temperature: Float
    }
    var threeHourWeatherDetails = [ThreeHourWeatherDetail]()
    
/*    private struct DailyWeatherForecast: Codable {
        let forecast: Forecast
        struct Forecast: Codable {
            let forecastday: [ForecastDay]
            struct ForecastDay: Codable {
                let date: String
                let day: Day
                struct Day: Codable {
                    let maxtemp_c: Float
                    let mintemp_c: Float
                    let condition: Condition
                    struct Condition: Codable {
                        let text: String
                        let icon: String
                    }
                }
            }
        }
    }*/
    private struct DailyWeatherForecast: Codable {
        let daily: [Forecast]
        struct Forecast: Codable {
            let dt: TimeInterval
            let temp: Temp
            struct Temp: Codable {
                let min: Float
                let max: Float
            }
            let weather: [Weather]
            struct Weather: Codable {
                let main: String
                let description: String
                let icon: String
            }
        }
    }
    struct DailyWeatherDetail {
        let date: Date
        let main: String
        let description: String
        let icon: String
        let temp_min: Float
        let temp_max: Float
    }
    var dailyWeatherDetails = [DailyWeatherDetail]()
    
    init(city: City) {
        timeZoneId = city.timeZoneId
        let dispatchQueue1 = DispatchQueue(label: "downLoadThreeHourWeatherForecastQueue", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: .global())
        dispatchQueue1.async {
            self.requestThreeHourWeatherForecast(city: city)
        }
        let dispatchQueue2 = DispatchQueue(label: "downLoadDailyWeatherForecastQueue", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: .global())
        dispatchQueue2.async {
            self.requestDailyWeatherForecast(city: city)
        }
    }

    @objc func requestThreeHourWeatherForecast(city: City) {
        // 天気の情報を取得するURLを作成
        guard let req_url = URL(string: "http://api.openweathermap.org/data/2.5/forecast?id=\(city.id!)&APPID=0cf5362c8c28488a4777a3150949a7dc") else {
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
            
            if data != nil { self.downloadThreeHourWeatherForecastData(session, data: data!) }
        })
        // ダウンロード開始
        task.resume()
    }
    
    // セッションに登録したタスクからデータが届いた時に使用する
    func downloadThreeHourWeatherForecastData(_ session: URLSession, data: Data) {
        
        session.finishTasksAndInvalidate()
        do {
            // JSONデータのデコーダーを生成
            let decorder = JSONDecoder()
            print("デコーダーを生成")
            // 受け取ったJSONデータをパース(解析)して格納
            let json = try decorder.decode(ThreeHourWeatherForecast.self, from: data)
            print("データーを解析")
            // 天気の情報が取得できているか確認
            let forecasts: [ThreeHourWeatherForecast.ThreeHourWeather] = json.list
            let calendar = Calendar.current
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            for forecast in forecasts {
                let gmtDate = formatter.date(from: forecast.dt_txt)
                let dateComponets = calendar.dateComponents(in: TimeZone(identifier: timeZoneId)!, from: gmtDate!)
                let date = calendar.date(from: dateComponets)
                print("date=", date)
                let main = forecast.weather.first!.main
                print("main=", main)
                let description = forecast.weather.first!.description
                print("description=", description)
                let icon = forecast.weather.first!.icon
                print("icon=", icon)
                // 温度の単位をケルビンから摂氏に変更
                let temperature: Float = forecast.main.temp - Weather.kelvin
                print("temperature=", temperature)
                let threeHourWeatherDetail = ThreeHourWeatherDetail(date: date!, main: main, description: description, icon: icon, temperature: temperature)
                threeHourWeatherDetails.append(threeHourWeatherDetail)
            }
        } catch {
            // エラー処理
            print("JSONデータの解析に失敗しました from WeatherForecast.swift in downloadThreeHourWeatherForecastData")
            print(error)
        }
    }

    @objc func requestDailyWeatherForecast(city: City) {
        // 天気の情報を取得するURLを作成
        guard let req_url = URL(string: "https://api.openweathermap.org/data/2.5/onecall?lat=\(city.lat!)&lon=\(city.lon!)&exclude=hourly&appid=0cf5362c8c28488a4777a3150949a7dc") else {
            return
        }
        print("***************************************")
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
            
            if data != nil { self.downloadDailyWeatherForecastData(session, data: data!) }
        })
        // ダウンロード開始
        task.resume()
    }
    
    // セッションに登録したタスクからデータが届いた時に使用する
    func downloadDailyWeatherForecastData(_ session: URLSession, data: Data) {

        // セッションを終了
        session.finishTasksAndInvalidate()
        do {
            // JSONデータのデコーダーを生成
            let decorder = JSONDecoder()
            print("デコーダーを生成")
            // 受け取ったJSONデータをパース(解析)して格納
            let json = try decorder.decode(DailyWeatherForecast.self, from: data)
            print("データーを解析")
            let today = Date()
            // 天気の情報が取得できているか確認
            let forecastdays: [DailyWeatherForecast.Forecast] = json.daily
            for forecastday in forecastdays {
                let date = Date(timeIntervalSince1970: forecastday.dt)
                print("date=", date)
                if date > today {
                    let main = forecastday.weather.first!.main
                    print("main=", main)
                    let description = forecastday.weather.first!.description
                    print("description=", description)
                    let icon = forecastday.weather.first!.icon
                    print("icon=", icon)
                    let temp_min = forecastday.temp.min - Weather.kelvin
                    print("temp_min=", temp_min)
                    let temp_max = forecastday.temp.max - Weather.kelvin
                    print("temp_max=", temp_max)
                    let weatherDetail = DailyWeatherDetail(date: date, main: main, description: description, icon: icon, temp_min: temp_min, temp_max: temp_max)
                    dailyWeatherDetails.append(weatherDetail)
                }
            }
        } catch {
            // エラー処理
            print("JSONデータの解析に失敗しました from WeatherForecast.swift in downloadDailyWeatherForecastData")
            print(error)
        }
    }
}
