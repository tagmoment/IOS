//
//  TMVerticalRectMask.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 1/3/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit

class TMVerticalRectMask: TMMask{
	var workingBounds : CGRect
	
	init(rect: CGRect){
		self.workingBounds = rect
	}
	
	var clippingPath : UIBezierPath{
		var somepath = UIBezierPath(rect: CGRect(x: 0.0, y: 0.0, width: workingBounds.maxX/2, height: workingBounds.height))
		
		return somepath
	}

	func createViewModel() -> TMMaskViewModel{
		return TMMaskViewModel(name: "uandme")
	}
}
