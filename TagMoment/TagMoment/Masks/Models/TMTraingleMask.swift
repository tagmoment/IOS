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
	
	var clippingPath : UIBezierPath{
		var somepath = UIBezierPath()
		somepath.moveToPoint(CGPoint(x: 0.0,y: 0.0))
		somepath.addLineToPoint(CGPoint(x: 0.0,y: workingBounds.height))
		somepath.addLineToPoint(CGPoint(x: workingBounds.width, y: workingBounds.height))
		somepath.closePath()
		return somepath
	}
	
	func createViewModel() -> TMMaskViewModel{
		return TMMaskViewModel(name: " nameit")
	}

}
