//
//  TMTopHalfCircle.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 5/12/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation
class TMTopHalfCircleMask : TMMask {
	
	let percentageOfWidth = CGFloat(0.9)
	var workingBounds : CGRect
	
	init(rect: CGRect){
		self.workingBounds = rect
	}
	
	func clippingPathWithRect(bounds : CGRect) -> CGPath
	{
		
		var rectForOval = CGRect(x: 0, y: 0,width: bounds.width, height: bounds.width)
		var somepath = UIBezierPath(ovalInRect: rectForOval)
		
		return somepath.CGPath
	}
	
	var cameraBounds : CGRect{
		let currentWidth = self.workingBounds.width*percentageOfWidth
		let margin = (self.workingBounds.width - currentWidth)/2
		return CGRect(x: margin, y: -currentWidth/2, width: currentWidth, height: currentWidth);
	}
	
	func createViewModel() -> TMMaskViewModel{
		return TMMaskViewModel(name: "joy")
	}
}
