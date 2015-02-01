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
	
	var clippingPath : UIBezierPath{
		var rectForOval = CGRect(x: self.workingBounds.width/4, y: self.workingBounds.height/2 - 30,width: self.workingBounds.width/2, height: self.workingBounds.width/2)
		var somepath = UIBezierPath(ovalInRect: rectForOval)
		
		return somepath
	}
	
	func createViewModel() -> TMMaskViewModel{
		return TMMaskViewModel(name: "moment")
	}
}
