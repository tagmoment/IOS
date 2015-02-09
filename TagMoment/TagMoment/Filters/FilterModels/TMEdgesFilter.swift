//
//  TMEdgesFilter.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 2/9/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation
import CoreImage

class TMEdgesFilter : TMFilterInterface{
	var iconName = "Surprise"
	
	lazy var filter : CIFilter = {
		return CIFilter(name: "CIEdges")
		}()
	
	func applyFilterValue(value: Float) {
		self.filter.setValue(value, forKey: kCIInputIntensityKey)
		
	}
	
	func supportsChangingValues() -> Bool{
		return true;
	}
	
}
