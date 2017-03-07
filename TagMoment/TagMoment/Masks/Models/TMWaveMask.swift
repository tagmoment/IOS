//
//  TMWaveMask.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 1/4/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit

class TMWaveMask: NSObject, TMMask {
	var workingBounds : CGRect
	
	init(rect: CGRect){
		
		self.workingBounds = rect
	}
	
	func clippingPathWithRect(_ bounds : CGRect) -> CGPath
	{
		let path = UIBezierPath()
		path.move(to: CGPoint(x: self.workingBounds.width/2, y: 0))
		path.addQuadCurve(to: CGPoint(x: self.workingBounds.width/2, y: self.workingBounds.height/2),
			controlPoint: CGPoint(x: self.workingBounds.width/4, y: self.workingBounds.height/4))
		path.addQuadCurve(to: CGPoint(x: self.workingBounds.width/2, y: self.workingBounds.height), controlPoint: CGPoint(x: self.workingBounds.width*3/4, y: self.workingBounds.height*3/4))
		path.addLine(to: CGPoint(x: self.workingBounds.width, y: self.workingBounds.height))
		path.addLine(to: CGPoint(x: self.workingBounds.width, y: 0))
		path.close()
		
		return path.cgPath
	}
		
	var cameraBounds : CGRect{
		return self.workingBounds;
	}
	
	func createViewModel() -> TMMaskViewModel{
		let viewModel = TMMaskViewModel(name: "waves")
		viewModel.maskProductId = "tagmoment_mask_waves_1"
		viewModel.locked = !InAppPurchaseRepo.isProductBought(viewModel.maskProductId)
		return viewModel
	}
}
