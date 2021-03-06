//
//  TMBottomHalfCircleMask.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 5/12/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation
class TMBottomHalfCircleMask: TMMask {
	
	let percentageOfWidth = CGFloat(0.9)
	var workingBounds : CGRect
	
	init(rect: CGRect){
		self.workingBounds = rect
	}
	
	func clippingPathWithRect(bounds : CGRect) -> CGPath
	{
		
		let rectForOval = CGRect(x: 0, y: 0,width: bounds.width, height: bounds.width)
		let somepath = UIBezierPath(ovalInRect: rectForOval)
		
		return somepath.CGPath
	}
	
	var cameraBounds : CGRect{
		let currentWidth = self.workingBounds.width*percentageOfWidth
		let margin = (self.workingBounds.width - currentWidth)/2
		return CGRect(x: margin, y: self.workingBounds.height - currentWidth/2, width: currentWidth, height: currentWidth);
	}
	
	func createViewModel() -> TMMaskViewModel{
		return TMMaskViewModel(name: "up")
	}
}
