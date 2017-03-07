//
//  TMEdgesFilter.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 2/9/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation
import CoreImage

class TMTravelFilter : TMAlphaFilterBase{
	override var filtersProtected : [CIFilter]
	{
		get
		{
			var filters = super.filtersProtected
			filters.insert(CIFilter(name: "CISepiaTone")!, at: 0)
			return filters
		}
		
	}
	
	override init()
	{
		super.init()
		self.iconName = "Travel"
		self.displayName = "Take Off"
	}
}
