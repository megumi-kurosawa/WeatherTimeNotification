//
//  PageViewController.swift
//  WeatherClock
//
//  Created by 黒沢めぐみ on 2018/10/23.
//  Copyright © 2018年 9630megumi. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

var updated: [Bool] = [false, false, false]

class PageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate, UIGestureRecognizerDelegate {
    
    var bannerView: GADBannerView!
    var timer1minute: Timer!
    var timer5minute: Timer!
    var timer1hour: Timer!
    let interval1minute = 60.0
    let interval5minute = 60.0 * 5.0
    let interval1hour = 60.0 * 60.0

    var leftViewController: LeftViewController?
    var centerViewController: CenterViewController?
    var rightViewController: RightViewController?
    
    var viewControllersArray: Array<UIViewController> = []
    var pageControl: UIPageControl!
    
    let alarmClock = AlarmClock()

    private let isFahrenheit_key = "isFahrenheit_key"
    private let suiteName = "group.com.9630megumi.WeatherClock"
    static let lecture_add_key = "lecture_add_key"
    static let lecture_refresh_key = "lecture_refresh_key"

    /////////////////////////////////////////
    // viewのサイクル処理                     //
    /////////////////////////////////////////
    
    override func loadView() {
        super.loadView()
        print("\(String(describing: type(of: self))):\(#function)")
        let innerUserDefaults: UserDefaults! = UserDefaults.standard
        innerUserDefaults.register(defaults: [PageViewController.lecture_add_key : false, PageViewController.lecture_refresh_key : false])
        let userDefaults: UserDefaults! = UserDefaults(suiteName: suiteName)
        userDefaults.register(defaults: [isFahrenheit_key : false])
        isFahrenheit = userDefaults.bool(forKey: isFahrenheit_key)
        CityList.load()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(String(describing: type(of: self))):\(#function)")
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidBecomeActiveNotification), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillResignActiveNotification), name: UIApplication.willResignActiveNotification, object: nil)

        view.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        
        leftViewController = LeftViewController()
        centerViewController = CenterViewController()
        rightViewController = RightViewController()
        leftViewController?.view.frame = view.frame
        centerViewController?.view.frame = view.frame
        rightViewController?.view.frame = view.frame
        
        leftViewController?.view.tag = 0
        centerViewController?.view.tag = 1
        rightViewController?.view.tag = 2

        viewControllersArray.append(leftViewController as! UIViewController)
        viewControllersArray.append(centerViewController as! UIViewController)
        viewControllersArray.append(rightViewController as! UIViewController)
        
        DispatchQueue.main.async {
            self.setViewControllers([self.viewControllersArray.first!], direction: .forward, animated: true, completion:nil)
        }
        
        if purchased == false {
            // バナー広告を作成する
            bannerView = BannerViewMaker().makeBannerView(rootViewController: self)
            bannerView.load(GADRequest())
        }
        
        //PageControlの生成
        pageControl = UIPageControl(frame: CGRect(x:0, y:self.view.frame.height - 50, width:self.view.frame.width, height:50))
        pageControl.backgroundColor = UIColor.clear
        
        // PageControlするページ数を設定する.
        pageControl.numberOfPages = viewControllersArray.count
        
        // 現在ページを設定する.
        pageControl.currentPage = 0
        pageControl.isUserInteractionEnabled = false
        self.view.addSubview(pageControl)
        
        //DelegateとDataSouceの設定
        dataSource = self
        delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("\(String(describing: type(of: self))):\(#function)")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("\(String(describing: type(of: self))):\(#function)")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("\(String(describing: type(of: self))):\(#function)")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("\(String(describing: type(of: self))):\(#function)")
    }

    /////////////////////////////////////////
    // 画面遷移用                         //
    /////////////////////////////////////////
    
    func fadein() {
        leftViewController?.fadeIn()
        centerViewController?.fadeIn()
        rightViewController?.fadeIn()
    }

    /////////////////////////////////////////
    // 各種データ処理                         //
    /////////////////////////////////////////
    
    @objc func applicationWillResignActiveNotification() {
        print(#function)
        if timer1minute != nil { timer1minute.invalidate() }
        if timer5minute != nil { timer5minute.invalidate() }
        if timer1hour != nil { timer1hour.invalidate() }
    }
    
    @objc func applicationDidBecomeActiveNotification() {
        print(#function)
        scheduleTimers()
    }
    
    // 定刻周期のタイマーを作成する
    func scheduleTimers() {
        update1minute()
        update5minute()
        update1hour()
        // 端数秒分のタイマーを作成する
        let calender = Calendar.current
        let second = calender.component(.second, from: Date())
        _ = scheduledTimer(timeInterval: interval1minute - Double(second), target: self, selector: #selector(schedule1muniteTimer), repeats: false)
        _ = scheduledTimer(timeInterval: interval5minute - Double(second), target: self, selector: #selector(schedule5muniteTimer), repeats: false)
        let minute = calender.component(.minute, from: Date())
        _ = scheduledTimer(timeInterval: interval1hour - Double(60 * minute + second), target: self, selector: #selector(schedule1hourTimer), repeats: false)
    }
    
    @objc func schedule1muniteTimer() {
        update1minute()
        timer1minute = scheduledTimer(timeInterval: interval1minute, target: self, selector: #selector(update1minute), repeats: true)
    }

    @objc func schedule5muniteTimer() {
        update5minute()
        timer5minute = scheduledTimer(timeInterval: interval5minute, target: self, selector: #selector(update5minute), repeats: true)
    }
    
    @objc func schedule1hourTimer() {
        update1hour()
        timer1hour = scheduledTimer(timeInterval: interval1hour, target: self, selector: #selector(update1hour), repeats: true)
    }

    func scheduledTimer(timeInterval: TimeInterval, target: Any, selector: Selector, repeats: Bool) -> Timer {
        return Timer.scheduledTimer(timeInterval: timeInterval, target: target, selector: selector, userInfo: nil, repeats: repeats)
    }
    
    @objc func update1minute() {
        print(#function)
        centerViewController?.update()
        rightViewController?.update()
    }
    
    @objc func update5minute() {
        print(#function)
        leftViewController?.update()
    }
    
    @objc func update1hour() {
        print(#function)
        leftViewController?.updateWeatherForecasts()
    }
    
    /////////////////////////////////////////
    // ページビュー処理                       //
    /////////////////////////////////////////
    
    //DataSourceのメソッド
    //指定されたViewControllerの前にViewControllerを返す
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        var index = viewController.view.tag
        pageControl.currentPage = index
        index = index - 1
        if index < 0{
            return nil
        }
        return viewControllersArray[index]
    }
    
    //DataSourceのメソッド
    //指定されたViewControllerの後にViewControllerを返す
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        var index = viewController.view.tag
        pageControl.currentPage = index
        if index == viewControllersArray.count - 1 {
            return nil
        }
        index = index + 1
        return viewControllersArray[index]
    }
    
    // Delegateのメソッド
    //Viewが変更されると呼ばれる
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating: Bool, previousViewControllers: [UIViewController], transitionCompleted: Bool) {
        print("moved")
    }
}
