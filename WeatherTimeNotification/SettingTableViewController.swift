//
//  SettingTableViewController.swift
//  WeatherClock
//
//  Created by 黒沢めぐみ on 2018/11/04.
//  Copyright © 2018年 9630megumi. All rights reserved.
//

import UIKit
import StoreKit

var isFahrenheit = false

class SettingTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    private var gestureRecognizer: UISwipeGestureRecognizer!
    
    private let reuseIdentifier = "settingCell"
    private let isFahrenheit_key = "isFahrenheit_key"
    private let suiteName = "group.com.9630megumi.WeatherClock"
    
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

        // スワイプジェスチャを追加する
        gestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction))
        gestureRecognizer.direction = .down
        tableView.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.delegate = self
        
        let closeButton = UIButton(type: .custom)
        closeButton.frame = CGRect(x: view.frame.maxX - 30, y: 0, width: 30, height: 30)
        closeButton.setTitleColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), for: .normal)
        closeButton.setTitleColor(#colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1), for: .selected)
        closeButton.setTitle("×", for: UIControl.State())
        closeButton.layer.cornerRadius = 8.0
        closeButton.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        closeButton.layer.borderWidth = 1.0
        closeButton.clipsToBounds = true
        closeButton.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        closeButton.isEnabled = true
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.allowsSelection = false
        
        let bounds = view.bounds
        let statusbarHight = UIApplication.shared.statusBarFrame.height
        let headerView = UIView(frame: CGRect(x: bounds.minX, y: statusbarHight,
                                              width: bounds.width, height: 80))
        headerView.addSubview(closeButton)
        let textLabel = UILabel(frame: CGRect(x: bounds.minX + 20, y: statusbarHight + 10,
                                              width: bounds.width - 20, height: 50))
        textLabel.font = UIFont.systemFont(ofSize: 30)
        textLabel.text = "Weather Clock"
        headerView.addSubview(textLabel)
        
        tableView.tableHeaderView = headerView
        tableView.tableFooterView = UIView()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
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
    // スワイプアクション                      //
    /////////////////////////////////////////
    
    @objc func swipeAction(_ sender: UISwipeGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    // テーブルビューのジェスチャと併用するため、trueを返す
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    /////////////////////////////////////////
    // ボタンアクション                       //
    /////////////////////////////////////////
    
    @objc func closeButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }

    @objc func reviewButtonAction(_ sender: UIButton) {
        print("レビュー画面を表示します")
        if #available(iOS 10.3, *) {
            // iOS 10.3以上の処理
            SKStoreReviewController.requestReview()
        } else if let url = URL(string: "itms-apps://itunes.apple.com/app/com.9630megumi.WeatherClock?action=write-review") {
            // iOS 10.3未満の処理
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:])
            }
            else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @objc func purchaseButtonAction(_ sender: UIButton) {
        print("購入画面を表示します")
        let vc = PurchaseViewController()
        present(vc, animated: true, completion: nil)
    }
        
    /////////////////////////////////////////
    // セグメントコントロールアクション           //
    /////////////////////////////////////////
    
    @objc func selectSegment(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            isFahrenheit = false
//            print("摂氏を設定します")
        case 1:
            isFahrenheit = true
//            print("華氏を設定します")
        default:
            break
        }
        let userDefaults: UserDefaults! = UserDefaults(suiteName: suiteName)
        userDefaults.set(isFahrenheit, forKey: isFahrenheit_key)
        userDefaults.synchronize()
        updated = [true, false, false]
    }

    /////////////////////////////////////////
    // テーブルビュー処理                      //
    /////////////////////////////////////////

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "About developer"
        } else if section == 1 {
            return "Setting of advertising"
        } else if section == 2 {
            return "Notation of temperature"
        }
        return ""
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 2
        case 1:
            return 1
        case 2:
            return 1
        default:
            break
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                return 140.0
            case 1:
                return 100.0
            default:
                break
            }
        case 1:
            return 54.0
        case 2:
            return 54.0
        default:
            break
        }
        return 44.0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        let bounds = view.bounds
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let textView = UITextView(frame: CGRect(x: 10, y: 0,
                                                        width: bounds.width - 20, height: 140))
                textView.isUserInteractionEnabled = false
                textView.font = UIFont(name: "HiraKakuProN-W3", size: 17)
                textView.text = "Megumi. K is a japanese programmer working as individual. she lives countryside, and loves coffee and walking. app programming is pleasure for her. she everyday, seeking wonder."
                cell.contentView.addSubview(textView)
            case 1:
                let textView = UITextView(frame: CGRect(x: 10, y: 0,
                                                        width: bounds.width - 65, height: 90))
                textView.isUserInteractionEnabled = false
                textView.font = UIFont(name: "HiraKakuProN-W3", size: 16)
                textView.text = "If you want to something for WeatherClock, please send me feedback."
                let button = prepareButton(title: "Review",
                                           frame: CGRect(x: bounds.maxX - 70, y: 51,
                                                         width: 65, height: 44))
                button.addTarget(self, action: #selector(reviewButtonAction), for: .touchUpInside)
                cell.contentView.addSubview(textView)
                cell.contentView.addSubview(button)
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                cell.textLabel?.font = UIFont(name: "HiraKakuProN-W3", size: 16)
                cell.textLabel?.text = "Remove advertising"
                let button = prepareButton(title: "Purchase",
                                           frame: CGRect(x: bounds.maxX - 95, y: 5,
                                                         width: 90, height: 44))
                button.addTarget(self, action: #selector(purchaseButtonAction), for: .touchUpInside)
                cell.contentView.addSubview(button)
            default:
                break
            }
        case 2:
            switch indexPath.row {
            case 0:
                cell.textLabel?.font = UIFont(name: "HiraKakuProN-W3", size: 16)
                cell.textLabel?.text = "Celsius or Fahrenheit"
                let segments = ["Celsius", "Fahrenheit"]
                let segmentedControl = UISegmentedControl(items: segments)
                segmentedControl.frame = CGRect(x: bounds.maxX - 165, y: 5, width: 160, height: 44)
                segmentedControl.layer.cornerRadius = 10.0
                segmentedControl.layer.borderColor = #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1)
                segmentedControl.layer.borderWidth = 1.0
                segmentedControl.clipsToBounds = true
                let userDefaults: UserDefaults! = UserDefaults(suiteName: suiteName)
                let isFahrenheit: Bool = userDefaults.bool(forKey: isFahrenheit_key)
                segmentedControl.selectedSegmentIndex = isFahrenheit ? 1 : 0
                segmentedControl.addTarget(self, action: #selector(selectSegment), for: .valueChanged)
                cell.contentView.addSubview(segmentedControl)
            default:
                break
            }
        default:
            break
        }
        return cell
    }

    func prepareButton(title: String, frame: CGRect) -> UIButton {
        let button = UIButton(frame: frame)
        button.backgroundColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        button.layer.cornerRadius = 10.0
        button.setTitle(title, for: UIControl.State())
        return button
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
}
