//
//  CityListLoader.swift
//  WeatherClock
//
//  Created by 黒沢めぐみ on 2018/10/24.
//  Copyright © 2018年 9630megumi. All rights reserved.
//

import Foundation
import UIKit

class CityList {

/*    // 検索先cityリストのJSONファイル読み込み用構造体
    // 緯度・経度の構造体
    struct CoordJson: Codable {
        var lon: Float = 0.0
        var lat: Float = 0.0
    }
    struct CityJson: Codable {
        let id: Int?
        let name: String?
        let country: String?
        let coord: CoordJson?
    }*/
    
    // 現在地からの地名取得JSONファイル読み込み用構造体
    struct MapsJson: Codable {
        let result: ResultJson
        struct ResultJson: Codable {
            let address_components: [AddressJson]!
            struct AddressJson: Codable {
                let long_name: String
                let short_name: String
            }
            let geometry: GeometryJson
            struct GeometryJson: Codable {
                let location: LocationJson
                struct LocationJson: Codable {
                    let lat: Double
                    let lng: Double
                }
            }
        }
    }

    // 距離での並べ替え用
    struct Place {
        let distance: Double
        let city: CityList.City
    }
    
    // 検索結果
    struct Coord {
        let lat: Double?
        let lon: Double?
    }
    // 検索結果の表示用構造体
    struct City {
        let id: Int!
        let name: String?
        let country: String?
        let coord: Coord?
    }
    // 検索先cityリスト
    static var searchCityList = [CityList.City]()

