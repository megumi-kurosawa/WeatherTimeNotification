//
//  WeatherCell.swift
//  WeatherClock
//
//  Created by 黒沢めぐみ on 2018/10/23.
//  Copyright © 2018年 9630megumi. All rights reserved.
//

import UIKit

class WeatherCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Cellに設置したオブジェクトを取得する
        let imageView = viewWithTag(1) as! UIImageView
        let cityLabel = viewWithTag(2) as! UILabel
        let countryLabel = viewWithTag(3) as! UILabel
        let weatherLabel = viewWithTag(4) as! UILabel
        let descriptionLabel = viewWithTag(5) as! UILabel
        let temperatureLabel = viewWithTag(6) as! UILabel
        
        imageView.image = nil
        cityLabel.text = nil
        countryLabel.text = nil
        weatherLabel.text = nil
        descriptionLabel.text = nil
        temperatureLabel.text = nil
    }
}
