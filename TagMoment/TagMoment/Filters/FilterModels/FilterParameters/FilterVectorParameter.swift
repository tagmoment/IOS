//
//  FilterVectorParameter.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 2/18/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation
import CoreImage

class FilterVectorParameter : FilterParameterProtocol
{
	var key : String
	
	init(key : String)
	{
		self.key = key
	}
	
	func normalizedValueFromPercent(_ percent : Float) -> AnyObject
	{
//		return CIVector(x: CGFloat(320*percent), y: CGFloat(320*percent))
		return CIVector(x: CGFloat(150), y: CGFloat(150))
	}
}
