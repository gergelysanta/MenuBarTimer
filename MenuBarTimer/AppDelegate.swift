//
//  AppDelegate.swift
//  MenuBarTimer
//
//  Created by Gergely Sánta on 30/04/2018.
//  Copyright © 2018 TriKatz. All rights reserved.
//

import Cocoa
import ProgressImage

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	let menuTimer = MenuTimer()
	let progressImage = ProgressImage()
	let pauseImage = NSImage(named: NSImage.Name("Pause"))?.copy() as? NSImage

	let statusItem = NSStatusBar.system.statusItem(withLength: 76)	// or: NSStatusItem.variableLength
	let menuController = MenuViewController()
	
	private var timeStamp: String {
		get {
			return "\(Date().timeIntervalSince1970 * 1000)"
		}
	}
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		
		// Set progressimage as template so it will invert colors when selected and also in dark mode
		progressImage.isTemplate = true
		
		// Resize pause image
		pauseImage?.resizingMode = .stretch
		pauseImage?.size = progressImage.size
		
		// Add status button
		statusItem.button?.image = progressImage
		statusItem.button?.title = "0%"
		statusItem.button?.imagePosition = .imageLeft
		statusItem.button?.action = #selector(statusButtonPressed(_:))
		statusItem.button?.sendAction(on: [ .leftMouseUp, .rightMouseUp ])
		
		// Set AppDelegate as timer's delegate
		menuTimer.delegate = self
		
		// Actualize visuals
		actualizeStatus()
	}
	
	@objc func statusButtonPressed(_ sender: NSStatusBarButton) {
		
		if let event = NSApp.currentEvent,
			let statusButton = statusItem.button
		{
			if	event.modifierFlags.contains(.option) ||
				event.modifierFlags.contains(.control) ||
				event.modifierFlags.contains(.command) ||
				event.type == .rightMouseUp
			{
				let popover = NSPopover()
				popover.contentViewController = menuController
				popover.behavior = .transient
				popover.show(relativeTo: statusButton.frame, of: statusButton, preferredEdge: .maxY)
				return
			}
		}
		
		if !menuTimer.running {
			menuTimer.start(forSeconds: Configuration.shared.timerSeconds)
		}
		else {
			menuTimer.togglePause()
		}
	}
	
	func actualizeStatus() {
		// Actualize status item
		statusItem.button?.title = String(format: "%.0f%%", menuTimer.progress*100)
		progressImage.type = ProgressImage.ProgressType(rawValue: Configuration.shared.trayType) ?? .horizontal
		if progressImage.type == .horizontal {
			progressImage.size = ProgressImage.defaultSize
		}
		else {
			progressImage.size = NSSize(width: progressImage.size.height, height: progressImage.size.height)
		}
		progressImage.progress = menuTimer.progress
		statusItem.button?.needsDisplay = true
	}
	
	func showAlert(message: String, type: NSAlert.Style = .warning) {
		let alertDialog = NSAlert()
		alertDialog.alertStyle = type
		alertDialog.informativeText = message
		switch type {
		case .critical:
			alertDialog.messageText = "Critical error"
		case .informational:
			alertDialog.messageText = "Information"
		case .warning:
			alertDialog.messageText = "Warning"
		}
		alertDialog.runModal()
	}
	
	func notify(title: String, subtitle: String?, message: String) {
		
		checkNotificationSettings()
		
		// Create notification with requested texts
		let notification = NSUserNotification()
		notification.title = title
		notification.subtitle = subtitle
		notification.informativeText = message
		
		// Set UNIQUE identifier
		// If identifier is not unique and notification with this ID was already delivered
		// to notification center, this notification won't be displayed.
		// Note that NotificationCenter is system-wide, so the old notification could be
		// delivered by other process (by older instance of gui-agent for example)
		notification.identifier = "ESNotification.\(timeStamp)"
		
		// Deliver the notification
		NSUserNotificationCenter.default.deliver(notification)
	}
	
	private func checkNotificationSettings() {
		guard let bundleId = Bundle.main.bundleIdentifier else { return }
		let path = "\(NSHomeDirectory())/Library/Preferences/com.apple.ncprefs.plist"
		if let dict = NSDictionary(contentsOfFile: path) as? [String: Any],
			let appsArray = dict["apps"] as? [[String: Any]]
		{
			for app in appsArray {
				if let appBundleID = app["bundle-id"] as? String,
					let appFlags = app["flags"] as? Int,
					appBundleID == bundleId
				{
					// decimal binary
					// 70      0000 0000 0100 0110    when notification bubbles are disabled ('None' set) - default value in this case
					// 78      0000 0000 0100 1110    when notification banners are enabled
					//                        ^
					// 86      0000 0000 0101 0110    when notification alerts are enabled
					//                      ^
					// 4166    0001 0000 0100 0110    when notifications on lock screen are disabled
					//            ^
					// 71      0000 0000 0100 0111    when "Show in notification Center" is disabled
					//                           ^
					// 68      0000 0000 0100 0100    when "Badge app icon" is disabled
					//                          ^
					// 66      0000 0000 0100 0010    when "Play sound for notifications" is disabled\
					//                         ^
					if appFlags & 0b11000 == 0 {
						showAlert(message: "Notifications are disabled for MenuBarTimer.\nGo to 'System Preferences' -> 'Notifications' and set alert style to 'Banners' or 'Alerts' for MenuBarTimer")
					}
					else if appFlags & 0b1 == 1 {
						showAlert(message: "MenuBarTimer should be enabled to show in Notification Center.\nGo to 'System Preferences' -> 'Notifications' and check 'Show in Notification Center' for MenuBarTimer")
					}
					break
				}
			}
		}
	}
	
}

extension AppDelegate: MenuTimerDelegate {
	
	func tick(timer: MenuTimer) {
		menuController.progress = timer.progress
		actualizeStatus()
	}
	
	func timerStarted(timer: MenuTimer) {
		#if DEBUG
			NSLog("Timer started for \(timer.secondsTotal) seconds...")
		#endif
		statusItem.button?.image = progressImage
		menuController.configurationView(show: false)
	}
	
	func timerEnded(timer: MenuTimer) {
		#if DEBUG
			NSLog("Timer ended...")
		#endif
		menuController.configurationView(show: true)
		self.notify(title: "Timer ended", subtitle: nil, message: "Your timer run out! Now take the consequences!")
	}
	
	func timerStopped(timer: MenuTimer) {
		#if DEBUG
			NSLog("Timer stopped...")
		#endif
		statusItem.button?.image = progressImage
		menuController.configurationView(show: true)
		actualizeStatus()
	}
	
	func timerPauseToggled(timer: MenuTimer, paused: Bool) {
		#if DEBUG
			NSLog("Timer %@...", paused ? "paused" : "resumed")
		#endif
		statusItem.button?.image = paused ? pauseImage : progressImage
	}
	
}
