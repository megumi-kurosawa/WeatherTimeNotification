//
//  RightViewController.swift
//  WeatherClock
//
//  Created by 黒沢めぐみ on 2018/10/22.
//  Copyright © 2018年 9630megumi. All rights reserved.
//

import UIKit

class RightViewController: MainViewController, UITableViewDataSource {

    private var events: Array<Event> = []
    private let backgroundImageName = "event_background"
    private let titleName = "Notifications"
    private let xibFileName = "EventCell"
    private let cellIdentifier = "eventCell"
    
    /////////////////////////////////////////
    // viewのサイクル処理                     //
    /////////////////////////////////////////

    override func loadView() {
        super.loadView()
        print("\(String(describing: type(of: self))):\(#function)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(String(describing: type(of: self))):\(#function)")
        view.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        addBackgroundImage(named: backgroundImageName)
        prepareKits()
        prepareTableView(nibName: xibFileName, cellIdentifier: cellIdentifier)
        addSubviews()
        // delegateを設定
        tableView.dataSource = self
        tableView.delegate = self
        events = CityManager().prepareAlarmList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fadeIn()
        super.viewWillAppear(animated)
        print("\(String(describing: type(of: self))):\(#function)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("\(String(describing: type(of: self))):\(#function)")
    }
    
    // viewを非表示にする
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("\(String(describing: type(of: self))):\(#function)")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("\(String(describing: type(of: self))):\(#function)")
    }
    
    /////////////////////////////////////////
    // スイッチ処理                           //
    /////////////////////////////////////////
    
    @objc func switchAction(sender: UISwitch) {
        let switchView = sender as UISwitch
        let cell = switchView.superview?.superview as! EventCell
        // スイッチされたcellの位置を取得
        if let row = tableView.indexPath(for: cell)?.row {
            // スイッチのオンオフによりアラームの処理を行う
            if switchView.isOn {
                // 現在以降の日時になっているかチェックする
                if Date() < events[row].alarmDate {
                    // (ここに来ることは、無いはず)
                } else {
                    // 日付を指定し直すようにメッセージを表示する
                    requestUserReSuchedule()
                    switchView.isOn = false
                }
            } else {
                // アラームをキャンセルする
                AlarmSetter().cancelAlarm(uuidString: events[row].uuidString)
                events.removeAll()
                events = CityManager().prepareAlarmList()
                tableView.reloadData()
            }
        }
    }
    
    func requestUserReSuchedule() {
        let alert = UIAlertController(title: "Note", message: "Please set the date. To set the date, tap the line.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    /////////////////////////////////////////
    // 各種データ処理                         //
    /////////////////////////////////////////
    
    func fadeIn() {
        if updated[2] == true {
            events.removeAll()
            events = CityManager().prepareAlarmList()
            updated[2] = false
        }
        tableView.reloadData()
    }
    
    // リストの時刻を1分毎に更新する
    @objc func update() {
        sleep(1)
        events.removeAll()
        events = CityManager().prepareAlarmList()
        tableView.reloadData()
    }

    /////////////////////////////////////////
    // テーブルビュー処理                      //
    /////////////////////////////////////////
    
    // 行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }

    // セル
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Cellを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! EventCell
        prepareCell(cell, index: indexPath.row)
        return cell
    }

    // セルを準備する
    func prepareCell(_ cell:UITableViewCell, index:Int) {
        displayCell(cell, index: index)
    }

    // Cellに時刻の情報を表示する
    func displayCell(_ cell:UITableViewCell, index:Int) {
        let spot = events[index]
        
        let cityAndFlag = getCountryFlag(countryCode: spot.country)
        
        // 時差を計算する
        let timeDefference = getTimeDifference(timeZoneId: spot.timeZoneId!)

        // アラームの日付と時刻を取得する
        let formatter = DateFormatter()
        // タイムゾーンを適用
        formatter.timeZone = TimeZone(identifier: spot.timeZoneId!)
        let alarmTime = spot.getTime(formatter: formatter)
        let alarmDate = spot.getDate(formatter: formatter)

        let cityNameLabel = cell.viewWithTag(1) as! UILabel
        let countryLabel = cell.viewWithTag(2) as! UILabel
        let timeDifferenceLabel = cell.viewWithTag(3) as! UILabel
        let alarmTimeLabel = cell.viewWithTag(4) as! UILabel
        let alarmDateLabel = cell.viewWithTag(5) as! UILabel
        let switchView = cell.viewWithTag(6) as! UISwitch
        
        if spot.alarmIsOn {
            cityNameLabel.text = spot.alarmTitle
        } else {
            cityNameLabel.text = spot.name
        }
        countryLabel.text = cityAndFlag
        timeDifferenceLabel.text = timeDefference
        alarmTimeLabel.text = alarmTime
        alarmDateLabel.text = alarmDate
        switchView.isOn = spot.alarmIsOn
        switchView.addTarget(self, action: #selector(self.switchAction(sender:)), for: .valueChanged)
    }
    
    // セルがタッチされた時に呼ばれる
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        let vc = SetEventViewController()
        vc.event = events[indexPath.row]
        vc.selectedRow = indexPath.row
        vc.cityName = events[indexPath.row].name
        self.present(vc, animated: true, completion: nil)
    }
    
    /////////////////////////////////////////
    // 画面表示の処理                         //
    /////////////////////////////////////////
    
    func prepareKits() {
        let bounds = self.view.bounds
        let statsbarHight = UIApplication.shared.statusBarFrame.size.height
        // ツールバーを作成する
        let toolbarFrame = CGRect(x: bounds.minX, y: statsbarHight,
                                  width: bounds.maxX, height: 50)
        toolbar = UIToolbar(frame: toolbarFrame)
        toolbar.alpha = 0.8
        // ツールバーのスペース
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        // 設定ボタンを作成する
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        button.setImage(UIImage(named: "setting_icon"), for: UIControl.State())
        button.addTarget(self, action: #selector(settingButtonAction), for: .touchUpInside)
        let settingButton = UIBarButtonItem(customView: button)
        settingButton.customView?.widthAnchor.constraint(equalToConstant: 44).isActive = true
        settingButton.customView?.heightAnchor.constraint(equalToConstant: 44).isActive = true
        toolbar.items = [space, settingButton]

        titleLabel = UILabel(frame: CGRect(x: bounds.minX, y: toolbarFrame.minY + 14,
                                           width: bounds.width, height: 26))
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.text = titleName
    }
    
    override func prepareTableView(nibName: String, cellIdentifier: String) {
        super.prepareTableView(nibName: nibName, cellIdentifier: cellIdentifier)
    }
    
    override func addSubviews() {
        view.addSubview(toolbar)
        view.addSubview(titleLabel)
        view.addSubview(tableView)
    }
}
