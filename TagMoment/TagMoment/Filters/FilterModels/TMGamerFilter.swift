//
//  TMGamerFilter.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 4/10/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation
import CoreImage

class TMGamerFilter : TMAlphaFilterBase{
	override var filtersProtected : [CIFilter] {
		get
		{
			var filters = super.filtersProtected
			filters.insert(CIFilter(name: "CIUnsharpMask"), atIndex: 0)
			return filters
			
		}
	}
	
	override init()
	{
		super.init()
		self.iconName = "Gamer"
	}
	
	override func applyFilterValue(value : Float)
	{
		let defaultParams = self.constantParams[self.filters[0].name()];
		for param in defaultParams!
		{
			self.filters[0].setValue(param.normalizedValueFromPercent(value), forKey: param.key)
		}
		super.applyFilterValue(value)
		
		
		
	}
	override func createConstantFilterParameters(inout outParams : [String : [FilterParameterProtocol]])
	{
		var colorControlsfilterParams = [FilterParameterProtocol]()
		colorControlsfilterParams.append(FilterConstantParameter(key: "inputRadius", constant: Float(2.0)))
		colorControlsfilterParams.append(FilterConstantParameter(key: "inputIntensity", constant: Float(6.5)))
		outParams.updateValue(colorControlsfilterParams, forKey: self.filters[0].name())
	}
	
}
