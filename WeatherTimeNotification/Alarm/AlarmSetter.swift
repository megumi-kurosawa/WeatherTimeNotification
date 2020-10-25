//
//  AlarmSetter.swift
//  WeatherClock
//
//  Created by 黒沢めぐみ on 2018/11/15.
//  Copyright © 2018年 9630megumi. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit

class AlarmSetter {
    
    var alarm: Event?
    
    func userConfirmation(viewController: UIViewController, at index: Int, soundName: String, alarm: Event) {
        
        self.alarm = alarm
        let message = makeMessage(alarmTitle: alarm.alarmTitle, soundName: soundName)
        let alert = UIAlertController(title: "Confirmation", message: message, preferredStyle: .alert)
        // OKしたらアラームをセットする
        let acceptAction = UIAlertAction(title: "OK", style: .default, handler: {
            (action: UIAlertAction!) -> Void in
            self.setAlarm(viewController: viewController, at: index, alarm: alarm)
        })
        // キャンセルしたら元の画面に戻る(何もしない)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cancelAction)
        alert.addAction(acceptAction)
        
        viewController.present(alert, animated: true, completion: nil)
    }

    func makeMessage(alarmTitle: String, soundName: String) -> String {
        // ユーザーに確認メッセージを表示する
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: self.alarm!.timeZoneId!)
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        let date = formatter.string(from: self.alarm!.alarmDate)
        return "Event title: \(alarmTitle)\n Date: \(date)\nPlace: \(self.alarm!.name!)\nSound: \(soundName)"
    }
    
    func setAlarm(viewController: UIViewController, at index: Int, alarm: Event) {
        
        // uuidがない場合は登録のみ
        if alarm.uuidString == "" {
            addNotification(at: index, alarm: alarm)
        // uuidがある場合はキャンセルして登録する
        } else {
            cancelAlarm(uuidString: alarm.uuidString)
            addNotification(at: index, alarm: alarm)
        }
        updated = [false, false, true]
        
        viewController.dismiss(animated: true, completion: nil)
    }
    
    func cancelAlarm(uuidString: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [uuidString])
        CityManager().cancelAlarm(uuidString: uuidString)
    }
    
    func addNotification(at index: Int, alarm: Event) {
        let content = UNMutableNotificationContent()
        content.title = alarm.alarmTitle
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: alarm.timeZoneId!)
        let alarmTime = alarm.getTime(formatter: formatter)
        let alarmDay = alarm.getDate(formatter: formatter)
        content.body = "\(alarm.name!) is now \(alarmTime)\n\(alarmDay)"
        let soundName = UNNotificationSoundName(rawValue: AlarmSound.soundList[alarm.soundId] + ".caf")
        content.sound = UNNotificationSound(named: soundName)
        content.userInfo = ["id_key": alarm.id!, "sound_key": alarm.soundId]
        content.categoryIdentifier = "weatherCategory"
        
        let calendar = Calendar.current
        let alarmDate = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: alarm.alarmDate)
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: alarmDate, repeats: false)
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                                            content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        center.add(request) { (error) in
            if error != nil { fatalError("failed to schedule notification request: \(request) with \(error!)") }}
        CityManager().setAlarm(uuidString: uuidString, at: index, title: alarm.alarmTitle, soundId: alarm.soundId, date: alarm.alarmDate)
    }

    // 通知を許可するかユーザーに確認して許可してもらう
    func requestUserAllowNotification(viewController: UIViewController, at: Int, soundName: String, alarm: (Event), authorized function: @escaping ((UIViewController, Int, String, (Event)) -> Void)) {
        UNUserNotificationCenter.current().getNotificationSettings(completionHandler: {
            (settings) in
            if settings.authorizationStatus == .authorized { function(viewController, at, soundName, alarm) }
            else { self.notificationAlert(viewController: viewController) }
            })
    }
    
    func notificationAlert(viewController: UIViewController) {
        let alart = UIAlertController(title: "Notification message", message: "Please allow notification setting to sound alarm.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { (action: UIAlertAction!) in
            // OSのアプリ設定画面へ遷移
            if let url = URL(string:"app-settings:root=General") {
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
        }
        alart.addAction(action)
        viewController.present(alart, animated: true, completion: nil)
    }
}
