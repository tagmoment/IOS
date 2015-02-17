//
//  TMBloomFilter.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 2/9/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation
import CoreImage

class TMBloomFilter : TMFilterBase{
	override var filtersProtected : [CIFilter] { return [CIFilter(name: "CIBloom")] }
	
	override init()
	{
		super.init()
		self.iconName = "Music"
	}
	
	

	
}
