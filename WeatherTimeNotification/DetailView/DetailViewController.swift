//
//  DetailViewController.swift
//  WeatherClock
//
//  Created by 黒沢めぐみ on 2018/11/20.
//  Copyright © 2018年 9630megumi. All rights reserved.
//

import UIKit
import GoogleMobileAds

class DetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource  {

    var bannerView: GADBannerView!
    var tableView: UITableView!
    var toolbar: UIToolbar!
    var indicatior: UIActivityIndicatorView!
    
    let cellIdentifier = "cellIdentifier"
    
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
        
        if purchased == false {
            // バナー広告を作成する
            bannerView = BannerViewMaker().makeBannerView(rootViewController: self)
            bannerView.load(GADRequest())
        }
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
    // ボタンアクション                       //
    /////////////////////////////////////////
    
    @objc func buttonAction() {
        self.dismiss(animated: true, completion: nil)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        return cell
    }

    /////////////////////////////////////////
    // 画面表示の処理                         //
    /////////////////////////////////////////

    func prepareKits() {
        let bounds = view.bounds
        indicatior = UIActivityIndicatorView(style: .whiteLarge)
        indicatior.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        indicatior.center.x = bounds.width / 2.0
        indicatior.center.y = bounds.height / 2.0
        indicatior.hidesWhenStopped = true
        indicatior.startAnimating()
        
        // ツールバーを作成する
        let toolbarFrame = CGRect(x: 0, y: bounds.height - 50,
                                  width: bounds.width, height: 50)
        toolbar = UIToolbar(frame: toolbarFrame)
        toolbar.alpha = 0.8
        // ツールバーのスペース
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        // 設定ボタンを作成する
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        button.setImage(UIImage(named: "menu_icon"), for: UIControl.State())
        button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        let menuButton = UIBarButtonItem(customView: button)
        menuButton.customView?.widthAnchor.constraint(equalToConstant: 44).isActive = true
        menuButton.customView?.heightAnchor.constraint(equalToConstant: 44).isActive = true
        toolbar.items = [space, menuButton]
    }
    
    func prepareTableView() {
        tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
    }
    
    func addSubviews() {
        view.addSubview(tableView)
        view.addSubview(indicatior)
        view.addSubview(toolbar)
    }
}
