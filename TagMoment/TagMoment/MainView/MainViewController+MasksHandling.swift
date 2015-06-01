//
//  MainViewController+MasksHandling.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 5/6/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation
extension MainViewController
{
	func maskLayerAndBoundsForMaskName(name: String?) -> (CAShapeLayer?, CGRect?)
	{
		if name == nil
		{
			return (nil, nil);
		}
		
		
		var workingRect = CGRect(x: 0.0, y: 0.0, width: UIScreen.mainScreen().bounds.width, height: UIScreen.mainScreen().bounds.width)
		let mask = MaskFactory.maskForName(name!, rect: workingRect)
		var maskLayer = CAShapeLayer()
		maskLayer.path = mask!.clippingPathWithRect(mask!.cameraBounds)
		return (maskLayer,mask!.cameraBounds)
	}
}