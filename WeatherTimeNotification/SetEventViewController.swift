//
//  SetEventViewController.swift
//  WeatherClock
//
//  Created by 黒沢めぐみ on 2018/10/22.
//  Copyright © 2018年 9630megumi. All rights reserved.
//

import UIKit
import AudioToolbox

class SetEventViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate {

    var cityNameLabel: UILabel?
    var descriptionLabel: UILabel?
    var textField: UITextField?
    var soundPicker: UIPickerView?
    var datePicker: UIDatePicker?
    var resetButton: UIButton!
    var decisionButton: DecisionButton!
    var gestureRecognizer: UISwipeGestureRecognizer!
    var touchRecognizer: UITapGestureRecognizer!
    
    var timer: Timer!
    
    var event: Event?
    var selectedRow: Int!
    var cityName: String!
    var testSound = AlarmSound()
    
    let soundList = ["Alarm 1",
                     "Alarm 2",
                     "Bell",
                     "Cock-a-doodle-doo",
                     "Bird",
                     "Birds",
                     "Music box 1",
                     "Music box 2",
                     "Healing 1",
                     "Healing 2",
                     "Silen 1",
                     "Silen 2",
                     "Clapping hands"]
    
    /////////////////////////////////////////
    // viewの処理                           //
    /////////////////////////////////////////
    
