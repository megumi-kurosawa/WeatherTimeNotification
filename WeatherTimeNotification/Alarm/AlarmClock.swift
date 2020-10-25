//
//  AlarmClock.swift
//  WeatherClock
//
//  Created by 黒沢めぐみ on 2018/11/10.
//  Copyright © 2018年 9630megumi. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class AlarmClock {

    public static let shared = AlarmClock()
    private static var sounds: Array<AlarmSound> = []
    
    deinit {
        AlarmClock.sounds.removeAll()
    }

    func sound(id: Int) {
        let sound = AlarmSound()
        AlarmClock.sounds.append(sound)
        AlarmClock.sounds.last?.play(id: id)
    }

    func play() {
        for sound in AlarmClock.sounds {
            sound.play()
        }
    }
    
    func pause() {
        for sound in AlarmClock.sounds {
            sound.stop()
        }
    }
    
    func stop() {
        for sound in AlarmClock.sounds {
            sound.stop()
        }
        AlarmClock.sounds.removeAll()
    }
}
