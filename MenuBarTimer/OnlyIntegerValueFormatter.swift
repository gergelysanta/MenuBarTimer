//
//  OnlyFloatValueFormatter.swift
//  MenuBarTimer
//
//  Created by Gergely Sánta on 30/06/2018.
//  Copyright © 2018 TriKatz. All rights reserved.
//

import Cocoa

class OnlyIntegerValueFormatter: NumberFormatter {
	
	override func isPartialStringValid(_ partialStringPtr: AutoreleasingUnsafeMutablePointer<NSString>, proposedSelectedRange proposedSelRangePtr: NSRangePointer?, originalString origString: String, originalSelectedRange origSelRange: NSRange, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
		
		if partialStringPtr.pointee.length == 0 {
			partialStringPtr.pointee = "0" as NSString
			proposedSelRangePtr?.pointee = NSMakeRange(0, partialStringPtr.pointee.length)
			return false
		}
		
		// Limit input length
		if partialStringPtr.pointee.length > 4 {
			return false
		}
		
		// Actual check
		return Int(partialStringPtr.pointee as String) != nil
	}
	
}
