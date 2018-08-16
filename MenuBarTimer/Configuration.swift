//
//  Configuration.Swift
//  MenuBarTimer
//
//  Created by Gergely Sánta on 16/08/2018.
//  Copyright © 2018 TriKatz. All rights reserved.
//

import Foundation

class Configuration {
	
	static let shared = Configuration()
	
	var timerSeconds:Int = 120 {
		didSet {
			save()
		}
	}
	
	var trayType:Int = 0 {
		didSet {
			save()
		}
	}
	
	private init() {
		// Load configuration
		let userDefaults = UserDefaults.standard
		if let floatValue = userDefaults.value(forKey: "timerSeconds") as? Int {
			timerSeconds = floatValue
		}
		if let intValue = userDefaults.value(forKey: "trayType") as? Int {
			trayType = intValue
		}
	}
	
	private func save() {
		UserDefaults.standard.set(timerSeconds, forKey: "timerSeconds")
		UserDefaults.standard.set(trayType, forKey: "trayType")
		UserDefaults.standard.synchronize()
	}
	
}
