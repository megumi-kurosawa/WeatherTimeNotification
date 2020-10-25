//
//  AlertViewMaker.swift
//  WeatherClock
//
//  Created by 黒沢めぐみ on 2018/11/17.
//  Copyright © 2018年 9630megumi. All rights reserved.
//

import Foundation
import UIKit

class AlertViewMaker {
    
    func makeAlertContrller(title: String, message: String) -> UIAlertController {
        return UIAlertController(title: title, message: message, preferredStyle: .alert)
    }
    
    func makeImageView(frame: CGRect, icon: String) -> UIImageView {
        let imageView = UIImageView(frame: CGRect(x: frame.width - 200, y: -8,
                                              width: 100, height: 80))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: icon)
        return imageView
    }
}
