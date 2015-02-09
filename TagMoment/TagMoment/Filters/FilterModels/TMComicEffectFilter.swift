//
//  TMComicEffectFilter.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 2/9/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation
import CoreImage

class TMComicEffectFilter : TMFilterInterface{
	var iconName = "Star"
	
	lazy var filter : CIFilter = {
		return CIFilter(name: "CIComicEffect")
		}()
	
	func applyFilterValue(value: Float) {
		return
	}
	
	func supportsChangingValues() -> Bool{
		return false
	}
	
}
