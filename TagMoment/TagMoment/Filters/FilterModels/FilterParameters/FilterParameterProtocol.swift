//
//  FilterParameterProtocol.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 2/18/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation

protocol FilterParameterProtocol
{
	var key : String { get }
	
	func normalizedValueFromPercent(_ percent : Float) -> AnyObject
	
}
