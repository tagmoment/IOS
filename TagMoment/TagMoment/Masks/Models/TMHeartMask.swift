//
//  TMHeartMask.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 1/4/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit

class TMHeartMask: NSObject, TMMask {
	var workingBounds : CGRect
	
	init(rect: CGRect){
		self.workingBounds = rect
	}
	
	var clippingPath : UIBezierPath{
		
		return TMHeartMask.bezierHeartShapePathWithWidth(self.workingBounds.width, center: CGPoint(x: self.workingBounds.midX, y: self.workingBounds.midY))
	}
	
	func createViewModel() -> TMMaskViewModel{
		return TMMaskViewModel(name: "xoxo")
	}
	
	
	class func toRadians(angle: CGFloat) -> CGFloat{
		return angle*CGFloat(M_PI)/CGFloat(180.0);
	}
	
	class func bezierHeartShapePathWithWidth(width: CGFloat, center: CGPoint) -> UIBezierPath{
		var w = width/2
		var h = width/2
		var path = UIBezierPath()
		path.addArcWithCenter(CGPoint(x: center.x + w/3 - 13.0,y: center.y + w/3), radius: w/3, startAngle: TMHeartMask.toRadians(30), endAngle: TMHeartMask.toRadians(210), clockwise: false)
		
		path.addArcWithCenter(CGPoint(x: center.x - w/3 + 13.0,y: center.y + w/3), radius: w/3, startAngle: TMHeartMask.toRadians(-30), endAngle: TMHeartMask.toRadians(150), clockwise: false)
		path.addLineToPoint(CGPoint(x: center.x, y: center.y + w))
		path.closePath()
		return path
	}
	

}
