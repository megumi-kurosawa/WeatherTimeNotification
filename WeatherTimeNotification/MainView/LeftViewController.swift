//
//  LeftViewController.swift
//  WeatherClock
//
//  Created by 黒沢めぐみ on 2018/10/22.
//  Copyright © 2018年 9630megumi. All rights reserved.
//

import UIKit

class LeftViewController: MainViewController, UITableViewDataSource {

    private var indicator: UIActivityIndicatorView!
    // 天気情報のクラスArray
    private var weathers = [Weather]()
    private var weatherForecasts = [WeatherForecast]()
    private let backgroundImageName = "weather_background"
    private let titleName = "Weather"
    private let xibFileName = "WeatherCell"
    private let cellIdentifier = "weatherCell"

    /////////////////////////////////////////
    // viewのサイクル処理                     //
    /////////////////////////////////////////
    
    // viewを読み込む
    override func loadView() {
        super.loadView()
        print("\(String(describing: type(of: self))):\(#function)")
    }
    
    // viewが読み込まれた
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(String(describing: type(of: self))):\(#function)")
        view.backgroundColor = #colorLiteral(red: 0.4620226622, green: 0.8382837176, blue: 1, alpha: 1)
        addBackgroundImage(named: backgroundImageName)
        prepareKits(title: titleName, target: self, leftButtonAction: #selector(editButtonAction(_:)), rightButtonAction: #selector(addButtonAction(_:)))
        prepareTableView(nibName: xibFileName, cellIdentifier: cellIdentifier)
        addSubviews()
        // delegateを設定
        tableView.dataSource = self
        tableView.delegate = self
        weathers = CityManager().prepareWeatherList()
        // インジケーターをアニメーションさせる
        indicator.startAnimating()
        if weathers.count == 0 {
            indicator.stopAnimating()
        } else if weathers.last?.weatherDetail == nil {
            updateWeather()
            _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(waitLoad), userInfo: nil, repeats: false)
        }
    }
    
    // viewを表示する
    override func viewWillAppear(_ animated: Bool) {
        fadeIn()
        super.viewWillAppear(animated)
        print("\(String(describing: type(of: self))):\(#function)")
    }
    
