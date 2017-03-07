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
	
	func clippingPathWithRect(_ bounds: CGRect) -> CGPath {
		let somepath = UIBezierPath()
		somepath.move(to: CGPoint(x: workingBounds.width,y: 0.0))
		somepath.addLine(to: CGPoint(x: workingBounds.width,y: workingBounds.height))
		somepath.addLine(to: CGPoint(x: 0.0, y: workingBounds.height))
		somepath.close()
		return somepath.cgPath
	}
	
	var cameraBounds : CGRect{
		return self.workingBounds;
	}
	
	func createViewModel() -> TMMaskViewModel{
		return TMMaskViewModel(name: "diagonal")
	}

}
