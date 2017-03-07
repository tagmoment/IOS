//
//  TMMask.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 1/2/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit

protocol TMMask {
	var cameraBounds : CGRect { get }
	
	func clippingPathWithRect(_ bounds : CGRect) -> CGPath
	func createViewModel() -> TMMaskViewModel
}
