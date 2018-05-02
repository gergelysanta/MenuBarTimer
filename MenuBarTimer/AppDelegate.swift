//
//  AppDelegate.swift
//  MenuBarTimer
//
//  Created by Gergely Sánta on 30/04/2018.
//  Copyright © 2018 TriKatz. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
	
	@IBOutlet weak var statusMenu: NSMenu!
	@IBOutlet weak var startMenuItem: NSMenuItem!
	@IBOutlet weak var stopMenuItem: NSMenuItem!
	@IBOutlet weak var pauseMenuItem: NSMenuItem!
	
	let menuTimer = MenuTimer()
	let progressImage = ProgressImage()

	let statusItem = NSStatusBar.system.statusItem(withLength: 76)	// or: NSStatusItem.variableLength
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		
		menuTimer.delegate = self
		progressImage.isTemplate = true
		
		statusItem.button?.image = progressImage
		statusItem.button?.title = "0%"
		statusItem.menu = statusMenu
		statusItem.button?.imagePosition = .imageLeft
		
		actualizeStatus()
	}
	
	@IBAction func menuItemSelected(_ sender: NSMenuItem) {
		if sender == startMenuItem {
			menuTimer.start(forSeconds: 15.0)
		}
		else if sender == stopMenuItem {
			menuTimer.stop()
		}
		else if sender == pauseMenuItem {
			menuTimer.togglePause()
		}
		actualizeStatus()
	}
	
	func actualizeStatus() {
		// Actualize status item
		statusItem.button?.title = String(format: "%.0f%%", menuTimer.progress*100)
		progressImage.progress = menuTimer.progress
		statusItem.button?.needsDisplay = true
		// Actualize menu item labels
		startMenuItem.title = menuTimer.running ? "Restart" : "Start"
		stopMenuItem.action = menuTimer.running ? #selector(menuItemSelected(_:)) : nil
		pauseMenuItem.title = menuTimer.paused ? "Resume" : "Pause"
		pauseMenuItem.action = menuTimer.running ? #selector(menuItemSelected(_:)) : nil
	}
	
}

extension AppDelegate: MenuTimerDelegate {
	
	func tick(timer: MenuTimer) {
		actualizeStatus()
	}
	
}
