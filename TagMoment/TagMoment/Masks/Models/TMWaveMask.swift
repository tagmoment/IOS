//
//  TMWaveMask.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 1/4/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit

class TMWaveMask: NSObject, TMMask {
	var workingBounds : CGRect
	
	init(rect: CGRect){
		self.workingBounds = rect
	}
	
	var clippingPath : UIBezierPath{
		
		var path = UIBezierPath()
		path.moveToPoint(CGPoint(x: self.workingBounds.width/2+100, y: 0))
		path.addCurveToPoint(CGPoint(x: self.workingBounds.width/2-100, y: self.workingBounds.height),
			controlPoint1: CGPoint(x: self.workingBounds.width/4, y: self.workingBounds.height/4),
			controlPoint2: CGPoint(x: self.workingBounds.width*3/4, y: self.workingBounds.height*3/4))
		path.addLineToPoint(CGPoint(x: self.workingBounds.width, y: self.workingBounds.height))
		path.addLineToPoint(CGPoint(x: self.workingBounds.width, y: 0))
		path.closePath()
		
		return path
	}
	
	func createViewModel() -> TMMaskViewModel{
		return TMMaskViewModel(name: "waves")
	}
}
