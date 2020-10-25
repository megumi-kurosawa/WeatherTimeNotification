//
//  DecisionButton.swift
//  WeatherClock
//
//  Created by 黒沢めぐみ on 2018/10/23.
//  Copyright © 2018年 9630megumi. All rights reserved.
//

import Foundation
import UIKit

class DecisionButton: UIButton {
    
    init(center:CGPoint) {
        super.init(frame: CGRect(x: center.x - 25,
                                 y: center.y + 240,
                                 width: 50,
                                 height: 48))
        setTitleColor(.blue, for: .normal)
        setTitleColor(.gray, for: .disabled)
        titleLabel?.font = .systemFont(ofSize: 32.0)
        setTitle("OK", for: UIControl.State())
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
