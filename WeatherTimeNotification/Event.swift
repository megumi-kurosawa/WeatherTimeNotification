//
//  Event.swift
//  WeatherClock
//
//  Created by 黒沢めぐみ on 2018/10/26.
//  Copyright © 2018年 9630megumi. All rights reserved.
//

import Foundation

class Event: City {
    
    func getTime(formatter:DateFormatter) -> String {
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: alarmDate)
    }
    
    func getDate(formatter:DateFormatter) -> String {
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter.string(from: alarmDate)
    }
}
