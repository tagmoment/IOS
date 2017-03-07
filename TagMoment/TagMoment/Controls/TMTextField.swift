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
	override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
		let rect =  self.rightViewRect(forBounds: bounds)
		return CGRect(x: bounds.origin.x + rect.width/2, y: bounds.origin.y, width: bounds.width, height: bounds.height)
	}
	
	override func textRect(forBounds bounds: CGRect) -> CGRect {
		let rect =  self.rightViewRect(forBounds: bounds)
		return CGRect(x: bounds.origin.x + rect.width/2, y: bounds.origin.y, width: bounds.width, height: bounds.height)
	}
	
	override func editingRect(forBounds bounds: CGRect) -> CGRect {
		let rect =  self.rightViewRect(forBounds: bounds)
		return CGRect(x: bounds.origin.x + rect.width/2, y: bounds.origin.y, width: bounds.width, height: bounds.height)
	}
	
	override func deleteBackward() {
		
		if let casted = self.delegate! as? TMTextFieldDelegate
		{
			casted.deleteBackwardsDetected()
		}
		super.deleteBackward()
	}
	
	override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
		UIMenuController.shared.isMenuVisible = false
		return false;
	}
	
	override func caretRect(for position: UITextPosition) -> CGRect {
		return super.caretRect(for: self.endOfDocument)
	}
	
}