    // viewを表示した
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("\(String(describing: type(of: self))):\(#function)")
    }
    
    // viewを非表示にする
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("\(String(describing: type(of: self))):\(#function)")
    }
    
    // viewが非表示になった
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("\(String(describing: type(of: self))):\(#function)")
    }
    
    /////////////////////////////////////////
    // ボタンアクション                       //
    /////////////////////////////////////////
    
    @objc func addButtonAction(_ sender: UIBarButtonItem) {

        let vc = SearchWeatherViewController()        
        self.present(vc, animated: true, completion: nil)
    }
   
    /////////////////////////////////////////
    // リロードアクション                      //
    /////////////////////////////////////////
    
    @objc func refreshControlValueChanged(sender: UIRefreshControl) {
        update()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            sender.endRefreshing()
        })
        indicator.stopAnimating()
    }
    
    /////////////////////////////////////////
    // 各種データ処理                         //
    /////////////////////////////////////////
    
    func fadeIn() {
        if updated[0] == true {
            weathers.removeAll()
            weathers = CityManager().prepareWeatherList()
            updated[0] = false
            
            // インジケーターをアニメーションさせる
            indicator.startAnimating()
            
            if weathers.count == 0 {
                indicator.stopAnimating()
            } else if weathers.last?.weatherDetail == nil {
                updateWeather()
                _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(waitLoad), userInfo: nil, repeats: false)
            }
        }
    }
    
    // 天候情報取得待ちをして、テーブルビューをリロードするタイマーをセットする
    @objc func waitLoad() {
        // 天候情報がすべて取得できているか確認する
        var allLoaded = true
        for weather in weathers {
            if weather.weatherDetail == nil {
                allLoaded = false
            }
        }
        tableView.reloadData()
        if allLoaded {
            // 取得できていれば、タイマーを終了する
            // インジケーターのアニメーションをストップする
            indicator.stopAnimating()
            // 天気予報のデータをダウンロードする
            prepareWeatherForecasts()
        } else {
            // 取得できていなければ、もう一度短時間のタイマーをセットする
            _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(waitLoad), userInfo: nil, repeats: false)
        }
    }
    
    // 天候情報を取得する
    func updateWeather() {
        // リストのデータ数繰り返す
        for weather in weathers {
            weather.update()
        }
    }
    
    // リストの天気を最新の情報に更新する
    @objc func update() {

        if weathers.count != 0 {
            updateWeather()
            tableView.reloadData()
        }
    }
    
    // 天気予報のデータを更新する
    func updateWeatherForecasts() {
        weatherForecasts.removeAll()
        prepareWeatherForecasts()
    }
    
    // 天気予報のデータを準備する
    func prepareWeatherForecasts() {
        for weather in weathers {
            let weatherForecast = WeatherForecast(city: weather)
            weatherForecasts.append(weatherForecast)
        }
    }

    /////////////////////////////////////////
    // テーブルビュー処理                      //
    /////////////////////////////////////////
    
    // 行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weathers.count
    }
        
    // セル
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Cellを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! WeatherCell
        
        cell.prepareForReuse()

        prepareCell(cell, index: indexPath.row)
        return cell
    }
    
    // セルを準備する
    func prepareCell(_ cell:UITableViewCell, index:Int) {
        
        // 天気の情報が取得されているか確認する
        if weathers[index].weatherDetail == nil {
            print("天候情報がありません")
        } else {
            // 情報を取得していたら、画面に表示する
            displayCell(cell, index: index)
        }
    }
    
    // Cellに天気の情報を表示する
    func displayCell(_ cell:UITableViewCell, index:Int) {
        
        // リストに保存した一覧から天気を表示する
        let weather = weathers[index]
        
        // 国コードの後に国旗を表示する
        let countryAndflag = getCountryFlag(countryCode: weather.country)
        
        let rawTemperature = weather.weatherDetail!.temperature
        let temperature: Int!
        if isFahrenheit { temperature =  Int(roundf(rawTemperature * 1.8)) + 32 }
        else { temperature = Int(roundf(rawTemperature)) }
        
        // Cellに設置したオブジェクトを取得する
        let imageView = cell.viewWithTag(1) as! UIImageView
        let cityLabel = cell.viewWithTag(2) as! UILabel
        let countryLabel = cell.viewWithTag(3) as! UILabel
        let weatherLabel = cell.viewWithTag(4) as! UILabel
        let descriptionLabel = cell.viewWithTag(5) as! UILabel
        let temperatureLabel = cell.viewWithTag(6) as! UILabel
        
        // レーベルに表示する
        cityLabel.text = weather.name
        countryLabel.text = countryAndflag
        weatherLabel.text = weather.weatherDetail?.main
        descriptionLabel.text = weather.weatherDetail?.description
        temperatureLabel.text = temperature.description + (isFahrenheit ? "°F" : "°C")
        // イメージ画像
        imageView.image = UIImage(named: weather.weatherDetail!.icon)
    }
    
    // セルがタップされた時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        let vc = WeatherDetailViewController()
        vc.weather = weathers[indexPath.row]
        vc.weatherForecasts = weatherForecasts[indexPath.row]
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
            weathers.remove(at: indexPath.row)
            super.tableView(tableView, commit: editingStyle, forRowAt: indexPath)
            updated = [false, true, true]
        }
    }

    // すべてのCellを並び替え可能にする
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Cellを並び替える時の処理
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Arrayのデータも並び替える
        let spotWeather = weathers[sourceIndexPath.row]
        weathers.remove(at: sourceIndexPath.row)
        weathers.insert(spotWeather, at: destinationIndexPath.row)
        super.tableView(tableView, moveRowAt: sourceIndexPath, to: destinationIndexPath)
        updated = [false, true, true]
    }

    /////////////////////////////////////////
    // 画面表示の処理                         //
    /////////////////////////////////////////

    override func prepareKits(title: String, target: Any?, leftButtonAction: Selector?, rightButtonAction: Selector?) {
        super.prepareKits(title: title, target: target, leftButtonAction: leftButtonAction, rightButtonAction: rightButtonAction)
        indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
        indicator.center = self.view.center
        indicator.hidesWhenStopped = true
    }
    
    override func prepareTableView(nibName: String, cellIdentifier: String) {
        super.prepareTableView(nibName: nibName, cellIdentifier: cellIdentifier)
        let refreshControl = UIRefreshControl()
        refreshControl.backgroundColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        refreshControl.alpha = 0.3
        refreshControl.addTarget(self, action: #selector(self.refreshControlValueChanged), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    override func addSubviews() {
        super.addSubviews()
        view.addSubview(indicator)
    }
}
