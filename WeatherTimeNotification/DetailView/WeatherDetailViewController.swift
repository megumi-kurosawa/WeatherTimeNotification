//
//  WeatherDetailViewController.swift
//  WeatherClock
//
//  Created by 黒沢めぐみ on 2018/11/20.
//  Copyright © 2018年 9630megumi. All rights reserved.
//

import Foundation
import UIKit

class WeatherDetailViewController: DetailViewController {
    
    var weather: Weather!
    var weatherForecasts: WeatherForecast!
    private var mainView: UIView!
    private var stackView: UIStackView!
    private var images = [UIImage]()
    private var swipeGestureRecognizerLeft: UISwipeGestureRecognizer!
    private var swipeGestureRecognizerRight: UISwipeGestureRecognizer!
    private var stackViewScrollVelocity: CGFloat! = 0.0

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
        view.backgroundColor = #colorLiteral(red: 0.4620226622, green: 0.8382837176, blue: 1, alpha: 1)
        prepareKits()
        prepareMainView()
        prepareStackView()
        prepareGestureRecognizers()
        prepareTableView()
        toolbar.barTintColor = #colorLiteral(red: 0.4620226622, green: 0.8382837176, blue: 1, alpha: 1)
        addSubviews()
        view.bringSubviewToFront(bannerView)
        let threeWeatherCount = weatherForecasts.threeHourWeatherDetails.count
        let dailyWeatherCount = weatherForecasts.dailyWeatherDetails.count
        if threeWeatherCount == 0 {
            weatherForecasts.requestThreeHourWeatherForecast(city: weather)
            _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { _ in self.waitLoadThreeHourWeather() })
        }
        if dailyWeatherCount == 0 {
            weatherForecasts.requestDailyWeatherForecast(city: weather)
            _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { _ in self.waitLoadDailyWeather() })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("\(String(describing: type(of: self))):\(#function)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("\(String(describing: type(of: self))):\(#function)")
        
        loadThreeHourWeathers()
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
    // タッチアクション                       //
    /////////////////////////////////////////

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        
        let touch = touches.first!
        
        let previouX = touch.previousLocation(in: stackView).x
        let nowX = touch.location(in: stackView).x
        let moveX = nowX - previouX
        
        stackViewScrollVelocity = moveX / CGFloat(touches.count)
    }
    
    /////////////////////////////////////////
    // スワイプアクション                      //
    /////////////////////////////////////////
    
    @objc func swipeAction(_ sender: UISwipeGestureRecognizer) {
        let moveX: CGFloat = stackViewScrollVelocity * 30
        let minX = -(stackView.frame.width - view.frame.width)
        let stackViewX = stackView.frame.origin.x
        let afterX = stackViewX + moveX
        switch sender.direction {
        case .left:
            if stackViewX == minX { return }
            if afterX <= minX {
                UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: { self.stackView.frame.origin.x = minX }, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: { self.stackView.frame.origin.x += moveX }, completion: nil)
            }
//            print("to left swiped")
        case .right:
            if stackViewX == 0 { return }
            if afterX >= 0 {
                UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: { self.stackView.frame.origin.x = 0 }, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseOut, animations: { self.stackView.frame.origin.x += moveX }, completion: nil)
            }
//            print("to right swiped")
        default:
            break
        }
    }
    
    func prepareGestureRecognizers() {
        swipeGestureRecognizerLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction))
        swipeGestureRecognizerLeft.direction = .left
        swipeGestureRecognizerRight = UISwipeGestureRecognizer(target: self, action: #selector(swipeAction))
        swipeGestureRecognizerRight.direction = .right
        stackView.addGestureRecognizer(swipeGestureRecognizerLeft)
        stackView.addGestureRecognizer(swipeGestureRecognizerRight)
    }

    /////////////////////////////////////////
    // 各種データ処理                         //
    /////////////////////////////////////////
    
    func waitLoadThreeHourWeather() {
        if weatherForecasts.threeHourWeatherDetails.count != 0 {
            loadThreeHourWeathers()
        } else {
            _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { _ in self.waitLoadThreeHourWeather() })
        }
    }

    func waitLoadDailyWeather() {
        if weatherForecasts.dailyWeatherDetails.count != 0 {
            tableView.reloadData()
        } else {
            _ = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { _ in self.waitLoadDailyWeather() })
        }
    }

    func getConvertedTemperature(temperature: Float) -> Int {
        if isFahrenheit { return conversionToFahrenheit(temperature: temperature) }
        else { return conversionToCelsius(temperature: temperature) }
    }
    
    func conversionToFahrenheit(temperature: Float) -> Int {
        return Int(roundf(temperature * 1.8)) + 32
    }
    
    func conversionToCelsius(temperature: Float) -> Int {
        return Int(roundf(temperature))
    }

    /////////////////////////////////////////
    // テーブルビュー処理                      //
    /////////////////////////////////////////
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weatherForecasts.dailyWeatherDetails.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.backgroundColor = .clear
        let weatherDetail = weatherForecasts.dailyWeatherDetails[indexPath.row]
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: weather.timeZoneId!)
        var calendar = Calendar.current
        calendar.timeZone = TimeZone(identifier: weather.timeZoneId!)!
        let dayOfTheWeek = calendar.component(.weekday, from: weatherDetail.date)
        let weekday = formatter.weekdaySymbols[dayOfTheWeek - 1]
        cell.textLabel?.text = weekday
        cell.imageView?.contentMode = .scaleAspectFit
        cell.imageView?.image = UIImage(named: weatherDetail.icon)

        let height = cell.contentView.frame.height
        let maxTemperatureLabel = autoreleasepool(invoking: { UILabel(frame: CGRect(x: view.frame.width - 110, y: 0, width: 40, height: height)) })
        maxTemperatureLabel.textAlignment = .right
        maxTemperatureLabel.font = UIFont(name: "HiraginoSans-W3", size: 20)
        maxTemperatureLabel.textColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)
        let raw_temp_max = weatherDetail.temp_max
        let temp_max = getConvertedTemperature(temperature: raw_temp_max)
        maxTemperatureLabel.text = temp_max.description
        let minTemperatureLabel = autoreleasepool(invoking: { UILabel(frame: CGRect(x: view.frame.width - 60, y: 0, width: 40, height: height)) })
        minTemperatureLabel.textAlignment = .right
        minTemperatureLabel.font = UIFont(name: "HiraginoSans-W3", size: 20)
        minTemperatureLabel.textColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
        let raw_temp_min = weatherDetail.temp_min
        let temp_min = getConvertedTemperature(temperature: raw_temp_min)
        minTemperatureLabel.text = temp_min.description
        cell.contentView.addSubview(maxTemperatureLabel)
        cell.contentView.addSubview(minTemperatureLabel)
        return cell
    }

    /////////////////////////////////////////
    // 画面表示の処理                         //
    /////////////////////////////////////////
    
    func loadThreeHourWeathers() {
        let numberOfRows = weatherForecasts.threeHourWeatherDetails.count
        let labelWidth = 70
        let height = 100
        let space = 10
        let newFrame = CGRect(x: 0, y: Int(mainView.frame.maxY),
                              width: space + (labelWidth + space) * numberOfRows, height: height)
        stackView.frame = newFrame
        stackView.spacing = CGFloat(space)
        let frame = CGRect(x: 0, y: 0, width: 0.1, height: 100)
        let view = UIView(frame: frame)
        view.widthAnchor.constraint(equalToConstant: 0.1).isActive = true
        stackView.addArrangedSubview(view)
        
        let dispatchGroup = DispatchGroup()
        let dispatchQueue = DispatchQueue(label: "loadImageQueue", qos: .userInteractive, attributes: .concurrent, autoreleaseFrequency: .inherit, target: .global())
        dispatchGroup.enter()
        dispatchQueue.async(group: dispatchGroup) {
            self.loadImages()
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        DispatchQueue.main.async(group: dispatchGroup) {
            self.loadViews(width: labelWidth, height: height)
            dispatchGroup.leave()
        }
        dispatchGroup.notify(queue: .main) {
            let views = self.stackView.arrangedSubviews
            var m = 0
            for n in 1 ..< views.count {
                let imageView = views[n].viewWithTag(1) as! UIImageView
                imageView.image = self.images[m]
                m += 1
            }
            self.stackView.setNeedsDisplay()
            self.images.removeAll()
            self.indicatior.stopAnimating()
        }
        
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0.0, y: 0.0, width: stackView.frame.width, height: 0.5)
        topBorder.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0.0, y: stackView.frame.height,
                                    width: stackView.frame.width, height: 0.5)
        bottomBorder.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        stackView.layer.addSublayer(topBorder)
        stackView.layer.addSublayer(bottomBorder)
    }
    
    func loadImages() {
        let weathers = weatherForecasts.threeHourWeatherDetails
        for weather in weathers {
            let image = UIImage(named: weather.icon)
            images.append(image!)
        }
    }
    
    func loadViews(width: Int, height: Int) {
        let image = UIImage(named: "weather_image_icon")
        var previousDay: Int! = nil
        for weather in weatherForecasts.threeHourWeatherDetails {
            let frame = CGRect(x: 0, y: 0, width: width, height: height)
            let view = UIView(frame: frame)
            let hourlabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: 30))
            hourlabel.textAlignment = .center
            hourlabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            let day = Calendar.current.component(.day, from: weather.date)
            let hour = Calendar.current.component(.hour, from: weather.date)
            if previousDay == nil || previousDay != day {
                let components = Calendar.current.dateComponents([.month, .day], from: weather.date)
                let month = components.month
                let day = components.day
                hourlabel.text = "\(month!)/\(day!),\(hour)"
                hourlabel.textAlignment = .left
                previousDay = day
            } else {
                hourlabel.text = "\(hour)"
            }
            let imageView = UIImageView(frame: CGRect(x: 0, y: 30, width: width, height: 40))
            imageView.tag = 1
            imageView.contentMode = .scaleAspectFill
            imageView.image = image
            let templabel = UILabel(frame: CGRect(x: 0, y: 70, width: width, height: 30))
            templabel.textAlignment = .center
            templabel.font = UIFont(name: "HiraginoSans-W3", size: 17)
            templabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            let rawTemperature = weather.temperature
            let temperature = getConvertedTemperature(temperature: rawTemperature)
            templabel.text = temperature.description + (isFahrenheit ? "°F" : "°C")
            view.addSubview(hourlabel)
            view.addSubview(imageView)
            view.addSubview(templabel)
            view.widthAnchor.constraint(equalToConstant: CGFloat(width)).isActive = true
            stackView.addArrangedSubview(view)
        }
    }

    func prepareMainView() {
        let statusbarHight = UIApplication.shared.statusBarFrame.height
        mainView = UIView(frame: CGRect(x: 0, y: Int(statusbarHight),
                                        width: Int(view.frame.width), height: 220))
        mainView.backgroundColor = .clear
        let cityNameLabel = UILabel(frame: CGRect(x: 0, y: 20, width: view.frame.width, height: 30))
        cityNameLabel.textAlignment = .center
        cityNameLabel.font = UIFont.systemFont(ofSize: 24)
        cityNameLabel.text = weather.name
        let imageView = UIImageView(frame: CGRect(x: mainView.center.x - 70, y: 50,
                                                  width: 140, height: 100))
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: weather.weatherDetail!.icon)
        let mainLabel = UILabel(frame: CGRect(x: 0, y: 135, width: mainView.frame.width, height: 35))
        mainLabel.textAlignment = .center
        mainLabel.font = UIFont.systemFont(ofSize: 28)
        mainLabel.textColor = #colorLiteral(red: 0.4513868093, green: 0.9930960536, blue: 1, alpha: 1)
        mainLabel.text = weather.weatherDetail!.main
        let temperatureLabel = UILabel(frame: CGRect(x: mainView.center.x - 70, y: 170,
                                                     width: 140, height: 50))
        temperatureLabel.textAlignment = .center
        temperatureLabel.font = UIFont(name: "HiraginoSans-W3", size: 32)
        temperatureLabel.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let rawTemperature = weather.weatherDetail!.temperature
        let temperature = getConvertedTemperature(temperature: rawTemperature)
        temperatureLabel.text = temperature.description + (isFahrenheit ? "°F" : "°C")
        mainView.addSubview(cityNameLabel)
        mainView.addSubview(imageView)
        mainView.addSubview(mainLabel)
        mainView.addSubview(temperatureLabel)
    }

    func prepareStackView() {
        stackView = UIStackView(frame: CGRect(x: 0.0, y: mainView.frame.maxY,
                                                  width: view.frame.width, height: 100.0))
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fill
    }
    
    override func prepareTableView() {
        super.prepareTableView()
        let bounds = view.bounds
        tableView.frame = CGRect(x: 0, y: stackView.frame.maxY,
                                    width: bounds.width, height: bounds.height)
        tableView.allowsSelection = false
        tableView.backgroundColor = .clear
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func addSubviews() {
        super.addSubviews()
        view.addSubview(mainView)
        view.addSubview(stackView)
    }
}
