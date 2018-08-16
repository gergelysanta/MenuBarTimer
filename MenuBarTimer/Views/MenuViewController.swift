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
	@IBOutlet weak var basicConfigurationConstraint: NSLayoutConstraint!
	@IBOutlet weak var mainConstraint: NSLayoutConstraint!
	
	// Preferences
	@IBOutlet weak var prefsTrayTypeCheckboxesView: NSView!
	@IBOutlet weak var prefsImageHorizontal: ProgressImageView!
	@IBOutlet weak var prefsImageVertical: ProgressImageView!
	@IBOutlet weak var prefsImagePie: ProgressImageView!
	@IBOutlet weak var prefsImageArc: ProgressImageView!
	
	private var menuTimer:MenuTimer?
	private var prefsImagesAnimationTimer:Timer?

	private let allHiddenHeight:CGFloat = 8.0
	private var basicConfigurationHeight:CGFloat = 0.0
	private var wholeConfigurationHeight:CGFloat = 0.0

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
			Configuration.shared.timerSeconds = startTimerWithSeconds.intValue
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
	
	private func getComponent(identifier: String) -> NSView? {
		let components = prefsTrayTypeCheckboxesView.subviews.filter { $0.identifier?.rawValue == identifier }
		return components.first
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		startTimerWithSeconds = NSNumber(integerLiteral: Configuration.shared.timerSeconds)
		
		basicConfigurationHeight = basicConfigurationConstraint.constant + allHiddenHeight
		wholeConfigurationHeight = mainConstraint.constant
		
		mainConstraint.constant = basicConfigurationHeight
		
		prefsImageHorizontal.type = .horizontal
		prefsImageVertical.type = .vertical
		prefsImagePie.type = .pie
		prefsImageArc.type = .arc
		
		switch Configuration.shared.trayType {
		case 1:
			(getComponent(identifier: "trayTypeVertical") as? NSButton)?.state = .on
		case 2:
			(getComponent(identifier: "trayTypePie") as? NSButton)?.state = .on
		case 3:
			(getComponent(identifier: "trayTypeArc") as? NSButton)?.state = .on
		default:
			(getComponent(identifier: "trayTypeHorizontal") as? NSButton)?.state = .on
		}
	}
	
	private func animatePreferencesImages(_ animate: Bool) {
		if animate && (prefsImagesAnimationTimer != nil) {
			// Animation already running
			return
		}
		else if !animate && (prefsImagesAnimationTimer == nil) {
			// Animation already stopped
			return
		}
		
		if animate {
			NSLog("Start animation")
			var increment:CGFloat = 0.01
			prefsImagesAnimationTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { (timer) in
				guard var progress = self.prefsImageHorizontal.progress else { return }
				
				progress += increment
				if ((increment > 0) && (progress >= 1.0)) ||
					((increment < 0) && (progress <= 0.0))
				{
					increment *= -1
				}
				
				self.prefsImageHorizontal.progress = progress
				self.prefsImageVertical.progress = progress
				self.prefsImagePie.progress = progress
				self.prefsImageArc.progress = progress
			}
		}
		else {
			NSLog("Stop animation")
			prefsImagesAnimationTimer?.invalidate()
			prefsImagesAnimationTimer = nil
		}
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
			timer.start(forSeconds: Configuration.shared.timerSeconds)
		}
		
		actualizeControls()
	}
	
	@IBAction func stopButtonPressed(_ sender: NSButton) {
		guard let timer = menuTimer else { return }
		
		timer.stop()
		progress = timer.progress
		
		actualizeControls()
	}
	
	@IBAction func preferencesButtonPressed(_ sender: NSButton) {
		DispatchQueue.main.async {
			if self.mainConstraint.constant > self.basicConfigurationHeight {
				// Advanced configuration is displayed, go to basic config only
				NSAnimationContext.runAnimationGroup({ (context) in
					self.mainConstraint.animator().constant = self.basicConfigurationHeight
				}, completionHandler: {
					self.animatePreferencesImages(false)
				})
			}
			else {
				// Basic configuration is displayed, go to advanced one
				self.animatePreferencesImages(true)
				self.mainConstraint.animator().constant = self.wholeConfigurationHeight
			}
		}
	}
	
	@IBAction func trayStyleButtonPressed(_ sender: NSButton) {
		Configuration.shared.trayType = sender.tag
		(NSApp.delegate as? AppDelegate)?.actualizeStatus()
	}
	
	func configurationView(show: Bool) {
		// Timer may be started also when this view was not displayed yet
		// In that case mainConstraint is not set, must check this
		guard self.mainConstraint != nil else { return }
		
		DispatchQueue.main.async {
			let newHeight = show ? self.basicConfigurationHeight : 8.0
			if self.mainConstraint.constant > self.basicConfigurationHeight {
				// Advanced configuration is displayed, stop animations
				NSAnimationContext.runAnimationGroup({ (context) in
					self.mainConstraint.animator().constant = newHeight
				}, completionHandler: {
					self.animatePreferencesImages(false)
				})
			}
			else {
				self.mainConstraint.animator().constant = newHeight
			}
		}
	}
	
}

extension MenuViewController: NSTextFieldDelegate {
	
	override func controlTextDidChange(_ obj: Notification) {
		if let textField = obj.object as? NSTextField {
			Configuration.shared.timerSeconds = textField.integerValue
		}
	}
	
}
