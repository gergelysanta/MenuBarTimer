//
//  MenuViewController.swift
//  MenuBarTimer
//
//  Created by Gergely Sánta on 18/05/2018.
//  Copyright © 2018 TriKatz. All rights reserved.
//

import Cocoa
import ProgressImage

class MenuViewController: NSViewController {
	
	@IBOutlet weak var progressImageView: ProgressImageView!
	@IBOutlet weak var progressLabel: NSTextField!
	@IBOutlet weak var startStopButton: NSButton!
	
	private var menuTimer:MenuTimer?
	
	private var _progress:CGFloat = 0.0
	var progress:CGFloat {
		get {
			return progressImageView.progress ?? 0.0
		}
		set {
			_progress = newValue
			if let progressView = progressImageView {
				progressView.progress = _progress
			}
			if let label = progressLabel {
				label.stringValue = String(format: "%.0f %%", _progress * 100.0)
			}
		}
	}
	
	// startTimerWithSeconds must be NSNumber because
	// binding can set also value nil when NSTextField is empty
	// In that case NSNumber will be 0
	@objc dynamic var startTimerWithSeconds:NSNumber = 30 {
		willSet {
			self.willChangeValue(for: \.timerAvailable)
		}
		didSet {
			NSLog("New value: \(startTimerWithSeconds)")
			self.didChangeValue(for: \.timerAvailable)
		}
	}
	
	@objc dynamic var timerAvailable:Bool {
		get {
			return startTimerWithSeconds.intValue > 0
		}
	}
	
	@objc dynamic var timerRunning:Bool {
		get {
			return menuTimer?.running ?? false
		}
	}
	
	init() {
		super.init(nibName: NSNib.Name("MenuView"), bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}
	
	override func viewWillAppear() {
		super.viewWillAppear()
		actualizeControls()
		progressImageView.progress = _progress
		progressLabel.stringValue = String(format: "%.0f %%", _progress * 100.0)
	}
	
	private func actualizeControls() {
		if let appDelegate = NSApp.delegate as? AppDelegate {
			menuTimer = appDelegate.menuTimer
			
			if let timer = menuTimer {
				if timer.running {
					startStopButton.state = timer.paused ? .off : .on
				}
				else {
					startStopButton.state = .off
				}
			}
		}
	}
	
	@IBAction func playPauseButtonPressed(_ sender: NSButton) {
		guard let timer = menuTimer else { return }
		
		if timer.running {
			timer.togglePause()
		}
		else {
			timer.start(forSeconds: CGFloat(startTimerWithSeconds.intValue))
		}
		
		actualizeControls()
	}
	
	@IBAction func stopButtonPressed(_ sender: NSButton) {
		guard let timer = menuTimer else { return }
		
		timer.stop()
		progress = timer.progress
		
		actualizeControls()
	}
	
	func configurationView(show: Bool) {
		let foundConstraints = view.constraints.filter { $0.identifier == "foldingConstraint" }
		if let constraint = foundConstraints.first {
			DispatchQueue.main.async {
				constraint.priority = show ? .defaultLow : NSLayoutConstraint.Priority(999)
			}
		}
	}
	
}

extension MenuViewController: NSTextFieldDelegate {
	
	override func controlTextDidChange(_ obj: Notification) {
		NSLog("\(obj)")
	}
	
}
