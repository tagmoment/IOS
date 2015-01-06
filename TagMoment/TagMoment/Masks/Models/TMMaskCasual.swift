//
//  TMMaskCasual.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 1/6/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit

class TMMaskCasual: TMMask {
	var workingBounds : CGRect
	
	init(rect: CGRect){
		self.workingBounds = rect
	}
	
	var clippingPath : UIBezierPath{
		
		return UIBezierPath()
	}
	
	func createViewModel() -> TMMaskViewModel{
		return TMMaskViewModel(name: "casual")
	}
}
