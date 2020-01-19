//
//  MainViewController.swift
//  Arkanoid
//
//  Created by Damon Cricket on 17.01.2020.
//  Copyright © 2020 DC. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, EmiterDelegate {
    
    struct Constants {
        struct Platform {
            static let width: CGFloat = 150.0
            static let height: CGFloat = 15.0
        }
        struct Ball {
            static let size: CGFloat = 30.0
        }
    }
    
    enum PlatformDirection {
        case left
        case right
    }
    
    @IBOutlet weak var blindView: UIView?
    
    @IBOutlet weak var startButton: UIButton?
    

    var platformView: UIView = UIView()
    
    var ballView: UIView = UIView()
    
    var blockViews: [UIView] = []

    var emiter: Emiter = Emiter()
    
    
    var platformDirection: PlatformDirection = .left

    override func viewDidLoad() {
        super.viewDidLoad()
        
        startButton?.layer.borderColor = UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0).cgColor
        startButton?.layer.borderWidth = 3.0
        startButton?.layer.cornerRadius = 3.0

        let platformX = (view.bounds.width - Constants.Platform.width) / 2.0
        let platformY = view.bounds.height - Constants.Platform.height - 30.0
        platformView.frame = CGRect(x: platformX, y: platformY, width: Constants.Platform.width, height: Constants.Platform.height)
        platformView.backgroundColor = .black
        view.addSubview(platformView)
        
        landBall()
        ballView.backgroundColor = .red
        view.addSubview(ballView)
        
        emiter.view = ballView
        emiter.interval = 0.005
        emiter.direction = EmiterConstants.Direction.leftUp
        emiter.delegate = self

        var lastX: CGFloat = 0.0
        var lastY: CGFloat = UIApplication.shared.statusBarFrame.height
        for _ in 0 ..< 6 {
            let count = 5
            lastX = 0.0
            for _ in 0 ... count {
                let blockWidth = view.bounds.width / CGFloat(count)
                let blockView = UIView(frame: CGRect(x: lastX, y: lastY , width: blockWidth, height: 20.0))
                lastX = blockView.frame.maxX
                blockView.backgroundColor = .blue
                blockViews.append(blockView)
                view.addSubview(blockView)
            }
            let last = blockViews.last!
            lastY = last.frame.maxY
        }
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureRecognizer(recognizer:)))
        view.addGestureRecognizer(panGestureRecognizer)
    }
    
    @objc func panGestureRecognizer(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: view)
        let velocity = recognizer.velocity(in: view)
        platformDirection = velocity.x > 0 ? .right : .left

        let delta = ballView.frame.minX - platformView.frame.minX
        
        let platformX = platformView.frame.minX
        let platformMaxX = platformView.frame.maxX
        let platformY = platformView.frame.minY
        let width = view.bounds.width
        
        platformView.center = CGPoint(x: location.x, y: platformView.center.y)

        if platformView.frame.minX < 0.0 {
            platformView.frame = CGRect(x: 0.0, y: platformY, width: Constants.Platform.width, height: Constants.Platform.height)
        } else if platformView.frame.maxX > width {
            platformView.frame = CGRect(x: width - Constants.Platform.width, y: platformY, width: Constants.Platform.width, height: Constants.Platform.height)
        }
        
        if ballView.frame.maxY == platformY && ballView.frame.maxX >= platformX && ballView.frame.minX <= platformMaxX {
            let ballX = platformView.frame.minX + delta
            ballView.frame = CGRect(x: ballX, y: ballView.frame.minY, width: Constants.Ball.size, height: Constants.Ball.size)
            switch platformDirection {
            case .left:
                emiter.direction = EmiterConstants.Direction.leftUp
            case .right:
                emiter.direction = EmiterConstants.Direction.rightUp
            }
        }
    }
    
    @IBAction func startButtonTap(sender: UIButton) {
        blindView?.isHidden = true
        emiter.direction = EmiterConstants.Direction.leftUp
        emiter.start()
    }
    
    func emiter(_ emiter: Emiter, didMoveView v: UIView) {
        let vX = v.frame.minX
        let vY = v.frame.minY
        let vMaxX = v.frame.maxX
        let bounds = view.bounds
        
        if vX <= 0.0 {
            if emiter.direction == EmiterConstants.Direction.leftUp {
                emiter.direction = EmiterConstants.Direction.rightUp
            } else {
                emiter.direction = EmiterConstants.Direction.rightDown
            }
        } else if vY <= 0.0 {
            if emiter.direction == EmiterConstants.Direction.leftUp {
                emiter.direction = EmiterConstants.Direction.leftDown
            } else {
                emiter.direction = EmiterConstants.Direction.rightDown
            }
        } else if vMaxX >= bounds.width {
            if emiter.direction == EmiterConstants.Direction.rightUp {
                emiter.direction = EmiterConstants.Direction.leftUp
            } else {
                emiter.direction = EmiterConstants.Direction.leftDown
            }
        } else if v.frame.maxY == platformView.frame.minY && v.frame.maxX >= platformView.frame.minX && v.frame.minX <= platformView.frame.maxX {
            emiter.pause(seconds: 1.0)
            if emiter.direction == EmiterConstants.Direction.rightDown {
                emiter.direction = EmiterConstants.Direction.rightUp
            } else {
                emiter.direction = EmiterConstants.Direction.leftUp
            }
        } else if v.frame.maxY >= bounds.height {
            emiter.stop()
            blindView?.isHidden = false
            landBall()
        }
    }
    
    func landBall() {
        let ballX = platformView.center.x - Constants.Ball.size / 2.0
        let ballY = platformView.frame.origin.y - Constants.Ball.size
        ballView.frame = CGRect(x: ballX, y: ballY, width: Constants.Ball.size, height: Constants.Ball.size)
    }
}
