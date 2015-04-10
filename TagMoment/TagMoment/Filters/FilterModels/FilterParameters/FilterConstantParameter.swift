//
//  FilterConstantParameter.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 4/10/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation

class FilterConstantParameter : FilterParameterProtocol
{
	
	var key : String
	let constant : AnyObject
	
	init(key : String, constant: AnyObject)
	{
		self.key = key
		self.constant = constant
	}
	
	func normalizedValueFromPercent(percent : Float) -> AnyObject
	{
		return self.constant
	}
	
}