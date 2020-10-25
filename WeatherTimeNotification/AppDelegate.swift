//
//  AppDelegate.swift
//  WeatherClock
//
//  Created by 黒沢めぐみ on 2018/10/10.
//  Copyright © 2018年 9630megumi. All rights reserved.
//

import UIKit
import CoreData
import GooglePlaces
import GoogleMobileAds
import UserNotifications
//import CoreLocation
//import AVFoundation
import StoreKit

var purchased = false

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, URLSessionDataDelegate, PurchaseManagerDelegate {

    var window: UIWindow?
    var weather: Weather?
    var alert: UIAlertController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print(#function)
        preparePurchase()
        GMSPlacesClient.provideAPIKey("AIzaSyCbFZe0glPIMrUmrriH-8Njlk5b5Uc4mXA")
        GADMobileAds.configure(withApplicationID: "ca-app-pub-4806785256947730~7392025896")
        registerForPushNotifications()
        return true
    }

    // アプリがforegroundの時に呼び出されるNotification
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print(#function)
        
        let content: UNNotificationContent = notification.request.content
        alert = AlertViewMaker().makeAlertContrller(title: content.title, message: content.body)
        let action = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction) in AlarmClock.shared.stop() })
        alert?.addAction(action)

        if let cityId = content.userInfo["id_key"] as? Int {
            weather = Weather(delegate: self, id: cityId)
        }
        if let soundId = content.userInfo["sound_key"] as? Int {
            AlarmClock.shared.sound(id: soundId)
        }
        CityManager().updateAlarmIsOn()

        completionHandler([])
    }
    
    // Notificationへのユーザーからの反応
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print(#function)
        
        AlarmClock.shared.stop()
        
        completionHandler()
    }
    
    // MARK: - URL Session

    // セッションに登録したタスクからデータを受け取ったら呼ばれる
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        // 受け取ったデータから処理を行う
        weather?.downloadWeatherData(session, data: data)
        if weather?.weatherDetail != nil {
            let imageView = AlertViewMaker().makeImageView(frame: alert!.view.frame, icon: weather!.weatherDetail!.icon)
            alert?.view.addSubview(imageView)
        }
        window?.rootViewController?.present(alert!, animated: true, completion: nil)
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        print(#function)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        print(#function)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        print(#function)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print(#function)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print(#function)
        // オブザーバー登録解除
        SKPaymentQueue.default().remove(PurchaseManager.sharedManager());
    }

    // MARK: - Purchase
    
    //---------------------------------------
    // アプリ内課金設定
    //---------------------------------------
    func preparePurchase() {
        // デリゲート設定
        PurchaseManager.sharedManager().delegate = self
        // オブザーバー登録
        SKPaymentQueue.default().add(PurchaseManager.sharedManager())
    }
    
    // 課金終了(前回アプリ起動時課金処理が中断されていた場合呼ばれる)
    func purchaseManager(_ purchaseManager: PurchaseManager!, didFinishUntreatedPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((_ complete: Bool) -> Void)!) {
        print("#### didFinishUntreatedPurchaseWithTransaction ####")
        // TODO: コンテンツ解放処理
        //コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(true)
    }
    
/*    func checkReceipt() {
        if let receiptURL = Bundle.main.appStoreReceiptURL {
            print(receiptURL)
            do {
                let receiptData = try Data(contentsOf: receiptURL)
                print("receiptData=\(receiptData)")
            } catch {
                print(error.localizedDescription)
            }
        } else {
            let payment = SKPaymentTransaction()
            let state = payment.transactionState
            if state == .purchased {
                purchased = true
            }
        }
    }*/
    
    // MARK: - Notifications

    // ユーザーからプッシュ通知許可を取得する
    func registerForPushNotifications() {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(options: [.alert, .sound]) {
            (granted, error) in
            
            // 1. Check if permission granted
            guard granted else { return }

            // アクションを作成する
            let openAction = UNNotificationAction(identifier: "openAction", title: "Open", options: .foreground)
            let category = UNNotificationCategory(identifier: "weatherCategory", actions: [openAction], intentIdentifiers: [], options: [])
            notificationCenter.setNotificationCategories([category])

            // 2. Attempt registration for remote notifications on the main thread
            DispatchQueue.main.async {
                UIApplication.shared.unregisterForRemoteNotifications()
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Cities")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

