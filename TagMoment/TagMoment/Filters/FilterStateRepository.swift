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
	
	class func persistFilters(_ payload : (mask: TMMaskViewModel, currentIndex: Int, otherIndex : Int, currentSliderValue : Float, otherSliderValue : Float, jumperSelected : Bool))
	{
		let defaults = UserDefaults.standard
		defaults.set(NSKeyedArchiver.archivedData(withRootObject: payload.mask), forKey: maskViewModelKey)
		defaults.set(payload.currentIndex, forKey: currentIndexKey)
		defaults.set(payload.otherIndex, forKey: otherIndexKey)
		defaults.set(payload.currentSliderValue, forKey: currentSliderValueKey)
		defaults.set(payload.otherSliderValue, forKey: otherSliderValueKey)
		defaults.set(payload.jumperSelected, forKey: jumperSelectedKey)

	}
	
	class func restoreFilters() ->  (mask: TMMaskViewModel?, currentIndex: Int, otherIndex : Int, currentSliderValue : Float, otherSliderValue : Float, jumperSelected : Bool)
	{
		let defaults = UserDefaults.standard
		var maskViewModel : TMMaskViewModel?
		if let data = defaults.object(forKey: maskViewModelKey) as? Data
		{
			let unarc = NSKeyedUnarchiver(forReadingWith: data)
			maskViewModel = unarc.decodeObject(forKey: "root") as? TMMaskViewModel
		}
		
		
		let persistedIndex = defaults.integer(forKey: currentIndexKey)
		let lastSelectedIndex = defaults.integer(forKey: otherIndexKey)
		let persistedSliderValue = defaults.float(forKey: currentSliderValueKey)
		let lastSliderValue = defaults.float(forKey: otherSliderValueKey)
		let persistedJumperState = defaults.bool(forKey: jumperSelectedKey)
		
		return (maskViewModel, persistedIndex, lastSelectedIndex, persistedSliderValue, lastSliderValue, persistedJumperState)
	}
	
	class func clearFiltersState()
	{
		let defaults = UserDefaults.standard
		defaults.removeObject(forKey: maskViewModelKey)
		defaults.removeObject(forKey: currentIndexKey)
		defaults.removeObject(forKey: otherIndexKey)
		defaults.removeObject(forKey: currentSliderValueKey)
		defaults.removeObject(forKey: otherSliderValueKey)
	}
}
