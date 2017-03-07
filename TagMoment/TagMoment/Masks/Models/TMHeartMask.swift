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
	
	func clippingPathWithRect(_ bounds: CGRect) -> CGPath {
		return TMHeartMask.bezierHeartShapePathWithWidth(bounds.width, center: CGPoint(x: bounds.width/2, y: bounds.height/2)).cgPath
	}
	var cameraBounds : CGRect{
		return CGRect(x: self.workingBounds.width/4, y: self.workingBounds.height/2 - 15, width: self.workingBounds.width/2, height: self.workingBounds.width/2)
	}
	
	func createViewModel() -> TMMaskViewModel{
		return TMMaskViewModel(name: "xoxo")
	}
	
	
	class func toRadians(_ angle: CGFloat) -> CGFloat{
		return angle*CGFloat(M_PI)/CGFloat(180.0);
	}
	
	class func bezierHeartShapePathWithWidth(_ width: CGFloat, center: CGPoint) -> UIBezierPath{
		let w = width
//		let h = width
		let radiusConst = width > 170.0 ? CGFloat(40.0) : CGFloat(35.0)
		let radius = w - center.x - radiusConst
//		let y = center.y + 20
		let path = UIBezierPath()
		path.addArc(withCenter: CGPoint(x: center.x + radiusConst,y: radius), radius: radius, startAngle: TMHeartMask.toRadians(40), endAngle: TMHeartMask.toRadians(210), clockwise: false)
		
		path.addArc(withCenter: CGPoint(x: center.x - radiusConst,y: radius), radius: radius, startAngle: TMHeartMask.toRadians(-30), endAngle: TMHeartMask.toRadians(140), clockwise: false)
		path.addLine(to: CGPoint(x: center.x, y: width))
		path.close()
		return path
	}
	

}
