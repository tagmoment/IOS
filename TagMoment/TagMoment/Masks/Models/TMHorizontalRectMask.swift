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
	
	var clippingPath : UIBezierPath{
		var somepath = UIBezierPath(rect: CGRect(x: 0.0, y: 0.0, width: workingBounds.maxX, height: workingBounds.maxY/2))
		
		return somepath
	}
	
	func createViewModel() -> TMMaskViewModel{
		return TMMaskViewModel(name: "Flat")
	}
}
