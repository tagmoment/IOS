//
//  TMAlphaFilterBase.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 4/10/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation

class TMAlphaFilterBase : TMFilterBase
{
	override var filtersProtected : [CIFilter] {
		get
		{
			return [CIFilter(name: "CIColorMatrix")!,
				CIFilter(name: "CISourceOverCompositing")!]
		}
	}
//	var ColorMatrix = CIFilter(name: "CIColorMatrix")
//	var Compositor =
	override func inputImage(_ inputImage: CIImage!) {
		super.inputImage(inputImage)
		self.filters[2].setValue(inputImage, forKey: kCIInputBackgroundImageKey)
	}
	
	override func applyFilterValue(_ value : Float)
	{
		self.filters[1].setDefaults()
		self.filters[1].setValue(CIVector(x: CGFloat(0), y: CGFloat(0), z: CGFloat(0), w: CGFloat(value)), forKey: "inputAVector");
	}
}
