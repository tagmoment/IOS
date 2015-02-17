//
//  TMColorMapFilter.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 2/9/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation
import CoreImage

class TMPhotoEffectMonoFilter : TMFilterBase{
	
	override init()
	{
		super.init()
		self.iconName = "Love"
	}
	
	lazy var filter : CIFilter = {
		return CIFilter(name: "CIPhotoEffectMono")
		}()
	
	
	override func supportsChangingValues() -> Bool{
		return false;
	}
	
}
