//
//  TMBubbleMask.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 5/20/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit
class TMBubbleMask: NSObject, TMMask {
	var workingBounds : CGRect
	
	init(rect: CGRect){
		self.workingBounds = rect
	}
	
	func clippingPathWithRect(bounds : CGRect) -> CGPath
	{
		let scaleFactor = CGFloat(0.08)
		let controlScaleFactor = CGFloat(0.1333)
		var path = UIBezierPath()
		let relativeRect = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height)
		path.addArcWithCenter(CGPoint(x: relativeRect.midX - relativeRect.width*scaleFactor  ,y: relativeRect.midY), radius: relativeRect.width/2 - relativeRect.width*scaleFactor*2, startAngle: TMHeartMask.toRadians(0), endAngle: TMHeartMask.toRadians(100), clockwise: false)
		
		path.addQuadCurveToPoint(CGPoint(x: relativeRect.width - relativeRect.width*scaleFactor*2, y: relativeRect.midY + relativeRect.width/2 - relativeRect.width*scaleFactor*2), controlPoint: CGPoint(x: relativeRect.width/2, y: relativeRect.height - relativeRect.width*controlScaleFactor))
		path.addQuadCurveToPoint(CGPoint(x: relativeRect.width - relativeRect.width*scaleFactor*3, y: relativeRect.midY) , controlPoint: CGPoint(x: relativeRect.width/2 + relativeRect.width*controlScaleFactor*2, y: relativeRect.height - relativeRect.width*controlScaleFactor*1.5))
		path.closePath()
//		path = UIBezierPath(rect: CGRectMake(0,0,bounds.width, bounds.width))
		return path.CGPath
	}
	
	var cameraBounds : CGRect{
		
		return CGRect(x: 0 , y: 0, width: self.workingBounds.width/2, height: self.workingBounds.width/2);
//		return self.workingBounds
	}
	
	func createViewModel() -> TMMaskViewModel{
		return TMMaskViewModel(name: "bubble")
	}
	
	func toRadians(angle: CGFloat) -> CGFloat{
		return angle*CGFloat(M_PI)/CGFloat(180.0);
	}

	
}
