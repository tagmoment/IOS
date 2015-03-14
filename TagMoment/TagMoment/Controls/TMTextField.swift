//
//  TMTextField.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 3/14/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit

class TMTextField: UITextField {
	override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
		return CGRectMake(0.0, 4.0, bounds.width, bounds.height - 4.0)
	}
	
	override func textRectForBounds(bounds: CGRect) -> CGRect {
		return CGRectMake(0.0, 4.0, bounds.width, bounds.height - 4.0)
	}
}
