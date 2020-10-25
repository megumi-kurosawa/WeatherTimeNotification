//
//  AlarmSound.swift
//  WeatherClock
//
//  Created by 黒沢めぐみ on 2018/11/09.
//  Copyright © 2018年 9630megumi. All rights reserved.
//

import Foundation
import AVFoundation

class AlarmSound {
    
    private var player: AVAudioPlayer!
    static let soundList = ["01_alarm01",
                            "02_alarm02",
                            "03_bell",
                            "04_cock-a-doodle-doo",
                            "05_bird",
                            "06_birds",
                            "07_music_box01",
                            "08_music_box02",
                            "09_healing01",
                            "10_healing02",
                            "11_siren01",
                            "12_siren02",
                            "13_clapping-hands"]
    
    func play(id: Int) {
        // ファイルを開くパスを作成
        guard let path : String = Bundle.main.path(forResource: AlarmSound.soundList[id], ofType: "caf") else { return }
        // パスからURLを作成
        let url = URL(fileURLWithPath: path)
        // ファイルを開いてデータを読み込み
        var data: Data!
        do {
            data = try Data(contentsOf: url)
        } catch {
            print("ファイルが開けません")
            print(error)
            return
        }
        do {
            player = try AVAudioPlayer(data: data)
            player.enableRate = true
            player.prepareToPlay()
            player.rate = 1.0
            player.play()
        } catch { fatalError("サウンドプレイヤーを作成できません") }
    }
    
    func play() {
        if player != nil {
            player.play()
        }
    }
    
    func stop() {
        if player != nil {
            player.pause()
        }
    }
    
    func isPlaing() -> Bool {
        if player != nil {
            return player.isPlaying
        } else {
            return false
        }
    }
}
