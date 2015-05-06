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
	
	func clippingPathWithRect(bounds: CGRect) -> CGPath
	{
		return UIBezierPath().CGPath
	}
	
	var cameraBounds : CGRect{
		return self.workingBounds;
	}
	
	func createViewModel() -> TMMaskViewModel{
		var viewModel = TMMaskViewModel(name: "casual")
		viewModel.hasOneCapture = true;
		return viewModel
	}
	
}
