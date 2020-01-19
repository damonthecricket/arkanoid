//
//  Emiter.swift
//  Arkanoid
//
//  Created by Damon Cricket on 17.01.2020.
//  Copyright © 2020 DC. All rights reserved.
//

import Foundation
import UIKit

struct EmiterDirection: Equatable {
    let x: CGFloat
    let y: CGFloat
    init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }
    static func ==(lhs: EmiterDirection, rhs: EmiterDirection) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}

struct EmiterConstants {
    struct Direction {
        static let leftUp = EmiterDirection(x: CGFloat(-1.0), y:  CGFloat(-1.0))
        static let rightUp = EmiterDirection(x: CGFloat(1.0), y: CGFloat(-1.0))
        static let rightDown = EmiterDirection(x: CGFloat(1.0), y: CGFloat(1.0))
        static let leftDown = EmiterDirection(x: CGFloat(-1.0), y: CGFloat(1.0))
    }
}

protocol EmiterDelegate: class {
    func emiter(_ emiter: Emiter, didMoveView view: UIView)
}

class Emiter {
    weak var delegate: EmiterDelegate?
    
    var direction: EmiterDirection? = nil
    
    var interval: TimeInterval = 0.0
    
    var view: UIView? = nil
    
    var timer: Timer? = nil

    deinit {
        stop()
        direction = nil
        view = nil
    }
    
    func start() {
        startTimer()
    }
    
    func pause(seconds: TimeInterval) {
        stop()
        Timer.scheduledTimer(timeInterval: seconds, target: self, selector: #selector(pauseTimerTick(timer:)), userInfo: nil, repeats: false)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(viewTimerTick(timer:)), userInfo: nil, repeats: true)
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc func viewTimerTick(timer: Timer) {
        let viewX = view!.frame.minX + direction!.x
        let viewY = view!.frame.minY + direction!.y
        view?.frame = CGRect(x: viewX, y: viewY, width: view!.frame.width, height: view!.frame.height)
        delegate?.emiter(self, didMoveView: view!)
    }
    
    @objc func pauseTimerTick(timer: Timer) {
        startTimer()
    }
}
