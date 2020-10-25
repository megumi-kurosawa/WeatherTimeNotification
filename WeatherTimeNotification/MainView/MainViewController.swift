//
//  MainViewController.swift
//  WeatherClock
//
//  Created by 黒沢めぐみ on 2018/10/21.
//  Copyright © 2018年 9630megumi. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController, UITableViewDelegate {

    enum ToolbarButton: Int {
        case edit = 0
        case flexibleSpace = 1
        case setting = 2
        case fixedSpace = 3
        case add = 4
    }
    
    var toolbar: UIToolbar!
    var titleLabel: UILabel!
    var tableView: UITableView!
    var selectedRow = -1

    // 囲み文字🇦文字コード
    let charAIndex = 127461

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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("\(String(describing: type(of: self))):\(#function)")
        if selectedRow != -1 {
            let indexPath = IndexPath(row: selectedRow, section: 0)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("\(String(describing: type(of: self))):\(#function)")
        if selectedRow != -1 {
            let indexPath = IndexPath(row: selectedRow, section: 0)
            tableView.deselectRow(at: indexPath, animated: true)
            selectedRow = -1
        }
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
    // ボタンアクション                       //
    /////////////////////////////////////////
    
    @objc func editButtonAction(_ sender: UIBarButtonItem) {
        
        var items = toolbar.items
        var leftButton: UIBarButtonItem
        let rightButton1 = items![ToolbarButton.setting.rawValue]
        let rightButton2 = items![ToolbarButton.add.rawValue]

        // 編集中は"Done"、完了したら"Edit"に変更する
        if tableView.isEditing {
            leftButton = UIBarButtonItem(barButtonSystemItem: .edit,
                                        target: self,
                                        action: #selector(editButtonAction(_:)))
            tableView.isEditing = false
            rightButton1.isEnabled = true
            rightButton2.isEnabled = true
        } else {
            leftButton = UIBarButtonItem(barButtonSystemItem: .done,
                                        target: self,
                                        action: #selector(editButtonAction(_:)))
            tableView.isEditing = true
            rightButton1.isEnabled = false
            rightButton2.isEnabled = false
        }
        items![0] = leftButton
        toolbar.setItems(items, animated: false)
    }
    
    @objc func settingButtonAction(_ sender: UIBarButtonItem) {
        
        let vc = SettingTableViewController()
        present(vc, animated: true, completion: nil)
    }

    /////////////////////////////////////////
    // テーブルビュー処理                      //
    /////////////////////////////////////////
        
    // ライン
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // Remove seperator inset
        if cell.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
            cell.separatorInset = UIEdgeInsets.zero
        }
        // Prevent the cell from inheriting the Table View's margin settings
        if cell.responds(to: #selector(setter: UIView.preservesSuperviewLayoutMargins)) {
            cell.preservesSuperviewLayoutMargins = false
        }
        // Explictly set your cell's layout margins
        if cell.responds(to: #selector(setter: UIView.layoutMargins)) {
            cell.layoutMargins = UIEdgeInsets.zero
        }
    }
    
    // テーブルビューのCellを編集可能にする
    override func setEditing(_ editing: Bool, animated: Bool) {
        // 継承
        super.setEditing(editing, animated: animated)
        // テーブルビューを編集モードに切り替える
        tableView.isEditing = editing //editingはBool型でeditButtonに依存する変数
    }

    // Cellを削除
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // データを更新
        CityManager().remove(at: indexPath.row)
        // テーブルビューからCellを削除する
        tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
    }

    // Cellを並び替える時の処理
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // Arrayのデータも並び替える
        CityManager().move(at: sourceIndexPath.row, to: destinationIndexPath.row)
    }

    /////////////////////////////////////////
    // 画面表示の処理                         //
    /////////////////////////////////////////
    
    func addBackgroundImage(named:String) {
        let bg = UIImageView(frame: CGRect(x: view.bounds.minX, y: UIApplication.shared.statusBarFrame.height,
                                           width: view.bounds.width, height: view.bounds.height - UIApplication.shared.statusBarFrame.height))
        bg.image = UIImage(named: named)
        bg.contentMode = .scaleAspectFill
        bg.layer.zPosition = -1
        view.addSubview(bg)
    }
    
    func prepareKits(title:String, target: Any?, leftButtonAction: Selector?, rightButtonAction: Selector?) {
        let bounds = self.view.bounds
        let statsbarHight = UIApplication.shared.statusBarFrame.size.height
        // ツールバーを作成する
        let toolbarFrame = CGRect(x: bounds.minX, y: statsbarHight,
                                  width: bounds.maxX, height: 50)
        toolbar = UIToolbar(frame: toolbarFrame)
        // ツールバーのスペース
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let fixedSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        fixedSpace.width = 4
        // 編集ボタンを作成する
        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: leftButtonAction)
        // 設定ボタンを作成する
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        button.setImage(UIImage(named: "setting_icon"), for: UIControl.State())
        button.addTarget(self, action: #selector(settingButtonAction), for: .touchUpInside)
        let settingButton = UIBarButtonItem(customView: button)
        settingButton.customView?.widthAnchor.constraint(equalToConstant: 44).isActive = true
        settingButton.customView?.heightAnchor.constraint(equalToConstant: 44).isActive = true
        // 追加ボタンを作成する
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: rightButtonAction)
        toolbar.items = [editButton, space, settingButton, fixedSpace, addButton]

        titleLabel = UILabel(frame: CGRect(x: bounds.minX, y: toolbarFrame.minY + 14,
                                           width: bounds.width, height: 26))
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.systemFont(ofSize: 20)
        titleLabel.text = title
    }
    
    func prepareTableView(nibName:String , cellIdentifier:String) {
        let bounds = self.view.bounds
        let statsbarHight = UIApplication.shared.statusBarFrame.size.height
        // テーブルビューを作成する
        let minY = statsbarHight + toolbar.frame.height
        let tableFrame = CGRect(x: bounds.minX, y: minY,
                                width: bounds.width, height: bounds.height - minY)
        tableView = UITableView(frame: tableFrame, style: .plain)
        tableView!.autoresizingMask = [
            .flexibleWidth,
            .flexibleHeight]
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView()
        // Cellを登録する
        tableView.rowHeight = 100.0
        tableView.register(UINib(nibName: nibName, bundle: nil), forCellReuseIdentifier: cellIdentifier)
    }
    
    func addSubviews() {
        view.addSubview(toolbar)
        view.addSubview(titleLabel)
        view.addSubview(tableView)
    }
    
    /////////////////////////////////////////
    // 各種データ処理                         //
    /////////////////////////////////////////
    
    // 国コードの後に国旗を表示する
    func getCountryFlag(countryCode:String) -> String {
        // 1文字ずつに分ける
        let str1 = countryCode.prefix(1)
        let str2 = countryCode.suffix(1)
        // 文字コードを計算する
        let code1 = searchIndex(str1[str1.startIndex]) + charAIndex
        let code2 = searchIndex(str2[str2.startIndex]) + charAIndex
        // コードスカラーを作成する
        let codeScalar1 = UnicodeScalar(code1)
        let codeScalar2 = UnicodeScalar(code2)
        // スカラーから文字を取得
        let characters1 = codeScalar1.map(Character.init)
        let characters2 = codeScalar2.map(Character.init)
        let string1 = String(characters1!)
        let string2 = String(characters2!)
        let flag = string1 + string2
        let countryAndFlag = "\(countryCode.description) \(flag)"
        return countryAndFlag
    }

    func searchIndex(_ char:Character) -> Int {
        var index = 0
        let string = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        for str in string {
            if str == char {
                index += 1
                return index
            }
            index += 1
        }
        return 0
    }
    
    // 時差を取得する
    func getTimeDifference(timeZoneId:String) -> String {
        let localTimeZone = TimeZone.current
        let spotTimeZone = TimeZone(identifier: timeZoneId)
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
