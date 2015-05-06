//
//  TMHorizontalRectMask.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 1/3/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit

class TMHorizontalRectMask: TMMask {
	var workingBounds : CGRect
	
	init(rect: CGRect){
		self.workingBounds = rect
	}
	
	func clippingPathWithRect(bounds : CGRect) -> CGPath
	{
		var somepath = UIBezierPath(rect: CGRect(x: 0.0, y: workingBounds.maxY/2, width: workingBounds.maxX, height: workingBounds.maxY/2))
		
		return somepath.CGPath
	}
	
	var cameraBounds : CGRect{
		return self.workingBounds;
	}
	
	func createViewModel() -> TMMaskViewModel{
		return TMMaskViewModel(name: "flat")
	}
}
