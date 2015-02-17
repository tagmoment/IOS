//
//  TMLinearToSRGBToneCurve.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 2/9/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation
import CoreImage

class TMVintageFilter : TMFilterBase{
	override var filtersProtected : [CIFilter] {
		get
		{
			return [CIFilter(name: "CIPhotoEffectNoir"), CIFilter(name: "CIHighlightShadowAdjust")]
		}
	}
	
	override init()
	{
		super.init()
		self.iconName = "Vintage"
	}
	
}
