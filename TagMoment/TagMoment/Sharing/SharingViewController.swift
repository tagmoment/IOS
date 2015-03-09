//
//  SharingViewController.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 2/22/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit
import Foundation
protocol SharingControllerDelegate : class{
	func taggingKeyboardWillChange(animationTime : Double, endFrame: CGRect)
	func updateUserInfoText(newText : String)
}

class SharingViewController: UIViewController, UITextFieldDelegate	{

	weak var sharingDelegate: SharingControllerDelegate?
	
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var shareButton: UIButton!
	@IBOutlet weak var saveImageButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
		var bgImage = shareButton.backgroundImageForState(UIControlState.Normal)
		bgImage = bgImage?.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 46, bottom: 0, right: 0))
		shareButton.setBackgroundImage(bgImage, forState: UIControlState.Normal)
		bgImage = saveImageButton.backgroundImageForState(UIControlState.Normal)
		bgImage = bgImage?.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 46))
		saveImageButton.setBackgroundImage(bgImage, forState: UIControlState.Normal)
		
    }

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboardNotification:", name: UIKeyboardWillChangeFrameNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldDidChangeText:", name: UITextFieldTextDidChangeNotification, object: nil)
	}
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	func handleKeyboardNotification(notif: NSNotification)
	{
		let animationTime = notif.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as Double
		let keyboardEndFrame = notif.userInfo?[UIKeyboardFrameEndUserInfoKey] as NSValue
		
		
		if let delegate = self.sharingDelegate
		{
			delegate.taggingKeyboardWillChange(animationTime, endFrame: keyboardEndFrame.CGRectValue())
		}
	}
	func textFieldDidChangeText(notif: NSNotification)
	{
				if let delegate = self.sharingDelegate
				{
					delegate.updateUserInfoText(textField.text)
				}

	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool
	{
		self.textField .resignFirstResponder()
		return true
	}

	
	

}
