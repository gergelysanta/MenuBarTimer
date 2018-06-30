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

	let statusItem = NSStatusBar.system.statusItem(withLength: 76)	// or: NSStatusItem.variableLength
	let menuController = MenuViewController()
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		
		// Set progressimage as template so it will invert colors when selected and also in dark mode
		progressImage.isTemplate = true
		
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
			NSLog("Start")
			menuTimer.start(forSeconds: 10.0)
		}
		else {
			NSLog("Toggle")
			menuTimer.togglePause()
		}
	}
	
	func actualizeStatus() {
		// Actualize status item
		statusItem.button?.title = String(format: "%.0f%%", menuTimer.progress*100)
		progressImage.progress = menuTimer.progress
		statusItem.button?.needsDisplay = true
	}
	
}

extension AppDelegate: MenuTimerDelegate {
	
	func tick(timer: MenuTimer) {
		menuController.progress = timer.progress
		actualizeStatus()
	}
	
	func timerStarted(timer: MenuTimer) {
		#if DEBUG
			NSLog("Timer started...")
		#endif
		menuController.configurationView(show: false)
	}
	
	func timerEnded(timer: MenuTimer) {
		#if DEBUG
			NSLog("Timer ended...")
		#endif
		menuController.configurationView(show: true)
	}
	
	func timerStopped(timer: MenuTimer) {
		#if DEBUG
			NSLog("Timer stopped...")
		#endif
		menuController.configurationView(show: true)
		actualizeStatus()
	}
	
	func timerPauseToggled(timer: MenuTimer, paused: Bool) {
		#if DEBUG
			NSLog("Timer %@...", paused ? "paused" : "resumed")
		#endif
	}
	
}
