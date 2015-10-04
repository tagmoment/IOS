//
//  TMPixellateFilter.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 2/9/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation
import CoreImage

class TMCloudFilter : TMFilterBase{
	override var filtersProtected : [CIFilter] {
		get
		{
			return [CIFilter(name: "CIPixellate")!]
		}
	}
	
	override init()
	{
		super.init()
		self.iconName = "cloud"
	}
	
	
}
