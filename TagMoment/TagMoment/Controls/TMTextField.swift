//
//  TMTextField.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 3/14/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit

protocol TMTextFieldDelegate : UITextFieldDelegate
{
	func deleteBackwardsDetected()
}


class TMTextField: UITextField {
	override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
		let rect =  self.rightViewRectForBounds(bounds)
		return CGRectMake(bounds.origin.x + CGRectGetWidth(rect)/2, bounds.origin.y, bounds.width, bounds.height)
	}
	
	override func textRectForBounds(bounds: CGRect) -> CGRect {
		let rect =  self.rightViewRectForBounds(bounds)
		return CGRectMake(bounds.origin.x + CGRectGetWidth(rect)/2, bounds.origin.y, bounds.width, bounds.height)
	}
	
	override func editingRectForBounds(bounds: CGRect) -> CGRect {
		let rect =  self.rightViewRectForBounds(bounds)
		return CGRectMake(bounds.origin.x + CGRectGetWidth(rect)/2, bounds.origin.y, bounds.width, bounds.height)
	}
	
	override func deleteBackward() {
		
		if let casted = self.delegate! as? TMTextFieldDelegate
		{
			casted.deleteBackwardsDetected()
		}
		super.deleteBackward()
	}
}
