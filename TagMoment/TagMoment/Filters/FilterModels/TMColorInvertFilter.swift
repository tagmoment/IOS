//
//  TMColorInvertFilter.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 2/9/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation
import CoreImage

class TMColorInvertFilter : TMFilterInterface{
	var iconName = "Sun"
	
	lazy var filter : CIFilter = {
		return CIFilter(name: "CIColorInvert")
		}()
	
	func applyFilterValue(value: Float) {
		return;
	}
	
	func supportsChangingValues() -> Bool{
		return false;
	}
	
}
