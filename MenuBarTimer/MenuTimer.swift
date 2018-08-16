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
	func timerEnded(timer:MenuTimer)
	func timerStarted(timer:MenuTimer)
	func timerStopped(timer:MenuTimer)
	func timerPauseToggled(timer:MenuTimer, paused:Bool)
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
	
	private(set) var secondsTotal:Int = 0
	var secondsLeft:Int {
		return iterationsLeft / iterationsPerSecond
	}
	
	@discardableResult func start(forSeconds interval:Int) -> Bool {
		if running {
			stop()
		}
		
		secondsTotal = interval
		iterationsLeft = Int(CGFloat(interval)/precision)
		
		progress = 0.0
		progressIncrement = 1.0 / CGFloat(iterationsLeft)
		
		innerTimer = Timer.scheduledTimer(timeInterval: TimeInterval(precision),
										  target: self,
										  selector: #selector(timerTick(_:)),
										  userInfo: nil,
										  repeats: true)

		self.delegate?.timerStarted(timer: self)
		return true
	}
	
	func stop() {
		if running {
			innerTimer?.invalidate()
			innerTimer = nil
			progress = 0.0
			self.delegate?.timerStopped(timer: self)
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
		self.delegate?.timerPauseToggled(timer: self, paused: paused)
	}
	
	@objc private func timerTick(_ timer: Timer) {
		self.iterationsLeft -= 1
		self.progress += self.progressIncrement
		self.delegate?.tick(timer: self)
		
		if self.iterationsLeft <= 0 {
			innerTimer?.invalidate()
			innerTimer = nil
			self.delegate?.timerEnded(timer: self)
		}
	}
	
}
