//
//  CityNews.swift
//  WeatherClock
//
//  Created by 黒沢めぐみ on 2018/11/26.
//  Copyright © 2018年 9630megumi. All rights reserved.
//

import Foundation

class CityNews {
    
    var cityName: String
    
    struct NewsList: Codable {
        let kind: String
        let items: [Item]
        struct Item: Codable {
            let title: String
            let link: String
            let snippet: String
            var pagemap: PageMap! = nil
            struct PageMap: Codable {
                var cse_thumbnail: [Thumbnail]? = nil
                struct Thumbnail: Codable {
                    var src: String = ""
                }
            }
        }
    }
    struct News {
        let title: String
        let description: String
        let url: URL
        let thumbnail: String
    }
    var news = [News]()
    
    init(cityName: String) {
        self.cityName = cityName.replacingOccurrences(of: " ", with: "", options: .literal, range: nil)
        requestWebAPI()
    }

    // Web APIに情報をリクエストする
    func requestWebAPI() {
        // 天気の情報を取得するURLを作成
        guard let req_url = URL(string: "https://www.googleapis.com/customsearch/v1?q=\(cityName)&num=10&cx=000805348079889578920:beuacozlbdi&key=AIzaSyCbFZe0glPIMrUmrriH-8Njlk5b5Uc4mXA") else {
            return
        }
        print(req_url)
        
        // URLリクエストを作成
        let req = URLRequest(url: req_url)
        // タスクに登録するセッションを作成
        let session = URLSession(configuration: .default,
                                 delegate: nil,
                                 delegateQueue: OperationQueue.main)
        // セッションにリクエストをタスクに登録
        let task = session.dataTask(with: req, completionHandler: { (data, response, error) in
            // セッションを終了
            session.finishTasksAndInvalidate()
            do {
                // JSONデータのデコーダーを生成
                let decorder = JSONDecoder()
                // 受け取ったJSONデータをパース(解析)して格納
                let json = try decorder.decode(NewsList.self, from: data!)
                // データを取得できているか確認する
                let items: [NewsList.Item] = json.items
                for item in items {
                    let title = item.title
                    let description = item.snippet
                    guard let url = URL(string: item.link) else { return }
                    var thumbnail: String! = ""
                    if item.pagemap != nil {
                        if item.pagemap.cse_thumbnail != nil {
                            thumbnail = item.pagemap.cse_thumbnail!.first?.src
                        }
                    }
                    print(thumbnail)
                    let news = News(title: title, description: description, url: url, thumbnail: thumbnail)
                    self.news.append(news)
                    print("ニュースをダウンロードしました")
                }
            } catch {
                // エラー処理
                print("JSONデータの解析に失敗しました from CityNews.swift")
                print(error)
            }
        })
        // ダウンロード開始
        task.resume()
    }
}
