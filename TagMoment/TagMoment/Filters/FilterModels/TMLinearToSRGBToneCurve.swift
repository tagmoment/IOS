//
//  TMLinearToSRGBToneCurve.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 2/9/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation
import CoreImage

class TMLinearToSRGBToneCurveFilter : TMFilterInterface{
	var iconName = "Gamer"
	
	lazy var filter : CIFilter = {
		return CIFilter(name: "CILinearToSRGBToneCurve")
		}()
	
	func applyFilterValue(value: Float) {
		return;
	}
	
	func supportsChangingValues() -> Bool{
		return false;
	}
	
}
