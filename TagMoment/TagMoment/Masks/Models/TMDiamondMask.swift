//
//  TMDiamondMask.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 5/12/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation

class TMDiamondMask :  TMMask {
	
	let percentageOfWidth = CGFloat(0.6)
	let percentageOfHeight = CGFloat(0.9)
	var workingBounds : CGRect
	
	init(rect: CGRect){
		self.workingBounds = rect
	}
	
	func clippingPathWithRect(bounds : CGRect) -> CGPath
	{
		let path = UIBezierPath()
		path.moveToPoint(CGPoint(x: bounds.width/2, y: 0))
		path.addLineToPoint(CGPoint(x: 0, y: bounds.height/2))
		path.addLineToPoint(CGPoint(x: bounds.width/2, y: bounds.height))
		path.addLineToPoint(CGPoint(x: bounds.width, y: bounds.height/2))
		path.closePath()
		
		return path.CGPath
	}
	
	var cameraBounds : CGRect{
		let currentWidth = self.workingBounds.width*percentageOfWidth
		let currentHeight = self.workingBounds.height*percentageOfHeight
		let marginHori = (self.workingBounds.width - currentWidth)/2
		let marginVert = (self.workingBounds.height - currentHeight)/2
		return CGRect(x: marginHori, y: marginVert, width: currentWidth, height: currentHeight);
	}
	
	func createViewModel() -> TMMaskViewModel{
		return TMMaskViewModel(name: "diamond")
	}
	
}