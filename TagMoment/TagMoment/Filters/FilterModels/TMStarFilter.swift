//
//  TMComicEffectFilter.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 2/9/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation
import CoreImage

class TMStarFilter : TMAlphaFilterBase{
	override var filtersProtected : [CIFilter] {
		get
		{
			var filters = super.filtersProtected
			filters.insert(CIFilter(name: "CIColorControls")!, at: 0)
			return filters

		}
	}
	
	
		
	override init()
	{
		super.init()
		self.iconName = "Star"
		self.displayName = "Wish"
	}
	
	override func applyFilterValue(_ value : Float)
	{
		let defaultParams = self.constantParams[self.filters[0].name];
		for param in defaultParams!
		{
			self.filters[0].setValue(param.normalizedValueFromPercent(value), forKey: param.key)
		}
		super.applyFilterValue(value)
		
		
		
	}
	override func createConstantFilterParameters(_ outParams : inout [String : [FilterParameterProtocol]])
	{
		var colorControlsfilterParams = [FilterParameterProtocol]()
		colorControlsfilterParams.append(FilterConstantParameter(key: "inputSaturation", constant: Float(0.64) as AnyObject))
		colorControlsfilterParams.append(FilterConstantParameter(key: "inputBrightness", constant: Float(0.2) as AnyObject))
		colorControlsfilterParams.append(FilterConstantParameter(key: "inputContrast", constant: Float(1.88) as AnyObject))
		outParams.updateValue(colorControlsfilterParams, forKey: self.filters[0].name)
	}
	
}
