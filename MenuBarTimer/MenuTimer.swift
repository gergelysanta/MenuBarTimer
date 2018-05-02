//
//  MenuTimer.swift
//  MenuBarTimer
//
//  Created by Gergely Sánta on 02/05/2018.
//  Copyright © 2018 TriKatz. All rights reserved.
//

import Foundation

protocol MenuTimerDelegate {
	func tick(timer:MenuTimer)
}

class MenuTimer {
	
	var delegate:MenuTimerDelegate?
	
	var running:Bool {
		get {
			return (innerTimer == nil) ? false : true
		}
	}
	
	var paused:Bool {
		get {
			return !(innerTimer?.isValid ?? true)
		}
	}
	
	var iterationsPerSecond:Int {
		get {
			return Int(1.0/precision)
		}
		set {
			precision = 1.0/CGFloat(iterationsPerSecond)
		}
	}
	
	private(set) var progress:CGFloat = 0.0
	
	private var precision:CGFloat = 0.01
	private var progressIncrement:CGFloat = 0.0
	
	private var iterationsLeft:Int = 0
	private var innerTimer:Timer?
	
	@discardableResult func start(forSeconds interval:CGFloat) -> Bool {
		if running {
			stop()
		}
		
		iterationsLeft = Int(interval/precision)
		
		progress = 0.0
		progressIncrement = 1.0 / CGFloat(iterationsLeft)
		
		innerTimer = Timer.scheduledTimer(timeInterval: TimeInterval(precision),
										  target: self,
										  selector: #selector(timerTick(_:)),
										  userInfo: nil,
										  repeats: true)

		return true
	}
	
	func stop() {
		if running {
			innerTimer?.invalidate()
			innerTimer = nil
			progress = 0.0
		}
	}
	
	func togglePause() {
		if paused {
			innerTimer = Timer.scheduledTimer(timeInterval: TimeInterval(precision),
											  target: self,
											  selector: #selector(timerTick(_:)),
											  userInfo: nil,
											  repeats: true)
		}
		else {
			innerTimer?.invalidate()
		}
	}
	
	@objc private func timerTick(_ timer: Timer) {
		self.iterationsLeft -= 1
		self.progress += self.progressIncrement
		self.delegate?.tick(timer: self)
		
		if self.iterationsLeft <= 0 {
			timer.invalidate()
		}
	}
	
}
