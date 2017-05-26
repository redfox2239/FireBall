//
//  ViewController.swift
//  gameApp
//
//  Created by 原田　礼朗 on 2017/05/26.
//  Copyright © 2017年 reo harada. All rights reserved.
//

import UIKit

let fireBallFrame = CGRect(x: 0, y: 0, width: 50, height: 50)
let landscapeFrame = CGRect(x: 0, y: 300, width: 400, height: 1)
var intervalTime = TimeInterval(1.0)

class ViewController: UIViewController {

    @IBOutlet weak var personImageView: UIImageView!
    @IBOutlet weak var pointLabel: UILabel!
    var timer: Timer!
    var point = 0
    @IBOutlet weak var countTimerLabel: UILabel!
    var count = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 地面の生成
        let landView = UIView(frame: CGRect(x: 0, y: 400, width: UIScreen.main.bounds.size.width, height: 10))
        landView.backgroundColor = UIColor.green
        view.addSubview(landView)
        
        setTimer()

        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.hittedFireBall), name: NSNotification.Name(rawValue: "hitFireBall"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.addPoint), name: NSNotification.Name(rawValue: "endMoveFireBall"), object: nil)

    }
    
    func setTimer() {
        self.countTimerLabel.isHidden = false
        self.countTimerLabel.text = "3"
        self.count = 3
        Timer.scheduledTimer(withTimeInterval: 0.7, repeats: true) { (countTimer) in
            self.count -= 1
            if self.count == 0 {
                self.countTimerLabel.text = "GO!!!"
            }
            else {
                self.countTimerLabel.text = "\(self.count)"
            }
            if self.count < 0 {
                countTimer.invalidate()
                self.countTimerLabel.isHidden = true
                self.timer = Timer.scheduledTimer(withTimeInterval: intervalTime, repeats: true, block: { (timer) in
                    // 火の玉を生成
                    let fireBall = fireBallImageView()
                    fireBall.targetView = self.personImageView
                    fireBall.setUp()
                    self.view.addSubview(fireBall)
                    // 火の玉が落ちてくる
                    fireBall.fallDown(0.5)
                })
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLayoutSubviews() {
        personImageView.frame.origin.y = 400 - personImageView.frame.size.height
    }
    
    var initTouchPoint = CGPoint(x: 0, y: 0)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //if let touchView = touches.first?.view {
            //if personImageView == touchView {
                if let touchPoint = touches.first?.location(in: view) {
                    initTouchPoint = touchPoint
                }
            //}
        //}
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isEnableMove {
            //if let touchView = touches.first?.view {
                //if personImageView == touchView {
                    if let movePoint = touches.first?.location(in: view) {
                        personImageView.frame.origin.x += movePoint.x - initTouchPoint.x
                        personImageView.frame.origin.y = 400 - personImageView.frame.size.height
                        if personImageView.frame.origin.x < 0 {
                            personImageView.frame.origin.x = 0
                        }
                        if personImageView.frame.origin.x > UIScreen.main.bounds.maxX - personImageView.frame.size.width {
                            personImageView.frame.origin.x = UIScreen.main.bounds.maxX - personImageView.frame.size.width
                        }
                        initTouchPoint = movePoint
                    }
                //}
            //}
        }
    }
    
    var isEnableMove = true
    func hittedFireBall() {
        oneMoreButton.isHidden = false
        isEnableMove = false
        personImageView.image = UIImage(named: "persondead")
        personImageView.contentMode = UIViewContentMode.scaleAspectFit
        timer.invalidate()
    }
    
    func addPoint() {
        if isEnableMove {
            point += 1
            pointLabel.text = "\(point)ポイント"
            print(intervalTime)
            if self.timer.isValid && point%10 == 0 {
                intervalTime -= 0.1
                if intervalTime >= 0.1 {
                    self.timer.invalidate()
                    self.timer = Timer.scheduledTimer(withTimeInterval: intervalTime, repeats: true, block: { (timer) in
                        // 火の玉を生成
                        let fireBall = fireBallImageView()
                        fireBall.targetView = self.personImageView
                        fireBall.setUp()
                        self.view.addSubview(fireBall)
                        // 火の玉が落ちてくる
                        fireBall.fallDown(0.5)
                    })
                }
            }
        }
    }

    @IBOutlet weak var oneMoreButton: UIButton!
    @IBAction func tapOneMoreButton(_ sender: Any) {
        oneMoreButton.isHidden = true
        if !timer.isValid {
            intervalTime = 1.0
            point = 0
            pointLabel.text = "0ポイント"
            personImageView.image = UIImage(named: "person")
            personImageView.contentMode = UIViewContentMode.scaleToFill
            isEnableMove = true
            setTimer()
        }
    }
    
}

class fireBallImageView: UIImageView {
    var targetView: UIImageView!
    var timer: Timer!
    
    func setUp() {
        // デバイスサイズ取得
        let screenSize = UIScreen.main.bounds.size
        let randomX = Int(arc4random()) % Int(screenSize.width - fireBallFrame.size.width)
        setPosition(CGFloat(randomX))
        // 画像の設定
        image = UIImage(named: "hinotama")
        contentMode = UIViewContentMode.scaleToFill
        // 衝突監視
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true, block: { (timer) in
            let targetFrame = self.targetView.frame
            if let presentaionFrame = self.layer.presentation()?.frame {
                if ((presentaionFrame.minX < targetFrame.minX && targetFrame.minX < presentaionFrame.maxX) && presentaionFrame.maxY > targetFrame.minY) ||
                    ((presentaionFrame.minX < targetFrame.maxX && targetFrame.maxX < presentaionFrame.maxX) && presentaionFrame.maxY > targetFrame.minY)
                    {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "hitFireBall"), object: nil)
                }
            }
        })
    }
    
    func setPosition(_ x: CGFloat) {
        frame = fireBallFrame
        frame.origin.x = x
        frame.origin.y = 0
    }
    
    func fallDown(_ time: TimeInterval) {
        UIView.animate(withDuration: time, animations: {
            self.frame.origin.y = landscapeFrame.origin.y + fireBallFrame.size.height
        }) { (animate) in
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "endMoveFireBall"), object: nil)
            self.timer.invalidate()
            self.removeFromSuperview()
        }
    }
    
}
