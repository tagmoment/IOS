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
	@IBOutlet weak var buttonsHolder: UIView!
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
		prepareSocialButtonsAnimationState()
		
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		animateButtonEntrance()
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

	// MARK: - Animations
	func prepareSocialButtonsAnimationState()
	{
		for view in self.buttonsHolder.subviews
		{
			view.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
		}
	}
	
	func animateButtonEntrance()
	{
		var shuffled = self.buttonsHolder.subviews.shuffled()
		for i : Int in 0..<shuffled.count
		{
			let view = shuffled[i] as UIView
			let delay = Double(i)*0.1
			UIView.animateWithDuration(1.0, delay: delay ,usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
				view.layer.transform = CATransform3DIdentity
			}, completion: nil)
			
		}
	}
	
	// MARK: - Buttons Handling
	@IBAction func pinButtonPressed(sender: AnyObject) {
		prepareSocialButtonsAnimationState()
		animateButtonEntrance()
	}
	

}
