//
//  TMCircleMask.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 1/4/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit

class TMCircleMask: NSObject, TMMask {
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
		return CGRect(x: self.workingBounds.width/4, y: self.workingBounds.height/2 - 15, width: self.workingBounds.width/2, height: self.workingBounds.width/2);
	}
	
	func createViewModel() -> TMMaskViewModel{
		return TMMaskViewModel(name: "moment")
	}
}
