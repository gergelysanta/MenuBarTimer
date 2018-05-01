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
	
	@IBOutlet weak var window: NSWindow!
	@IBOutlet weak var imageView: NSImageView!
	
	let statusItem = NSStatusBar.system.statusItem(withLength: 76)
//	let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

	func applicationDidFinishLaunching(_ aNotification: Notification) {
		
		// Customize status bar item
		let timerProgress = ProgressImage()
		timerProgress.isTemplate = true
		
		statusItem.button?.image = timerProgress
		statusItem.button?.title = "Timer"
		statusItem.button?.imagePosition = .imageLeft
		
		// Add progress to main window
		let progressImage = ProgressImage(size: NSSize(width: 100.0, height: 20.0))
		
		let fromColor = NSColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
		var toColors:[NSColor] = [
			NSColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0),
			NSColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0),
			NSColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 1.0)
		]
		var toColor:NSColor = toColors.removeFirst()

		progressImage.progress = 0.0
		progressImage.color = fromColor
		
		imageView.image = progressImage
		
		Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { (timer) in
			if progressImage.progress == 1.0 {
				if toColors.count > 0 {
					toColor = toColors.removeFirst()
					timerProgress.progress = 0.0
					progressImage.progress = 0.0
				}
				else {
					timer.invalidate()
				}
			}

			timerProgress.progress += 0.001
			self.statusItem.button?.title = String(format: "%.0f%%", timerProgress.progress*100)

			progressImage.progress += 0.001
			progressImage.color = NSColor(red: fromColor.redComponent + ((toColor.redComponent - fromColor.redComponent) * progressImage.progress),
										  green: fromColor.greenComponent + ((toColor.greenComponent - fromColor.greenComponent) * progressImage.progress),
										  blue: fromColor.blueComponent + ((toColor.blueComponent - fromColor.blueComponent) * progressImage.progress),
										  alpha: fromColor.alphaComponent + ((toColor.alphaComponent - fromColor.alphaComponent) * progressImage.progress))
			
			self.imageView.needsDisplay = true
			self.statusItem.button?.needsDisplay = true
		}
	}
	
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}
	
}

