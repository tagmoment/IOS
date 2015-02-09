//
//  TMCrystallizeFilter.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 2/9/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation
import CoreImage

class TMCrystallizeFilter : TMFilterInterface{
	var iconName = "Surprise"
	
	lazy var filter : CIFilter = {
		return CIFilter(name: "CICrystallize")
		}()
	
	func applyFilterValue(value: Float) {
		self.filter.setValue(value*100, forKey: kCIInputRadiusKey)
		
	}
	
	func supportsChangingValues() -> Bool{
		return true;
	}
	
}
