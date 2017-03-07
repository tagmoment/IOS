//
//  TMColorMapFilter.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 2/9/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation
import CoreImage

class TMLoveFilter : TMAlphaFilterBase{
	override var filtersProtected : [CIFilter]
		{
		get
		{
			var filters = super.filtersProtected
			filters.insert(CIFilter(name: "CILinearToSRGBToneCurve")!, at: 0)
			return filters
		}
	}
	override init()
	{
		super.init()
		self.iconName = "Love"
		self.displayName = "feelings"
	}
}
