//
//  FilterStateRepository.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 30/10/2015.
//  Copyright © 2015 TagMoment. All rights reserved.
//

import Foundation
class FilterStateRepository
{
	static let maskViewModelKey = "maskViewModelKey"
	static let currentIndexKey = "currentIndexKey"
	static let otherIndexKey = "otherIndexKey"
	static let currentSliderValueKey = "currentSliderKey"
	static let otherSliderValueKey = "otherSliderKey"
	static let jumperSelectedKey = "jumperSelectedKey"
	
	class func persistFilters(payload : (mask: TMMaskViewModel, currentIndex: Int, otherIndex : Int, currentSliderValue : Float, otherSliderValue : Float, jumperSelected : Bool))
	{
		let defaults = NSUserDefaults.standardUserDefaults()
		defaults.setObject(NSKeyedArchiver.archivedDataWithRootObject(payload.mask), forKey: maskViewModelKey)
		defaults.setInteger(payload.currentIndex, forKey: currentIndexKey)
		defaults.setInteger(payload.otherIndex, forKey: otherIndexKey)
		defaults.setFloat(payload.currentSliderValue, forKey: currentSliderValueKey)
		defaults.setFloat(payload.otherSliderValue, forKey: otherSliderValueKey)
		defaults.setBool(payload.jumperSelected, forKey: jumperSelectedKey)

	}
	
	class func restoreFilters() ->  (mask: TMMaskViewModel?, currentIndex: Int, otherIndex : Int, currentSliderValue : Float, otherSliderValue : Float, jumperSelected : Bool)
	{
		let defaults = NSUserDefaults.standardUserDefaults()
		var maskViewModel : TMMaskViewModel?
		if let data = defaults.objectForKey(maskViewModelKey) as? NSData
		{
			let unarc = NSKeyedUnarchiver(forReadingWithData: data)
			maskViewModel = unarc.decodeObjectForKey("root") as? TMMaskViewModel
		}
		
		
		let persistedIndex = defaults.integerForKey(currentIndexKey)
		let lastSelectedIndex = defaults.integerForKey(otherIndexKey)
		let persistedSliderValue = defaults.floatForKey(currentSliderValueKey)
		let lastSliderValue = defaults.floatForKey(otherSliderValueKey)
		let persistedJumperState = defaults.boolForKey(jumperSelectedKey)
		
		return (maskViewModel, persistedIndex, lastSelectedIndex, persistedSliderValue, lastSliderValue, persistedJumperState)
	}
	
	class func clearFiltersState()
	{
		let defaults = NSUserDefaults.standardUserDefaults()
		defaults.removeObjectForKey(maskViewModelKey)
		defaults.removeObjectForKey(currentIndexKey)
		defaults.removeObjectForKey(otherIndexKey)
		defaults.removeObjectForKey(currentSliderValueKey)
		defaults.removeObjectForKey(otherSliderValueKey)
	}
}