//
//  TMSunFilter.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 3/30/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit

class TMSunFilter: TMFilterBase {
	
	override init()
	{
		super.init()
		self.iconName = "Sun"
	}
	
	override func supportsChangingValues() -> Bool {
		return false
	}
}
