//
//  TMPixellateFilter.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 2/9/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation
import CoreImage

class TMPixellateFilter : TMFilterInterface{
	var iconName = "Sunset"
	
	lazy var filter : CIFilter = {
		return CIFilter(name: "CIPixellate")
		}()
	
	func applyFilterValue(value: Float) {
		self.filter.setValue(value, forKey: kCIInputScaleKey)
		
	}
	
	func supportsChangingValues() -> Bool{
		return true;
	}
	
}
