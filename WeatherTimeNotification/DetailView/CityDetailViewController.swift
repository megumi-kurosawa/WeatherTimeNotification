//
//  CityDetailViewController.swift
//  WeatherClock
//
//  Created by 黒沢めぐみ on 2018/11/25.
//  Copyright © 2018年 9630megumi. All rights reserved.
//

import Foundation
import UIKit
import MapKit
import SafariServices

class CityDetailViewController: DetailViewController, SFSafariViewControllerDelegate {
    
    var city: Time!
    var cityNews: CityNews!
    private var mapView: MKMapView!
    
    /////////////////////////////////////////
    // viewのサイクル処理                     //
    /////////////////////////////////////////
    
    override func loadView() {
        super.loadView()
        print("\(String(describing: type(of: self))):\(#function)")
        
        cityNews = CityNews(cityName: city.name)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\(String(describing: type(of: self))):\(#function)")
        view.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        prepareKits()
        indicatior.color = #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 1)
        
        let bounds = view.bounds
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        mapView = MKMapView(frame: CGRect(x: 0, y: statusBarHeight, width: bounds.width, height: 300))
        let location = CLLocationCoordinate2D(latitude: city.lat, longitude: city.lon)
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 100000, longitudinalMeters: 100000)
        mapView.setRegion(region, animated: true)
        view.addSubview(mapView)
        
        prepareTableView()
        toolbar.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        addSubviews()
        view.bringSubviewToFront(bannerView)
        waitLoad()
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
        
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        }
    }

    /////////////////////////////////////////
    // 各種データ処理                         //
    /////////////////////////////////////////
    
    func waitLoad() {
        if cityNews.news.count > 0 {
            tableView.reloadData()
            indicatior.stopAnimating()
        } else {
            _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in self.waitLoad() })
        }
    }

    /////////////////////////////////////////
    // テーブルビュー処理                      //
    /////////////////////////////////////////
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityNews.news.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        let news = cityNews.news[indexPath.row]
        cell.textLabel?.text = news.title
        cell.detailTextLabel?.text = news.description
        if news.thumbnail != "" {
            if let url = URL(string: news.thumbnail) {
                if let imageData = try? Data(contentsOf: url) {
                    cell.imageView?.image = UIImage(data: imageData)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = SFSafariViewController(url: cityNews.news[indexPath.row].url)
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    /////////////////////////////////////////
    // Safariビューのdelegeteメソッド         //
    /////////////////////////////////////////
    
    func safariViewControllerDidFinish(_ controller: SFSafariViewController) {
        controller.dismiss(animated: true, completion: nil)
    }

    /////////////////////////////////////////
    // 画面表示の処理                         //
    /////////////////////////////////////////
    
    override func prepareTableView() {
        super.prepareTableView()
        let bounds = view.bounds
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        tableView.frame = CGRect(x: 0, y: mapView.frame.maxY, width: bounds.width, height: bounds.height - statusBarHeight - mapView.frame.height)
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
    }
}
