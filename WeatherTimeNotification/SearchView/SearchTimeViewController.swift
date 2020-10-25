//
//  SearchTimeViewController.swift
//  WeatherClock
//
//  Created by 黒沢めぐみ on 2018/10/22.
//  Copyright © 2018年 9630megumi. All rights reserved.
//

import UIKit

class SearchTimeViewController: SearchViewController {

    private var timeZoneIdLabel: UILabel?
    private var timeLabel: UILabel?
    private var decisionButton: DecisionButton!
    
    private var time: Time?
    
    override func loadView() {
        super.loadView()
        print("\(String(describing: type(of: self))):\(#function)")
        // レーベルを作成する
        prepareLabels()
        // ボタンを作成する
        prepareButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(String(describing: type(of: self))):\(#function)")

        view.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)

        // 部品をビューに表示する
        addSubviews()
        
        // ボタンを無効にして隠す
        decisionButton!.isEnabled = false
        decisionButton!.isHidden = true
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
    // サーチバー処理                         //
    /////////////////////////////////////////
    
    // 入力テキストが変更された時に呼び出し
    override func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        super.searchBar(searchBar, textDidChange: searchText)
        // 検索キーが空なら表示しない
        if searchText == "" {
            refureshView()
            if time != nil {
                time = nil
            }
        }
    }

    /////////////////////////////////////////
    // URLセッションの処理                    //
    /////////////////////////////////////////
    
    // セッションに登録したタスクからデータを受け取ったら呼ばれる
    override func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        if time != nil {
            // 受け取ったデータからタイムゾーンのデータを取得
            time?.downloadTimeZoneIdData(session, didReceive: data)
            if waitLoadView != nil {
                waitLoadView.removeFromSuperview()
            }
            timer.invalidate()
            waitingSecond = 0
            // 取得した情報を画面に表示
            display()
            // インジケーターのアニメーションを終了する
            indicator.stopAnimating()
            // OKボタンを有効にする
            decisionButton!.isEnabled = true
            // ユーザーからの操作を有効にする
            view.isUserInteractionEnabled = true
        } else {
            super.urlSession(session, dataTask: dataTask, didReceive: data)
        }
    }
    
    /////////////////////////////////////////
    // ボタン処理                            //
    /////////////////////////////////////////
    
    @objc func decisionButtonAction(sender: UIButton) {
        
        if time != nil {

            // キャスト
            let city = time as! City
            CityManager().append(city: city)
            updated = [true, true, true]
        }
        let vc = self.presentingViewController as! PageViewController
        vc.fadein()

        self.dismiss(animated: true, completion: nil)
    }

    /////////////////////////////////////////
    // テーブルビュー処理                      //
    /////////////////////////////////////////
    
    // セルがタップされた時
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        super.tableView(tableView, didSelectRowAt: indexPath)
        
        time = Time(delegate: self,
                            id: resultCities[indexPath.row].id,
                            name: resultCities[indexPath.row].name!,
                            country: resultCities[indexPath.row].country!,
                            lat: resultCities[indexPath.row].coord!.lat!,
                            lon: resultCities[indexPath.row].coord!.lon!)
        
        // ボタンを表示する
        decisionButton!.isHidden = false
        // 一時的にユーザーからの操作を無効にする(誤操作防止のため)
        view.isUserInteractionEnabled = false
    }
    
    /////////////////////////////////////////
    // 画面表示の処理                         //
    /////////////////////////////////////////
    
    // レーベルを準備する
    override func prepareLabels() {
        super.prepareLabels()
        
        cityNameLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        let bounds = self.view.bounds
        let viewCenterY = (bounds.maxY - UIApplication.shared.statusBarFrame.size.height - searchBar.frame.height) / 2
        timeZoneIdLabel = UILabel(frame: CGRect(x: bounds.minX, y: viewCenterY - 50,
                                                width: bounds.width, height: 40))
        timeZoneIdLabel?.textAlignment = .center
        timeZoneIdLabel?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        timeZoneIdLabel?.font = UIFont.systemFont(ofSize: 30)
        timeLabel = UILabel(frame: CGRect(x: bounds.minX,
                                          y: viewCenterY,
                                          width: bounds.width, height: 140))
        timeLabel?.textAlignment = .center
        timeLabel?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        timeLabel?.font = UIFont.systemFont(ofSize: 30)
        timeLabel!.numberOfLines = 3
    }

    // ボタンを準備する
    func prepareButton() {
        let bounds = self.view.bounds
        let viewCenterX = bounds.maxX / 2
        let viewCenterY = (bounds.maxY - UIApplication.shared.statusBarFrame.size.height - searchBar.frame.height) / 2
        let center = CGPoint(x: viewCenterX, y: viewCenterY)
        decisionButton = DecisionButton(center: center)
        decisionButton.addTarget(self, action: #selector(decisionButtonAction), for: UIControl.Event.touchUpInside)
    }
    
    // 部品をビューに表示する
    override func addSubviews() {
        super.addSubviews()
        view.addSubview(timeZoneIdLabel!)
        view.addSubview(timeLabel!)
        view.addSubview(decisionButton!)
    }
    
    // 取得した情報を画面に表示する
    override func display() {
        // レーベルや画像を表示する
        if time != nil {
            let formatter = DateFormatter()
            // タイムゾーンを適用
            formatter.timeZone = TimeZone(identifier: (time?.timeZoneId)!)
            // 時刻を取得
            let nowTime = time!.getTime(formatter: formatter)
            // 日付を取得
            let nowDate = time!.getDate(formatter: formatter)
            
            // 画面に表示
            cityNameLabel.text = time?.name
            timeZoneIdLabel?.text = time?.timeZoneId
            timeLabel!.text = nowDate + "\n" + nowTime
        }
    }
    
    // 画面の表示を初期状態に戻す
    override func refureshView() {
        // レーベルや画像を空にする
        super.refureshView()
        timeZoneIdLabel?.text?.removeAll()
        timeLabel!.text?.removeAll()
        // ボタンを無効にして隠す
        decisionButton!.isEnabled = false
        decisionButton!.isHidden = true
    }
}
