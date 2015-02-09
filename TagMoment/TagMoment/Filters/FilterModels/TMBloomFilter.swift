//
//  TMBloomFilter.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 2/9/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation
import CoreImage

class TMBloomFilter : TMFilterInterface{
	var iconName = "Music"
	
	lazy var filter : CIFilter = {
		return CIFilter(name: "CIBloom")
		}()
	
	func applyFilterValue(value: Float) {
		self.filter.setValue(value*100, forKey: kCIInputRadiusKey)
		self.filter.setValue(value, forKey: kCIInputIntensityKey)
		
	}
	
	func supportsChangingValues() -> Bool{
		return true;
	}
	
}
