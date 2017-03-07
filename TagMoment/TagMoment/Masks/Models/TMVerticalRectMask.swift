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
	
	func clippingPathWithRect(_ bounds: CGRect) -> CGPath {
		let somepath = UIBezierPath(rect: CGRect(x: workingBounds.maxX/2, y: 0 , width: workingBounds.maxX/2, height: workingBounds.height))
		
		return somepath.cgPath
	}
	var cameraBounds : CGRect{
		return self.workingBounds;
	}
	
	func createViewModel() -> TMMaskViewModel{
		return TMMaskViewModel(name: "u&me")
	}
}
