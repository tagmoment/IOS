//
//  TMTraingleMask.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 1/2/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit

class TMTraingleMask: TMMask {
	var workingBounds : CGRect
	
	init(rect: CGRect){
		self.workingBounds = rect
	}
	
	func clippingPathWithRect(bounds: CGRect) -> CGPath {
		let somepath = UIBezierPath()
		somepath.moveToPoint(CGPoint(x: workingBounds.width,y: 0.0))
		somepath.addLineToPoint(CGPoint(x: workingBounds.width,y: workingBounds.height))
		somepath.addLineToPoint(CGPoint(x: 0.0, y: workingBounds.height))
		somepath.closePath()
		return somepath.CGPath
	}
	
	var cameraBounds : CGRect{
		return self.workingBounds;
	}
	
	func createViewModel() -> TMMaskViewModel{
		return TMMaskViewModel(name: "nameit")
	}

}
