//
//  NotificationViewController.swift
//  NotificationContentExtension
//
//  Created by 黒沢めぐみ on 2018/11/08.
//  Copyright © 2018年 9630megumi. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension, URLSessionDataDelegate {

    @IBOutlet var mainLabel: UILabel?
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    private let isFahrenheit_key = "isFahrenheit_key"
    private let suiteName = "group.com.9630megumi.WeatherClock"

    // ケルビン(温度の単位)
    let kelvin: Float = 273.15
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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any required interface initialization here.
    }
    
    func didReceive(_ notification: UNNotification) {
        let content = notification.request.content

        if let id = content.userInfo["id_key"] as? Int {
            guard let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?id=\(id)&APPID=0cf5362c8c28488a4777a3150949a7dc") else {
                return
            }
            let req = URLRequest(url: url)
            let session = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue.main)
            let task = session.dataTask (with: req)
            // Begin download task.
            task.resume()
        }
    }

    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        session.finishTasksAndInvalidate()
        // Handle the case where the download task succeeds.
        do {
            // JSONデータのデコーダーを生成
            let decorder = JSONDecoder()
            // 受け取ったJSONデータをパース(解析)して格納
            let json = try decorder.decode(WeatherJson.self, from: data)
            
            // 天気の情報が取得できているか確認
            if json.weather != nil, json.id != 0 {
                // 取得した情報をアンラップ
                let main: String = json.weather![0].main
                let description: String = json.weather![0].description
                let iconIndex: String = json.weather![0].icon
                // アイコンのURLを作成
                guard let icon = URL(string: "http://openweathermap.org/img/w/\(iconIndex).png") else { return
                }
                if let imageData = try? Data(contentsOf: icon) {
                    imageView.image = UIImage(data: imageData)
                }
                // 温度の単位をケルビンから摂氏に変更
                let rawTemperature: Float = json.main.temp - self.kelvin
                let userDefaults: UserDefaults! = UserDefaults(suiteName: suiteName)
                let isFahrenheit: Bool = userDefaults.bool(forKey: isFahrenheit_key)
                let temperature: Int!
                if isFahrenheit { temperature =  Int(roundf(rawTemperature * 1.8)) + 32 }
                else { temperature = Int(roundf(rawTemperature)) }
                mainLabel?.text = main
                descriptionLabel.text = description
                temperatureLabel.text = temperature.description + (isFahrenheit ? "°F" : "°C")
                print("天候情報をダウンロードしました")
            } else {
                print("天候情報を読み取れません")
            }
        } catch {
            // エラー処理
            print("JSONデータの解析に失敗しました from NotificationViewController.swift")
            print(error)
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        // Need to become first responder to have custom input view.
        return true
    }
}