    // cityリストを準備
    static func load() {
        // ファイルを開くパスを作成
        guard let csvPath : String = Bundle.main.path(forResource: "city.list", ofType: "csv")
            else { return }
        do {
            let csvStr = try String(contentsOfFile: csvPath, encoding: .utf8)
            let csvArr = csvStr.components(separatedBy: .newlines)
            for str in csvArr {
                let strArr = str.components(separatedBy: ",")
                let id: Int = Int(NSString(string: strArr[0]).intValue)
                let Name: String = strArr[1]
                let name = Name.lowercased()
                let country: String = strArr[2]
                let lat: Double = NSString(string: strArr[3]).doubleValue
                let lon: Double = NSString(string: strArr[4]).doubleValue
                let coord = Coord(lat: lat, lon: lon)
                let city = CityList.City(id: id, name: name, country: country, coord: coord)
                CityList.searchCityList.append(city)
            }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
/*        // ファイルを開くパスを作成
        guard let path : String = Bundle.main.path(forResource: "city.list", ofType: "json")
            else { return }
        // パスからURLを作成
        let url = URL(fileURLWithPath: path)
        // ファイルを開いてデータを読み込み
        var data: Data?
        do {
            data = try Data(contentsOf: url)
        } catch {
            print("ファイルが開けません")
            print(error)
            return
        }
        
        // JSONデータを読み込む
        do {
            // JSONデータのデコーダーを生成
            let decorder = JSONDecoder()
            // 受け取ったJSONデータをパース(解析)して格納
            let json = try decorder.decode([CityJson].self, from: data!)
            
            // 取得しているidの数を処理
            let count = json.count
            if count > 0 {
                for n in 0...count - 1 {
                    // id、地名、国をアンラップ
                    if let id = json[n].id, let Name = json[n].name,
                        let country = json[n].country, let lon = json[n].coord?.lon, let lat = json[n].coord?.lat {
                        // city名を検索時に使いやすいように小文字で保存
                        let name = Name.lowercased()
                        let coord = Coord(lat: lat, lon: lon)
                        // １つのidの情報をまとめて管理
                        let city = CityList.City(id: id, name: name, country: country, coord: coord)
                        // idリストへ追加
                        searchCityList.append(city)
                    }
                }
            }
        } catch {
            print("JSONデータの読み込みに失敗しました")
            print(error)
        }*/
    }
    
    // 文字列を含む地名を配列で返す
    func searchCity (_ text: String) -> Array<City> {
        
        var resultCities: Array<City> = []
        // 文字列を検索しやすいように小文字で揃える
        let searchWord = text.lowercased()
        
        // 検索結果配列に情報を格納する
        // cityリストの要素を確認する
        for city in CityList.searchCityList {
            // 検索キーを含む地名を検索する
            if city.name!.hasPrefix(searchWord) {
                // 先頭文字だけ大文字に変換
                let name = city.name
                let Name = name!.prefix(1).uppercased() + name!.dropFirst()
                let city = CityList.City(id: city.id, name: Name, country: city.country,
                                coord: Coord(lat: city.coord?.lat, lon: city.coord?.lon))
                resultCities.append(city)
            }
        }
        return resultCities
    }
    
    // 国コードが一致する地名を配列で返す
    private func searchCountry(_ country: String) -> Array<City> {

        var resultCities: Array<City> = []
        // 検索結果配列に情報を格納する
        // cityリストの要素を確認する
        for city in CityList.searchCityList {
            // 検索キーを含む地名を検索する
            if city.country == country {
                let city = CityList.City(id: city.id, name: city.name, country: city.country,
                                         coord: Coord(lat: city.coord?.lat, lon: city.coord?.lon))
                resultCities.append(city)
            }
        }
        return resultCities
    }

    // 現在地の地名と重なる地名を配列で返す
    private func searchNearCity(searchCityNames: Array<String>, countryCities: Array<City>) -> Array<City> {
        
        var resultCities: Array<City> = []
        
        // 文字列を検索しやすいように小文字で揃える
        var searchcitynames: Array<String> = []
        for city in searchCityNames {
            searchcitynames.append(city.lowercased())
        }
        
        // 検索結果配列に情報を格納する
        // cityリストの要素を確認する
        for city in countryCities {
            for cityname in searchcitynames {
                if city.name == cityname || city.name!.hasPrefix(cityname) || cityname.hasPrefix(city.name!) {
                    // 先頭文字だけ大文字に変換
                    let name = city.name
                    let Name = name!.prefix(1).uppercased() + name!.dropFirst()
                    let city = CityList.City(id: city.id, name: Name, country: city.country,
                                             coord: Coord(lat: city.coord?.lat, lon: city.coord?.lon))
                    resultCities.append(city)
                    break
                }
            }
        }
        return resultCities
    }
    
    // 地名を近い順に並べ替えて配列で返す
    private func sortNearCities(lat: Double, lon: Double, cities: Array<City>) -> Array<City> {
        
        // 距離の近い順に並べる
        var places: Array<CityList.Place> = []
        for city in cities {
            let lat2 = pow(city.coord!.lat! - lat, 2.0)
            let lon2 = pow(city.coord!.lon! - lon, 2.0)
            let distance = sqrt(lat2 + lon2)
            let place = CityList.Place(distance: distance, city: city)
            places.append(place)
        }
        places.sort(by: {$0.distance < $1.distance})
        var sorted: Array<City> = []
        for place in places {
            sorted.append(place.city)
        }
        // 重複する地名を削除する
        var deleteIndex: Array<Int> = []
        for n in 0 ..< places.count {
            for m in n + 1 ..< places.count {
                if places[n].city.name == places[m].city.name {
                    if deleteIndex.contains(m) == false {
                        deleteIndex.append(m)
                    }
                }
            }
        }
        if deleteIndex.count > 0 {
            var counter = deleteIndex.count - 1
            repeat {
                sorted.remove(at: deleteIndex[counter])
                counter -= 1
            } while counter >= 0
        }
        // 検索上位3件を残して削除する
        if sorted.count > 3 {
            for _ in 3 ..< sorted.count {
                sorted.remove(at: 3)
            }
        }
        
        return sorted
    }
    
    // placeIDから近隣の地名を近い順に配列で返す
    func searchCityFromDownloadData(_ session: URLSession, didReceive data: Data) -> Array<City> {
        
        var resultCities: Array<City> = []
        // セッションを終了
        session.finishTasksAndInvalidate()
        do {
            // JSONデータのデコーダーを生成
            let decorder = JSONDecoder()
            // 受け取ったJSONデータをパース(解析)して格納
            let json = try decorder.decode(MapsJson.self, from: data)
            
            // 情報が取得できているか確認
            if json.result.address_components != nil {
                if json.result.address_components!.count > 0 {
                    let countryNumber: Int = json.result.address_components!.count - 2
                    let country = json.result.address_components![countryNumber].short_name
                    let countryCities = self.searchCountry(country)
                    var names: Array<String> = []
                    for n in 0 ..< countryNumber {
                        names.append(json.result.address_components[n].long_name)
                    }
                    let nearCities = self.searchNearCity(searchCityNames: names,
                                                         countryCities: countryCities)
                    resultCities = self.sortNearCities(lat: json.result.geometry.location.lat,
                                                       lon: json.result.geometry.location.lng,
                                                       cities: nearCities)
                } else {
                    print("地域情報を読み取れません")
                }
            }
        } catch {
            // エラー処理
            print("JSONデータの解析に失敗しました from CityList.swift")
            print(error)
        }
        return resultCities
    }
    
    func requestWebAPIFromPlaceId(delegate: URLSessionDelegate, placeID: String) {

        // 場所の情報を取得するURLを作成
        guard let req_url = URL(string: "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeID)&language=en&key=AIzaSyCbFZe0glPIMrUmrriH-8Njlk5b5Uc4mXA") else {
            return
        }
        print(req_url)
        
        // URLリクエストを作成
        let req = URLRequest(url: req_url)
        // タスクに登録するセッションを作成
        let session = URLSession(configuration: .default,
                                 delegate: delegate,
                                 delegateQueue: OperationQueue.main)
        // セッションにリクエストをタスクに登録
        let task = session.dataTask(with: req)
        // ダウンロード開始
        task.resume()
    }
}
