//
//  TMColorMapFilter.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 2/9/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation
import CoreImage

class TMPhotoEffectMonoFilter : TMFilterInterface{
	var iconName = "Love"
	
	lazy var filter : CIFilter = {
		return CIFilter(name: "CIPhotoEffectMono")
		}()
	
	func applyFilterValue(value: Float) {
		return
	}
	
	func supportsChangingValues() -> Bool{
		return false;
	}
	
}
