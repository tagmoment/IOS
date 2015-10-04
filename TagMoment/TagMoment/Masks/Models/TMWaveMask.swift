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
	
	func clippingPathWithRect(bounds : CGRect) -> CGPath
	{
		let path = UIBezierPath()
		path.moveToPoint(CGPoint(x: self.workingBounds.width/2, y: 0))
		path.addQuadCurveToPoint(CGPoint(x: self.workingBounds.width/2, y: self.workingBounds.height/2),
			controlPoint: CGPoint(x: self.workingBounds.width/4, y: self.workingBounds.height/4))
		path.addQuadCurveToPoint(CGPoint(x: self.workingBounds.width/2, y: self.workingBounds.height), controlPoint: CGPoint(x: self.workingBounds.width*3/4, y: self.workingBounds.height*3/4))
		path.addLineToPoint(CGPoint(x: self.workingBounds.width, y: self.workingBounds.height))
		path.addLineToPoint(CGPoint(x: self.workingBounds.width, y: 0))
		path.closePath()
		
		return path.CGPath
	}
		
	var cameraBounds : CGRect{
		return self.workingBounds;
	}
	
	func createViewModel() -> TMMaskViewModel{
		return TMMaskViewModel(name: "waves")
	}
}
