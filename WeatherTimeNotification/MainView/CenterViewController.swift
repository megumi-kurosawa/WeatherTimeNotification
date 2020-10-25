//
//  CenterViewController.swift
//  WeatherClock
//
//  Created by 黒沢めぐみ on 2018/10/22.
//  Copyright © 2018年 9630megumi. All rights reserved.
//

import UIKit

class CenterViewController: MainViewController, UITableViewDataSource {
    
    // 時刻情報のクラスArray
    private var times = [Time]()
    private let backgroundImageName = "time_background"
    private let titleName = "Time"
    private let xibFileName = "TimeCell"
    private let cellIdentifier = "timeCell"

    /////////////////////////////////////////
    // viewのサイクル処理                     //
    /////////////////////////////////////////
    
    // viewを読み込む
    override func loadView() {
        super.loadView()
        print("\(String(describing: type(of: self))):\(#function)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(String(describing: type(of: self))):\(#function)")
        view.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        addBackgroundImage(named: backgroundImageName)
        prepareKits(title: titleName, target: self, leftButtonAction: #selector(editButtonAction(_:)), rightButtonAction: #selector(addButtonAction(_:)))
        prepareTableView(nibName: xibFileName, cellIdentifier: cellIdentifier)
        addSubviews()
        // delegateを設定
        tableView.dataSource = self
        tableView.delegate = self
        times = CityManager().prepareTimeList()
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
    // ボタンアクション                       //
    /////////////////////////////////////////
        
    @objc func addButtonAction(_ sender: UIBarButtonItem) {
        let vc = SearchTimeViewController()
        self.present(vc, animated: true, completion: nil)
    }

    /////////////////////////////////////////
    // 各種データ処理                         //
    /////////////////////////////////////////
    
    func fadeIn() {
        if updated[1] == true {
            times.removeAll()
            times = CityManager().prepareTimeList()
            updated[1] = false
        } else {
            
        }
        tableView.reloadData()
    }
    
    // リストの時刻を1分毎に更新する
    @objc func update() {
        tableView.reloadData()
    }

    /////////////////////////////////////////
    // テーブルビュー処理                      //
    /////////////////////////////////////////
    
    // 行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return times.count
    }
        
    // セル
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Cellを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! TimeCell
        prepareCell(cell, index: indexPath.row)
        return cell
    }
    
    // セルを準備する
    func prepareCell(_ cell:UITableViewCell, index:Int) {
        
        // タイムゾーンの情報が取得されているか確認する
        if times[index].timeZoneId == nil {
            // 何もしない
            print("タイムゾーンIDがありません")
        } else {
            // 情報を取得していたら、画面に表示する
            displayCell(cell, index: index)
        }
    }
    
    // Cellに時刻の情報を表示する
    func displayCell(_ cell:UITableViewCell, index:Int) {
        
        // 国コードに国旗を付ける
        let countryAndFlag = getCountryFlag(countryCode: times[index].country)
        
        // 時差を計算する
        let timeDefference = getTimeDifference(timeZoneId: times[index].timeZoneId!)

        // 日付と時刻を取得する
        let formatter = DateFormatter()
        // タイムゾーンを適用
        formatter.timeZone = TimeZone(identifier: times[index].timeZoneId!)
        let nowTime = times[index].getTime(formatter: formatter)
        let nowDate = times[index].getDate(formatter: formatter)
        
        // Cellに設置したオブジェクトを取得する
        let cityNameLabel = cell.viewWithTag(1) as! UILabel
        let countryLabel = cell.viewWithTag(2) as! UILabel
        let timeDifferenceLabel = cell.viewWithTag(3) as! UILabel
        let timeLabel = cell.viewWithTag(4) as! UILabel
        let dateLabel = cell.viewWithTag(5) as! UILabel
        
        // レーベルに表示する
        cityNameLabel.text = times[index].name
        countryLabel.text = countryAndFlag
        timeDifferenceLabel.text = timeDefference
        timeLabel.text = nowTime
        dateLabel.text = nowDate
    }
    
    // セルがタップされた時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        let vc = CityDetailViewController()
        vc.city = times[indexPath.row]
        present(vc, animated: true, completion: nil)
    }
    
    // すべてのCellを削除可能にする
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Cellを削除
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        // 削除可能になっているか確認する
        if editingStyle == .delete {
            // データを更新
            times.remove(at: indexPath.row)
            super.tableView(tableView, commit: editingStyle, forRowAt: indexPath)
            updated = [true, false, true]
        }
    }
    
    // すべてのCellを並び替え可能にする
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Cellを並び替える時の処理
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Arrayのデータも並び替える
        let spotTime = times[sourceIndexPath.row]
        times.remove(at: sourceIndexPath.row)
        times.insert(spotTime, at: destinationIndexPath.row)
        super.tableView(tableView, moveRowAt: sourceIndexPath, to: destinationIndexPath)
        updated = [true, false, true]
    }
    
    /////////////////////////////////////////
    // 画面表示の処理                         //
    /////////////////////////////////////////

    override func prepareTableView(nibName: String, cellIdentifier: String) {
        super.prepareTableView(nibName: nibName, cellIdentifier: cellIdentifier)
    }
}
