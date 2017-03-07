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
		
		let userDefaults = UserDefaults.standard
		if (userDefaults.value(forKey: "saveToCameraRoll") == nil)
		{
			userDefaults.register( defaults: [ "saveToCameraRoll" : "prompt" ])
			userDefaults.synchronize()
		}
		
	}
	
	class func saveToCameraRollSaveState()
	{
		let userDefaults = UserDefaults.standard
		userDefaults.set("always", forKey: "saveToCameraRoll")
		userDefaults.synchronize()
	}
	
	class func neverSaveToCameraRollSameState()
	{
		let userDefaults = UserDefaults.standard
		userDefaults.set("never", forKey: "saveToCameraRoll")
		userDefaults.synchronize()
	}
	
	class func shouldSaveToCameraRoll() -> Bool
	{
		let userDefaults = UserDefaults.standard
		if let value = userDefaults.value(forKey: "saveToCameraRoll")
		{
			let valueString = value as! String
			return valueString == "always"
		}
		
		return false
	}
	
	class func shouldPrompt() -> Bool
	{
		let userDefaults = UserDefaults.standard
		if let value = userDefaults.value(forKey: "saveToCameraRoll")
		{
			let valueString = value as! String
			return valueString == "prompt"
		}
		
		return false
	}
	
	
}
