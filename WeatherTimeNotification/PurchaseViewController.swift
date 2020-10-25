//
//  PurchaseViewController.swift
//  WeatherClock
//
//  Created by 黒沢めぐみ on 2018/12/10.
//  Copyright © 2018年 9630megumi. All rights reserved.
//

import UIKit
import StoreKit

class PurchaseViewController: UIViewController, PurchaseManagerDelegate {

    private var priceLabel: UILabel!
    private var purchaseButton: UIButton!
    private let productIdentifiers : [String] = ["com.9630megumi.WeatherClock"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let center = view.center
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        priceLabel = UILabel(frame: CGRect(x: center.x - 130, y: statusBarHeight + 50,
                                           width: 260, height: 60))
        priceLabel.textAlignment = .center
        priceLabel.font = UIFont.systemFont(ofSize: 32)
        priceLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        purchaseButton = UIButton(frame: CGRect(x: center.x - 50, y: center.y + 120,
                                                width: 100, height: 60))
        purchaseButton.setTitle("Purchase", for: UIControl.State())
        purchaseButton.setTitleColor(#colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1), for: UIControl.State())
        purchaseButton.backgroundColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        purchaseButton.layer.cornerRadius = 15.0
        purchaseButton.clipsToBounds = true
        let closeButton = UIButton(type: .custom)
        closeButton.frame = CGRect(x: view.frame.maxX - 30, y: statusBarHeight,
                                   width: 30, height: 30)
        closeButton.setTitleColor(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1), for: .normal)
        closeButton.setTitleColor(#colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1), for: .selected)
        closeButton.setTitle("×", for: UIControl.State())
        closeButton.layer.cornerRadius = 8.0
        closeButton.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        closeButton.layer.borderWidth = 1.0
        closeButton.clipsToBounds = true
        closeButton.addTarget(self, action: #selector(closeButtonAction), for: .touchUpInside)
        closeButton.isEnabled = true
        view.addSubview(priceLabel)
        view.addSubview(purchaseButton)
        view.addSubview(closeButton)
        startPurchase(productIdentifier: productIdentifiers[0])
    }

    /////////////////////////////////////////
    // 購入処理                              //
    /////////////////////////////////////////
    
    //------------------------------------
    // 課金処理開始
    //------------------------------------
    func startPurchase(productIdentifier : String) {
        print("課金処理開始!!")
        //デリゲード設定
        PurchaseManager.sharedManager().delegate = self
        //プロダクト情報を取得
        ProductManager.productsWithProductIdentifiers(productIdentifiers: [productIdentifier], completion: { (products, error) -> Void in
            if (products?.count)! > 0 {
                //課金処理開始
                PurchaseManager.sharedManager().startWithProduct((products?[0])!)
            }
            if (error != nil) {
                print(error!.localizedDescription)
            }
        })
    }
    // リストア開始
    func startRestore() {
        //デリゲード設定
        PurchaseManager.sharedManager().delegate = self
        //リストア開始
        PurchaseManager.sharedManager().startRestore()
    }
    
    //------------------------------------
    // MARK: - PurchaseManager Delegate
    //------------------------------------
    //課金終了時に呼び出される
    func purchaseManager(_ purchaseManager: PurchaseManager!, didFinishPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((_ complete: Bool) -> Void)!) {
        print("課金終了！！")
        //---------------------------
        // コンテンツ解放処理
        //---------------------------
        // TODO UserDefault更新
        //コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(true)
    }
    //課金終了時に呼び出される(startPurchaseで指定したプロダクトID以外のものが課金された時。)
    func purchaseManager(_ purchaseManager: PurchaseManager!, didFinishUntreatedPurchaseWithTransaction transaction: SKPaymentTransaction!, decisionHandler: ((_ complete: Bool) -> Void)!) {
        print("課金終了（指定プロダクトID以外）！！")
        //---------------------------
        // コンテンツ解放処理
        //---------------------------
        //コンテンツ解放が終了したら、この処理を実行(true: 課金処理全部完了, false 課金処理中断)
        decisionHandler(true)
    }
    //課金失敗時に呼び出される
    func purchaseManager(_ purchaseManager: PurchaseManager!, didFailWithError error: NSError!) {
        print("課金失敗！！")
        // TODO errorを使ってアラート表示
    }
    // リストア終了時に呼び出される(個々のトランザクションは”課金終了”で処理)
    func purchaseManagerDidFinishRestore(_ purchaseManager: PurchaseManager!) {
        print("リストア終了！！")
        // TODO インジケータなどを表示していたら非表示に
    }
    // 承認待ち状態時に呼び出される(ファミリー共有)
    func purchaseManagerDidDeferred(_ purchaseManager: PurchaseManager!) {
        print("承認待ち！！")
        // TODO インジケータなどを表示していたら非表示に
    }
    
    // プロダクト情報取得
    fileprivate func fetchProductInformationForIds(_ productIds:[String]) {
        ProductManager.productsWithProductIdentifiers(productIdentifiers: productIds,completion: {[weak self] (products : [SKProduct]?, error : NSError?) -> Void in
            if error != nil {
                if self != nil {
                }
                print(error?.localizedDescription)
                return
            }
            for product in products! {
                let priceString = ProductManager.priceStringFromProduct(product: product)
                if self != nil {
                    print(product.localizedTitle + ":\(priceString)")
                    self?.priceLabel.text = product.localizedTitle + ":\(priceString)"
                }
                print(product.localizedTitle + ":\(priceString)" )
            }
        })
    }
    
    /////////////////////////////////////////
    // ボタンアクション                       //
    /////////////////////////////////////////
    
    @objc func closeButtonAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
