//
//  SearchResultTableView.swift
//  WeatherClock
//
//  Created by 黒沢めぐみ on 2018/10/22.
//  Copyright © 2018年 9630megumi. All rights reserved.
//

import UIKit

class SearchResultTableView: UITableView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        autoresizingMask = [.flexibleHeight]
//        autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /////////////////////////////////////////
    // スワイプアクション                      //
    /////////////////////////////////////////
    
    // テーブルビューのジェスチャと併用するため、trueを返す
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
