//
//  SearchWeatherViewController.swift
//  WeatherClock
//
//  Created by 黒沢めぐみ on 2018/10/22.
//  Copyright © 2018年 9630megumi. All rights reserved.
//

import UIKit
import GooglePlaces

class SearchWeatherViewController: SearchViewController {
    
    private var mainLabel: UILabel?
    private var descriptionLabel: UILabel?
    private var weatherImage: UIImageView?
    private var decisionButton: DecisionButton!

    private var weater: Weather?

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

        view.backgroundColor = #colorLiteral(red: 0.4620226622, green: 0.8382837176, blue: 1, alpha: 1)
        
        // 部品をビューに表示する
        addSubviews()
        
        // ボタンを無効にして隠す
        decisionButton.isEnabled = false
        decisionButton.isHidden = true
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
            if weater != nil {
                weater = nil
            }
        }
    }

    /////////////////////////////////////////
    // URLセッションの処理                    //
    /////////////////////////////////////////
    
    // セッションに登録したタスクからデータを受け取ったら呼ばれる
    override func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        
        if weater != nil {
            // 受け取ったデータからデータを取得
            weater!.downloadTimeZoneIdData(session, didReceive: data)
            weater?.downloadWeatherData(session, data: data)
            
            if weater?.timeZoneId != "", weater?.weatherDetail != nil {
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
                decisionButton.isEnabled = true
                // ユーザーからの操作を有効にする
                view.isUserInteractionEnabled = true
            }
        } else {
            super.urlSession(session, dataTask: dataTask, didReceive: data)
        }
    }
    
    /////////////////////////////////////////
    // ボタン処理                            //
    /////////////////////////////////////////
    
    @objc func decisionButtonAction(sender: UIButton) {
        
        if weater != nil {

            // キャスト
            let city = weater as! City
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
        
        // インスタンスを生成
        weater = Weather(delegate: self,
                                  id: resultCities[indexPath.row].id,
                                  name: resultCities[indexPath.row].name!,
                                  country: resultCities[indexPath.row].country!,
                                  lat: resultCities[indexPath.row].coord!.lat!,
                                  lon: resultCities[indexPath.row].coord!.lon!)
        // Web APIに天候データをリクエスト
        weater!.requestWebAPI(self)
        
        // ボタンを表示する
        decisionButton.isHidden = false
        // 一時的にユーザーからの操作を無効にする(誤操作防止のため)
        view.isUserInteractionEnabled = false
    }

    /////////////////////////////////////////
    // 画面表示の処理                         //
    /////////////////////////////////////////

    // レーベルを準備する
    override func prepareLabels() {
        super.prepareLabels()
        let bounds = self.view.bounds
        let viewCenterX = bounds.maxX / 2
        let viewCenterY = (bounds.maxY - UIApplication.shared.statusBarFrame.size.height - searchBar.frame.height) / 2
        mainLabel = UILabel(frame: CGRect(x: bounds.minX,
                                          y: viewCenterY - 65,
                                          width: bounds.width, height: 50))
        mainLabel?.textAlignment = .center
        mainLabel?.textColor = #colorLiteral(red: 0.4513868093, green: 0.9930960536, blue: 1, alpha: 1)
        mainLabel?.font = UIFont.systemFont(ofSize: 44)
        descriptionLabel = UILabel(frame: CGRect(x: bounds.minX,
                                                 y: viewCenterY - 10,
                                                 width: bounds.width, height: 40))
        descriptionLabel?.textAlignment = .center
        descriptionLabel?.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.6)
        descriptionLabel?.font = UIFont.systemFont(ofSize: 32)
        weatherImage = UIImageView(frame: CGRect(x: viewCenterX - 110,
                                                 y: viewCenterY + 30,
                                                 width: 240, height: 220))
        weatherImage?.contentMode = .scaleAspectFit
    }
    
    // ボタンを準備する
    func prepareButton() {
        let bounds = self.view.bounds
        let viewCenterX = bounds.maxX / 2
        let viewCenterY = (bounds.maxY - UIApplication.shared.statusBarFrame.size.height - searchBar.frame.height) / 2
        let center = CGPoint(x: viewCenterX, y: viewCenterY)
        decisionButton = DecisionButton(center: center)
        decisionButton.addTarget(self, action: #selector(decisionButtonAction), for: .touchUpInside)
    }
    
    // 部品をビューに表示する
    override func addSubviews() {
        super.addSubviews()
        view.addSubview(mainLabel!)
        view.addSubview(descriptionLabel!)
        view.addSubview(weatherImage!)
        view.addSubview(decisionButton!)
    }
    
    // 天気の情報を画面に表示する
    override func display() {
        // レーベルや画像を表示する
        // 天気の情報が取得できているか確認する
        if weater?.weatherDetail != nil {
            // アンラップ
            if let city = weater?.name,
                let main = weater?.weatherDetail?.main,
                let description = weater?.weatherDetail?.description,
                let icon = weater?.weatherDetail?.icon {
                // 画面に表示
                cityNameLabel.text = city
                mainLabel!.text = main
                descriptionLabel!.text = description
                weatherImage?.image = UIImage(named: icon)
            }
        }
    }
    
    // 画面の表示を初期状態に戻す
    override func refureshView() {
        // レーベルや画像を空にする
        super.refureshView()
        mainLabel!.text?.removeAll()
        descriptionLabel!.text?.removeAll()
        weatherImage!.image = nil
        // ボタンを無効にして隠す
        decisionButton.isEnabled = false
        decisionButton.isHidden = true
    }
}
