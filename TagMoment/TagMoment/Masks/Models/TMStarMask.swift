//
//  TMStarMask.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 5/19/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit

class TMStarMask: NSObject, TMMask {
	var workingBounds : CGRect
	
	init(rect: CGRect){
		self.workingBounds = rect
	}
	
	func clippingPathWithRect(bounds : CGRect) -> CGPath
	{
		let rectForOval = CGRect(x: 0, y: 0,width: bounds.width, height: bounds.width)
		let starPath = StarMaskPathBuilder().starPath(x: rectForOval.midX, y: rectForOval.midY, radius: bounds.width/5, sides: 5, pointyness: CGFloat(2.5))
		var somepath = UIBezierPath(CGPath: starPath)
		
		return somepath.CGPath
	}
	
	var cameraBounds : CGRect{
		
		return CGRect(x: (self.workingBounds.width - self.workingBounds.width/1.5)/2 , y: self.workingBounds.height/3, width: self.workingBounds.width/1.5, height: self.workingBounds.width/1.5);
	}
	
	func createViewModel() -> TMMaskViewModel{
		return TMMaskViewModel(name: "star")
	}
}
