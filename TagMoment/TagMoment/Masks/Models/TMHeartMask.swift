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
		return angle / CGFloat(180 * M_PI);
	}
	
	class func bezierHeartShapePathWithWidth(width: CGFloat, center: CGPoint) -> UIBezierPath{
		var w = width/2
		var path = UIBezierPath()
		path.addArcWithCenter(CGPoint(x: center.x - w/2,y: center.y - sqrt(3)*w/6), radius: w/sqrt(3), startAngle: TMHeartMask.toRadians(150), endAngle: TMHeartMask.toRadians(-30), clockwise: true)
		path.addArcWithCenter(CGPoint(x: center.x + w/2,y: center.y - sqrt(3)*w/6), radius: w/sqrt(3), startAngle: TMHeartMask.toRadians(-150), endAngle: TMHeartMask.toRadians(30), clockwise: true)
		path.moveToPoint(CGPoint(x: center.x - w, y: center.y))
		path.addLineToPoint(CGPoint(x: center.x, y: center.y + w*sqrt(3)))
		path.addLineToPoint(CGPoint(x: center.x + w, y: center.y))
		
		return path
	}
	

}
