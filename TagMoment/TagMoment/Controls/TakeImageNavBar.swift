//
//  TakeImageNavBar.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 2/20/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit
protocol NavBarDelegate : class
{
	func retakeImageRequested()
	func nextStageRequested()
	
}

let FlashChangedNotification = "FlashChangedNotification" as NSString
let FlashStateKey = "FlashStateKey" as NSString

class TakeImageNavBar: UIView {
	
	
	weak var viewDelegate : NavBarDelegate?
	
	@IBOutlet weak var backButton: UIButton!
	
	@IBOutlet weak var rightButton: UIButton!
	
	@IBOutlet weak var middleButton: UIButton!
	
	var currentFlashState = FlashState.Auto
	var flashStateImages = ["flash_off", "flash_on", "flash_auto"]
	
	override func awakeFromNib() {
		self.backButton.alpha = 0.0
	}
	
	@IBAction func backButtonPressed(sender: AnyObject)
	{
		if let delegate = viewDelegate
		{
			delegate.retakeImageRequested()
		}
	}
	
	@IBAction func middleButtonPressed(sender: AnyObject)
	{
		
	}
	
	@IBAction func rightButtonPressed(sender: AnyObject)
	{
		if (rightButton.titleForState(UIControlState.Normal) == nil) //flash button
		{
			toggleFlashState()
		}
		else
		{
			if let delegate = viewDelegate
			{
				delegate.nextStageRequested()
			}
		}
	}
	
	func flashState() -> FlashState
	{
		return FlashState.Auto
	}
	
	func showLeftButton(animated: Bool)
	{
		if animated
		{
			UIView.animateWithDuration(0.5, animations: { () -> Void in
				self.backButton.alpha = 1.0
			})
		}else
		{
			self.backButton.alpha = 1.0
		}
	}
	
	func hideLeftButton(animated: Bool)
	{
		if animated
		{
			UIView.animateWithDuration(0.5, animations: { () -> Void in
				self.backButton.alpha = 0.0
			})
		}else
		{
			self.backButton.alpha = 0.0
		}
	}
	
	func editingStageAppearance(animated: Bool)
	{
		if animated
		{
			
			UIView.animateWithDuration(0.5, animations: { () -> Void in
				self.rightButton.alpha = 0.0
				self.middleButton.alpha = 0.0
			}, completion: { (finished) -> Void in
				self.rightButton.setTitle("Next", forState: UIControlState.Normal)
				self.rightButton.setImage(nil, forState: UIControlState.Normal)
				UIView.animateWithDuration(0.5, animations: { () -> Void in
					self.rightButton.alpha = 1.0
				})
			})
			
		}else
		{
			self.rightButton.setTitle("Next", forState: UIControlState.Normal)
			self.rightButton.setImage(nil, forState: UIControlState.Normal)
			self.rightButton.alpha = 1.0
			self.middleButton.alpha = 0.0
			
		}
	}
	
	func takingImageStageAppearance(animated: Bool)
	{
		self.hideLeftButton(animated)
		if (self.rightButton.titleForState(UIControlState.Normal) == nil)
		{
			return
		}
		
		if (animated)
		{
			UIView.animateWithDuration(0.5, animations: { () -> Void in
				self.rightButton.alpha = 0.0
				
				}, completion: { (finished) -> Void in
					self.zeroFlashState()
					UIView.animateWithDuration(0.5, animations: { () -> Void in
						self.rightButton.alpha = 1.0
						self.middleButton.alpha = 1.0
					})
			})
		}
		else
		{
			self.zeroFlashState()
			self.rightButton.alpha = 1.0
			self.middleButton.alpha = 1.0
		}
		
		
	}
	
	private func toggleFlashState()
	{
		var newFlashState = (currentFlashState.rawValue + 1)%flashStateImages.count
		let flashImage = UIImage(named: flashStateImages[newFlashState])
		self.rightButton.setImage(flashImage, forState: UIControlState.Normal)
		currentFlashState = FlashState(rawValue: newFlashState)!
		NSNotificationCenter.defaultCenter().postNotificationName(FlashChangedNotification, object: nil, userInfo: [FlashStateKey : newFlashState])
	}
	
	private func zeroFlashState()
	{
		currentFlashState = FlashState.Auto
		self.rightButton.setTitle(nil, forState: UIControlState.Normal)
		self.rightButton.setImage(UIImage(named: "flash_auto"), forState: UIControlState.Normal)
		NSNotificationCenter.defaultCenter().postNotificationName(FlashChangedNotification, object: nil, userInfo: [FlashStateKey : currentFlashState.rawValue])
	}
	
}
