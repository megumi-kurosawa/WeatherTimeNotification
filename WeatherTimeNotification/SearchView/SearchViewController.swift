//
//  SearchViewController.swift
//  WeatherClock
//
//  Created by 黒沢めぐみ on 2018/10/21.
//  Copyright © 2018年 9630megumi. All rights reserved.
//

import UIKit
import GooglePlaces

class SearchViewController: UIViewController, UISearchBarDelegate, URLSessionDataDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    var placesClient: GMSPlacesClient!
    var locationManager: CLLocationManager!
    var searchBar: UISearchBar!
    var cityNameLabel: UILabel!
    var messageLabel: UILabel!
    var waitLoadView: UIView!
    var getPlaceButton: UIButton!
    var indicator: UIActivityIndicatorView!
    var tableView: SearchResultTableView!
    var gestureRecognizer: UISwipeGestureRecognizer!
    
    var timer: Timer!
    var waitingSecond: Int = 0

    // 検索結果格納用配列
    var resultCities = [CityList.City]()
    
    let cellIdentifier = "Cell"

    /////////////////////////////////////////
    // viewの処理                           //
    /////////////////////////////////////////

    override func loadView() {
        super.loadView()
        print("\(String(describing: type(of: self))):\(#function)")

        prepareLabels()
        prepareTableView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(String(describing: type(of: self))):\(#function)")

        placesClient = GMSPlacesClient.shared()
        locationManager = CLLocationManager()

        // スワイプジェスチャを追加する
        gestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction))
        gestureRecognizer.direction = .down
        view.addGestureRecognizer(gestureRecognizer)
        
        addSubviews()
        
        // 呼び出し関連付け
        searchBar.delegate = self
        tableView.dataSource = self
        tableView.delegate = self
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
    // 位置情報サービスの処理                   //
    /////////////////////////////////////////

    func getCurrentPlace() {
        let placeFields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
                                UInt(GMSPlaceField.placeID.rawValue))
        placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: placeFields, callback: {
            (placeLikelihoodList: Array<GMSPlaceLikelihood>?, error: Error?) in
            if let error = error {
              print("An error occurred: \(error.localizedDescription)")
              return
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
              for likelihood in placeLikelihoodList {
                let place = likelihood.place
                print("Current Place name \(String(describing: place.name)) at likelihood \(likelihood.likelihood)")
                print("Current PlaceID \(String(describing: place.placeID))")
                
                CityList().requestWebAPIFromPlaceId(delegate: self, placeID: place.placeID!)
              }

                
/*        placesClient.currentPlace(callback: { (placeLikelihoodList, error) -> Void in
            if let error = error {
                print("Pick Place error: \(error.localizedDescription)")
                return
            }
            
            if let placeLikelihoodList = placeLikelihoodList {
                if let likelihood = placeLikelihoodList.likelihoods.first {
                    let place = likelihood.place*/
/*                    print("Current Place name \(place.name) at likelihood \(likelihood.likelihood)")
                    print("Current Place address \(String(describing:  place.formattedAddress))")
                    print("Current Place attributions \(String(describing: place.attributions))")
                    print("Current PlaceID \(place.placeID)")*/
            }
            self.indicator.startAnimating()
            // 待ち時間をカウントする
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.waitTimeCount), userInfo: nil, repeats: true)
        })
    }
    
    /////////////////////////////////////////
    // タッチイベント                         //
    /////////////////////////////////////////

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // キーボードを閉じる
        searchBar.endEditing(true)
        // キーボードを閉じてもキャンセルボタンを押せるようにする
        searchBarEnableCancelButton()
    }
    
    /////////////////////////////////////////
    // スワイプアクション                      //
    /////////////////////////////////////////
    
    @objc func swipeAction(_ sender: UISwipeGestureRecognizer) {
        searchBar.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
    
    /////////////////////////////////////////
    // ボタンアクション                       //
    /////////////////////////////////////////
    
    @objc func getPlaceButtonAction(_ sender: UIButton) {
        // 位置情報サービスの設定を確認する
        if(CLLocationManager.locationServicesEnabled() == true) {
            // セキュリティ認証のステータスを取得する
            let status = CLLocationManager.authorizationStatus()

            //位置情報が常に許可、使用中に許可であれば処理を行う
            if status == .authorizedAlways || status == .authorizedWhenInUse || status == .authorized {
                getCurrentPlace()
            // まだ許可されていなければ、許可メッセージを表示する
            } else if status == .notDetermined {
                locationManager.requestAlwaysAuthorization()
            // 何らかの理由により拒否されている場合は、設定画面へ誘導する
            } else {
                let alert = UIAlertController(title: "Notes", message: "Please allow to use location information service, to get current place.", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: { (action: UIAlertAction!) in
                    // OSのアプリ設定画面へ遷移
                    if let url = URL(string:"app-settings:root=General") {
                        if #available(iOS 10.0, *) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        } else {
                            UIApplication.shared.openURL(url)
                        }
                    }
                })
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
        } else {
            //位置情報サービスがOFFの場合はメッセージを表示する
            let aleart = UIAlertController(title: "Caution", message: "Location information service access denied. Please check the setting.", preferredStyle: .alert)
            let action = UIAlertAction(title:"OK", style: .default, handler:nil)
            aleart.addAction(action)
            
            present(aleart, animated:true, completion:nil)
        }
    }

    /////////////////////////////////////////
    // サーチバー処理                         //
    /////////////////////////////////////////
    
    // 入力テキストが変更された時に呼び出し
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // 検索結果をリフレッシュ
        resultCities.removeAll()
        
        // 検索キーが空なら表示しない
        if searchText == "" {
            // インジケーターをアニメーション中ならストップする
            if indicator.isAnimating {
                indicator.stopAnimating()
            }
            // 画面の表示を初期状態に戻す
            refureshView()
        } else {
            // city名を検索
            resultCities = CityList().searchCity(searchText)
            // 検索結果表示画面に切り替える
            prepareResultView()
        }
        tableView.reloadData()
    }
       
    /////////////////////////////////////////
    // ボタンアクション                         //
    /////////////////////////////////////////

    // 完了ボタンを押した時
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // キーボードを閉じる
        searchBar.endEditing(true)
        // キーボードを閉じてもキャンセルボタンを押せるようにする
        searchBarEnableCancelButton()
    }
    
    // キャンセルボタンを押した時
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if searchBar.text == "" {
            dismiss(animated: true, completion: nil)
        } else {
            searchBar.text = ""
        }
    }
    
    // キーボードを閉じてもキャンセルボタンを押せるようにする
    func searchBarEnableCancelButton() {
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
            cancelButton.isEnabled = true
        }
    }
    
    /////////////////////////////////////////
    // URLセッションの処理                    //
    /////////////////////////////////////////
    
    // セッションに登録したタスクからデータを受け取ったら呼ばれる
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        // 受け取ったデータから処理を行う
        // 現在地から近い地域の配列を結果表示する
        let result = CityList().searchCityFromDownloadData(session, didReceive: data)
        if result.count > 0 {
            // 結果を表示する
            resultCities = result
            // 検索結果表示画面に切り替える
            prepareResultView()
            tableView.reloadData()
        } else if resultCities.count == 0 {
            // 結果がない場合は、メッセージを表示する
            let alert = UIAlertController(title: "Sorry.", message: "can not locate place", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
        if waitLoadView != nil {
            waitLoadView.removeFromSuperview()
        }
        timer.invalidate()
        waitingSecond = 0
        indicator.stopAnimating()
    }
    
    /////////////////////////////////////////
    // 各種データ処理                         //
    /////////////////////////////////////////
    
    @objc func waitTimeCount() {
        waitingSecond += 1
        if waitingSecond == 5 {
            let center = view.center
            waitLoadView = UILabel(frame: CGRect(x: center.x - 100, y: center.y - 40, width: 200, height: 80))
            waitLoadView.backgroundColor = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1).withAlphaComponent(0.6)
            waitLoadView.layer.cornerRadius = 20.0
            waitLoadView.clipsToBounds = true
            let messageLabel = UILabel(frame: CGRect(x: 20, y: 10, width: 160, height: 60))
            messageLabel.backgroundColor = .clear
            messageLabel.textAlignment = .center
            messageLabel.font = UIFont.systemFont(ofSize: 20)
            messageLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            messageLabel.numberOfLines = 0
            messageLabel.lineBreakMode = .byWordWrapping
            messageLabel.adjustsFontSizeToFitWidth = true
            messageLabel.text = "It takes more time than usual"
            waitLoadView.addSubview(messageLabel)
            view.addSubview(waitLoadView)
        }
    }

    /////////////////////////////////////////
    // テーブルビュー処理                      //
    /////////////////////////////////////////
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Search result"
    }
    // 行数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultCities.count
    }
    
    // セル
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.text = resultCities[indexPath.row].name! + ", " + resultCities[indexPath.row].country!
        return cell
    }
        
    // セルがタップされた時
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // キーボードを非表示にする
        searchBar.endEditing(true)
        
        // タップされたセルを取得する
        let cell = tableView.cellForRow(at: indexPath)
        // サーチバーのテキストに保存
        searchBar.text = cell!.textLabel?.text
        // テーブルビューを非表示にする
        self.tableView.isHidden = true
        // インジケーターをアニメーションさせる
        indicator.startAnimating()
        
        // 待ち時間をカウントする
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(waitTimeCount), userInfo: nil, repeats: true)
        // WebAPIからデータを取得するインスタンスを生成、リクエストする(サブクラス)
    }
    
    /////////////////////////////////////////
    // 画面表示の処理                         //
    /////////////////////////////////////////
    
    func prepareLabels() {
        let statusBarHight = UIApplication.shared.statusBarFrame.size.height
        let bounds = self.view.bounds
        // サーチバーを作成する
        searchBar = UISearchBar(frame: CGRect(x: 0, y: statusBarHight, width: bounds.width, height: 56))
        searchBar.showsCancelButton = true
        // キーボードを閉じてもキャンセルボタンを押せるようにする
        searchBarEnableCancelButton()
        // リターンキーの表示を「完了」にする
        searchBar.returnKeyType = .done
        //何も入力されていなくてもReturnキーを押せるようにする
        searchBar.enablesReturnKeyAutomatically = false
        // サーチバーのプレイスフォルダーを設定する
        searchBar.placeholder = "City name"

        let viewCenterX = bounds.maxX / 2
        let viewCenterY = (bounds.maxY - UIApplication.shared.statusBarFrame.size.height -         searchBar.frame.height) / 2
        // 検索結果の地名を表示するレーベルを作成する
        cityNameLabel = UILabel(frame: CGRect(x: bounds.minX,
                                              y: viewCenterY - 130,
                                              width: bounds.width, height: 40))
        cityNameLabel.textAlignment = .center
        cityNameLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        cityNameLabel.font = UIFont.systemFont(ofSize: 36)
        // ユーザーへのメッセージレーベルを作成する
        messageLabel = UILabel(frame: CGRect(x: bounds.minX,
                                             y: viewCenterY - 80,
                                             width: bounds.width, height: 160))
        messageLabel.textColor = .white
        messageLabel.font = UIFont.systemFont(ofSize: 30.0)
        messageLabel.numberOfLines = 3
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineSpacing = 24.0
        let Attribute = [NSAttributedString.Key.paragraphStyle: paragraphStyle]
        messageLabel.attributedText = NSMutableAttributedString(string: "Let's search city!\nor\nGet current place.", attributes: Attribute)

        getPlaceButton = UIButton(frame: CGRect(x: viewCenterX - 40,
                                 y: viewCenterY + 110,
                                 width: 80,
                                 height: 40))
        getPlaceButton.setTitleColor(.blue, for: .normal)
        getPlaceButton.setTitleColor(.white, for: .selected)
        getPlaceButton.titleLabel!.font = .systemFont(ofSize: 28.0)
        getPlaceButton.setTitle("Here", for: UIControl.State())
        getPlaceButton.addTarget(self, action: #selector(getPlaceButtonAction), for: .touchUpInside)
        // add Target

        // インジケーターを作成する
        indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
        indicator.center = self.view.center
        indicator.hidesWhenStopped = true
    }
    
    func prepareTableView() {
        // テーブルビューを作成する
        let bounds = self.view.bounds
        let frame = CGRect(x: searchBar.frame.minX, y: searchBar.frame.maxY , width: bounds.width, height: bounds.height - searchBar.frame.height)
        tableView = SearchResultTableView(frame: frame, style: .plain)
        // テーブルビューを非表示にする
        tableView.isHidden = true
        // Cellを登録する
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
    }
    
    func addSubviews() {
        view.addSubview(searchBar)
        view.addSubview(cityNameLabel)
        view.addSubview(messageLabel)
        view.addSubview(getPlaceButton)
        view.addSubview(indicator)
        view.addSubview(tableView)
    }
    
    // 天気の情報を画面に表示する
    func display() {
        // レーベルや画像を表示する
    }
    
    // 画面の表示を初期状態に戻す
    func refureshView() {
        // レーベルや画像を空にする
        // 検索結果をリフレッシュ
        resultCities.removeAll()
        // 地名を空にする
        cityNameLabel.text?.removeAll()
        // テーブルビューを隠す
        tableView.isHidden = true
        // メッセージを表示する
        messageLabel.isHidden = false
        // ボタンを表示する
        getPlaceButton.isHidden = false
    }
    
    // 検索結果表示画面を準備する
    func prepareResultView() {
        // テーブルビューを表示する
        tableView.isHidden = false
        // メッセージを隠す
        messageLabel.isHidden = true
        // ボタンを隠す
        getPlaceButton.isHidden = true
    }
}