    override func loadView() {
        super.loadView()
        print("\(String(describing: type(of: self))):\(#function)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(String(describing: type(of: self))):\(#function)")

        view.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        
        // スワイプジェスチャを追加する
        gestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeAction(sender:)))
        gestureRecognizer.direction = .down
        view.addGestureRecognizer(gestureRecognizer)
        
        // レーベルを作成する
        prepareLabels()
        if event!.alarmIsOn {
            textField?.text = event!.alarmTitle
            soundPicker?.selectRow(event!.soundId, inComponent: 0, animated: false)
            datePicker?.date = event!.alarmDate
        } else {
            textField?.text = cityName + ":"
        }
        textField?.becomeFirstResponder()
        
        // ボタンを作成する
        prepareButton()
        // 部品をビューに表示する
        addSubviews()
    }

    // viewを表示する
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("\(String(describing: type(of: self))):\(#function)")
    }
    
    // viewを表示した
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("\(String(describing: type(of: self))):\(#function)")

        let calender = Calendar.current
        let second = calender.dateComponents([.second], from: Date()).second
        _ = Timer.scheduledTimer(timeInterval: 60.0 - Double(second!), target: self, selector: #selector(chengeTimer), userInfo: nil, repeats: false)
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

        if testSound.isPlaing() { testSound.stop() }
        if timer != nil { timer.invalidate() }
    }
    
    /////////////////////////////////////////
    // スワイプアクション                      //
    /////////////////////////////////////////
    
    // 下へスワイプするとビューを閉じる
    @objc func swipeAction(sender:UISwipeGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }

    /////////////////////////////////////////
    // タップアクション                        //
    /////////////////////////////////////////
    
    // キーボードの外をタップすると、キーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if textField?.isFirstResponder == true {
            textField?.resignFirstResponder()
        }
    }

    /////////////////////////////////////////
    // ピッカー処理                           //
    /////////////////////////////////////////
    
    // MARK: - Date Picker
    
    @objc func chengeTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true, block: { _ in self.datePicker?.minimumDate = Date(timeInterval: 60.0, since: Date()) })
    }
    
    // 時刻がセットされたらボタンを有効にして表示する
    @objc func pickerAction(sender: UIDatePicker) {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: datePicker!.date)
        event?.alarmDate = calendar.date(from: dateComponents)!
        resetButton.isEnabled = true
        decisionButton.isEnabled = true
    }
    
    // MARK: - Sound Picker View
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return soundList.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return soundList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if testSound.isPlaing() {
            testSound.stop()
        }
        testSound.play(id: row)
        event?.soundId = row
    }
    
    /////////////////////////////////////////
    // ボタンアクション                        //
    /////////////////////////////////////////
    
    // リセットボタンを押した時のアクション
    @objc func resetButtonAction(sender: UIButton) {
        // 日付を現在に戻す
        let timeZoneId = TimeZone(identifier: (event?.timeZoneId)!)
        let dateComponents = Calendar.current.dateComponents(in: timeZoneId!, from: Date())
        datePicker?.date = dateComponents.date!
        datePicker?.minimumDate = dateComponents.date
        // ボタンを無効、非表示にする
        resetButton.isEnabled = false
        decisionButton.isEnabled = false
    }
    
    // OKボタンを押した時のアクション
    @objc func decisionButtonAction(sender: UIButton) {
        
        if textField?.text == "" {
            presentAlert(title: "Note", message: "Please input alarm title.")
        } else if (event?.alarmDate)! <= Date() {
            presentAlert(title: "Note", message: "Please set the date of the future.")
        } else if let alarmDate = event?.alarmDate, let text = textField?.text {
            event?.alarmDate = alarmDate
            event?.alarmTitle = text
            let alarmSetter = AlarmSetter()
            alarmSetter.requestUserAllowNotification(viewController: self, at: selectedRow, soundName: soundList[event!.soundId], alarm: event!, authorized: alarmSetter.userConfirmation)
            
            // キャスト
            let city = event as! City
            CityManager().setAlarm(uuidString: city.uuidString, at: selectedRow, title: city.alarmTitle, soundId: city.soundId, date: city.alarmDate)
            updated = [false, false, true]
        }
        let vc = self.presentingViewController as! PageViewController
        vc.fadein()

        let alert = UIAlertController(title: "Confirmation", message: "is this OK?", preferredStyle: .alert)
        let acceptAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(acceptAction)
        self.present(alert, animated: true, completion: nil)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    /////////////////////////////////////////
    // テキストフィールドの処理                 //
    /////////////////////////////////////////
    
    // エンターキーを押すとキーボードを閉じる
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを閉じる
        textField.resignFirstResponder()
        return true
    }


    /////////////////////////////////////////
    // 画面表示の処理                         //
    /////////////////////////////////////////
    
    // レーベルを準備する
    func prepareLabels() {
        
        let bounds = self.view.bounds
        let viewCenterY = (bounds.maxY - UIApplication.shared.statusBarFrame.size.height) / 2
        cityNameLabel = UILabel(frame: CGRect(x: bounds.minX, y: viewCenterY - 240,
                                              width: bounds.width, height: 40))
        cityNameLabel?.textAlignment = .center
        cityNameLabel?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        cityNameLabel?.font = UIFont.systemFont(ofSize: 36)
        descriptionLabel = UILabel(frame: CGRect(x: bounds.minX, y: viewCenterY - 190,
                                             width: bounds.width, height: 30))
        descriptionLabel?.textAlignment = .center
        descriptionLabel?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        descriptionLabel?.font = UIFont.systemFont(ofSize: 28)
        
        cityNameLabel?.text = event?.name
        descriptionLabel?.text = event!.country + ", " + getTimeDefference()
        
        textField = UITextField(frame: CGRect(x: bounds.minX, y: viewCenterY - 140,
                                              width: bounds.width, height: 40))
        textField?.borderStyle = .roundedRect
        textField?.clearButtonMode = .whileEditing
        textField?.returnKeyType = .done
        textField?.placeholder = "Event title"
        textField?.delegate = self
        
        soundPicker = UIPickerView(frame: CGRect(x: bounds.minX, y: viewCenterY - 99,
                                                 width: bounds.width, height: 148))
        soundPicker?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        soundPicker?.dataSource = self
        soundPicker?.delegate = self
        
        datePicker = UIDatePicker(frame: CGRect(x: bounds.minX, y: viewCenterY + 80,
                                                width: bounds.width, height: 160))
        datePicker?.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        datePicker?.timeZone = TimeZone(identifier: (event?.timeZoneId)!)
//        let calender = Calendar.current
//        let second = calender.dateComponents([.second], from: Date()).second
        datePicker?.minimumDate = Date()
        //データ選択時の処理内容の設定
        datePicker!.addTarget(self, action: #selector(pickerAction(sender:)), for: .valueChanged)
    }
    
    // ボタンを準備する
    func prepareButton() {
        let bounds = self.view.bounds
        let viewCenterX = bounds.maxX / 2
        let viewCenterY = (bounds.maxY - UIApplication.shared.statusBarFrame.size.height) / 2
        let center = CGPoint(x: viewCenterX, y: viewCenterY)
        resetButton = UIButton(frame: CGRect(x: bounds.minX, y: viewCenterY + 50,
                                             width: bounds.width, height: 29))
        resetButton.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        resetButton.setTitleColor(.blue, for: .normal)
        resetButton.setTitleColor(.gray, for: .disabled)
        resetButton.titleLabel?.font = .systemFont(ofSize: 22.0)
        resetButton.setTitle("Reset date", for: UIControl.State())
        resetButton.addTarget(self, action: #selector(self.resetButtonAction), for: .touchUpInside)
        decisionButton = DecisionButton(center: center)
        decisionButton.addTarget(self, action: #selector(decisionButtonAction), for: .touchUpInside)
        // ボタンを無効にする
        resetButton.isEnabled = false
        decisionButton!.isEnabled = false
    }
    
    // 部品をビューに表示する
    func addSubviews() {
        view.addSubview(cityNameLabel!)
        view.addSubview(descriptionLabel!)
        view.addSubview(textField!)
        view.addSubview(soundPicker!)
        view.addSubview(datePicker!)
        view.addSubview(resetButton)
        view.addSubview(decisionButton!)
    }
    
    // 時差を計算する
    func getTimeDefference() -> String {
        let localTimeZone = TimeZone.current
        let spotTimeZone = TimeZone(identifier: (event?.timeZoneId)!)
        let localTimeZoneOffset = localTimeZone.secondsFromGMT()
        let spotTimeZoneOffset = spotTimeZone?.secondsFromGMT()
        let timeDifferenceSecond = spotTimeZoneOffset! - localTimeZoneOffset
        let defferenceHour = timeDifferenceSecond / (60 * 60)
        let defferenceMinute = (timeDifferenceSecond % (60 * 60)) / 60
        let timeDefference = String(format: "%@%d:%02d",
                                    defferenceHour > 0 ? "+" : "",
                                    defferenceHour,
                                    abs(defferenceMinute))
        return timeDefference
    }
}
