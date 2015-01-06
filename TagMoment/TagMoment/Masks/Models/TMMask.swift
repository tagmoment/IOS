//
//  TMMask.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 1/2/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit

protocol TMMask {
	var clippingPath: UIBezierPath { get }
	func createViewModel() -> TMMaskViewModel
}
