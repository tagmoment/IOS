//
//  SettingsHelper.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 14/12/2015.
//  Copyright © 2015 TagMoment. All rights reserved.
//

import UIKit

class SettingsHelper: NSObject {
	class func registerSettingsIfNeeded()
	{
		
		let userDefaults = NSUserDefaults.standardUserDefaults()
		if (userDefaults.valueForKey("saveToCameraRoll") == nil)
		{
			userDefaults.registerDefaults( [ "saveToCameraRoll" : "prompt" ])
			userDefaults.synchronize()
		}
		
	}
	
	class func saveToCameraRollSaveState()
	{
		let userDefaults = NSUserDefaults.standardUserDefaults()
		userDefaults.setObject("always", forKey: "saveToCameraRoll")
		userDefaults.synchronize()
	}
	
	class func neverSaveToCameraRollSameState()
	{
		let userDefaults = NSUserDefaults.standardUserDefaults()
		userDefaults.setObject("never", forKey: "saveToCameraRoll")
		userDefaults.synchronize()
	}
	
	class func shouldSaveToCameraRoll() -> Bool
	{
		let userDefaults = NSUserDefaults.standardUserDefaults()
		if let value = userDefaults.valueForKey("saveToCameraRoll")
		{
			let valueString = value as! String
			return valueString == "always"
		}
		
		return false
	}
	
	class func shouldPrompt() -> Bool
	{
		let userDefaults = NSUserDefaults.standardUserDefaults()
		if let value = userDefaults.valueForKey("saveToCameraRoll")
		{
			let valueString = value as! String
			return valueString == "prompt"
		}
		
		return false
	}
	
	
}
