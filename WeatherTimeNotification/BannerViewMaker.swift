//
//  BannerView.swift
//  WeatherClock
//
//  Created by 黒沢めぐみ on 2018/11/25.
//  Copyright © 2018年 9630megumi. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

class BannerViewMaker {

    func makeBannerView(rootViewController: UIViewController) -> GADBannerView {
        let bannerView = GADBannerView(adSize: kGADAdSizeBanner)
        bannerView.translatesAutoresizingMaskIntoConstraints = false
        bannerView.isUserInteractionEnabled = true
        bannerView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        rootViewController.view.addSubview(bannerView)
        rootViewController.view.addConstraints([NSLayoutConstraint(item: bannerView,
                                                attribute: .bottom,
                                                relatedBy: .equal,
                                                toItem: rootViewController.view,
                                                attribute: .bottom,
                                                multiplier: 1,
                                                constant: -50),
                             NSLayoutConstraint(item: bannerView,
                                                attribute: .centerX,
                                                relatedBy: .equal,
                                                toItem: rootViewController.view,
                                                attribute: .centerX,
                                                multiplier: 1,
                                                constant: 0)
            ])
        // テスト用ID
        bannerView.adUnitID = "ca-app-pub-3940256099942544/2934735716"
        bannerView.rootViewController = rootViewController
        return bannerView
    }
}
