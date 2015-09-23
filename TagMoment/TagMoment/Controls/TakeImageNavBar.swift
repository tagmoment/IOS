//
//  TakeImageNavBar.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 2/20/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit

enum FlashState: Int{
	case Off
	case On
	case Auto
}

enum TimerState: Int{
	case Off = 0
	case Three = 3
	case Five = 5
}

protocol NavBarDelegate : class
{
	func retakeImageRequested()
	func nextStageRequested()
	func maskButtonPressed()
	func editingStageWillAppear()
	
}

let FlashChangedNotification = "FlashChangedNotification"
let FlashStateKey = "FlashStateKey"

class TakeImageNavBar: UIView {
	
	let DefaultAppearanceAnimationTime = 0.4
	
	weak var viewDelegate : NavBarDelegate?
	
	@IBOutlet weak var middleButtonWidthConstraint: NSLayoutConstraint!
	@IBOutlet weak var middleButtonHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var backButton: UIButton!
	
	@IBOutlet weak var rightButton: UIButton!
	
	@IBOutlet weak var middleButton: UIButton!
	
	@IBOutlet weak var changeMasksButton: UIButton!
	var currentFlashState = FlashState.Auto
	var currentTimerIndex = 0
	var flashStateImages = ["flash_off", "flash_on", "flash_auto"]
	var timerStateImages = [("timericon_off", TimerState.Off), ("timericon_3sec", TimerState.Three), ("timericon_5sec", TimerState.Five)]
	
	
	override func awakeFromNib() {
		self.backButton.alpha = 0.0
		if (UIScreen.mainScreen().bounds.height > 480)
		{
			self.changeMasksButton.hidden = true
		}
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
		toggleTimerState()
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
	
	@IBAction func maskButtonPressed(sender: AnyObject) {
		self.changeMasksButton.selected = !self.changeMasksButton.selected
		if let delegate = viewDelegate
		{
			delegate.maskButtonPressed()
		}
	}
	
	func replicateJumperButtonToMiddleButton(jumper : UIButton)
	{
		self.middleButton.setImage(nil, forState: UIControlState.Normal)
		jumper.removeConstraints(jumper.constraints())
		jumper.tag = 1222
		self.middleButtonHeightConstraint.constant = 34
		self.middleButtonWidthConstraint.constant = 34
		self.middleButton.pinSubViewToAllEdges(jumper)
		UIView.animateWithDuration(0.5, animations: { () -> Void in
			self.middleButton.alpha = 1.0
		})
	}
	
	func restoreMiddleButton()
	{
		if (self.middleButton.subviews.count != 0)
		{
			let jumper = self.middleButton.viewWithTag(1222)
			if (jumper != nil)
			{
				jumper?.removeFromSuperview()
			}
			currentTimerIndex = 0
			self.middleButton.setImage(UIImage(named: timerStateImages[currentTimerIndex].0), forState: UIControlState.Normal)
		}
		
	}
	
	
	func timerState() -> TimerState
	{
		return timerStateImages[currentTimerIndex].1
	}
	
	func flashState() -> FlashState
	{
		return FlashState.Auto
	}
	
	
	
	func showLeftButton(show: Bool, animated: Bool)
	{
		self.showButton(self.backButton, show: show, animated: animated)
	}
	
	func showRightButton(show: Bool, animated: Bool)
	{
		self.showButton(self.rightButton, show: show, animated: animated)
	}
	
	func showMiddleButton(show: Bool, animated: Bool)
	{
		
		self.showButton(self.middleButton, show: show, animated: animated)
	}
	
	func hideMasksButton(animated: Bool)
	{
		if animated
		{
			UIView.animateWithDuration(0.5, animations: { () -> Void in
				self.changeMasksButton.alpha = 0.0
			})
		}else
		{
			self.changeMasksButton.alpha = 0.0
		}
	}

	private func showButton(view : UIView, show : Bool, animated : Bool)
	{
		let alpha : CGFloat = show ? 1.0 : 0.0
		
		if alpha == view.alpha { return }
		
		if animated
		{
			UIView.animateWithDuration(DefaultAppearanceAnimationTime, animations: { () -> Void in
				view.alpha = alpha
			})
		}else
		{
			view.alpha = alpha
		}
	}
	
	func applyNextButtonAppearanceToRightButton()
	{
		self.rightButton.setTitle("Next", forState: UIControlState.Normal)
		self.rightButton.setImage(nil, forState: UIControlState.Normal)
	}
	
	func applyCancelButtonAppearanceToBackButton()
	{
		self.backButton.setTitle("Cancel", forState: UIControlState.Normal)
		self.backButton.setImage(nil, forState: UIControlState.Normal)
	}
	
	func applyRetakeButtonAppearanceToBackButton()
	{
		self.backButton.setTitle("Retake", forState: UIControlState.Normal)
		self.backButton.setImage(nil, forState: UIControlState.Normal)
	}
	
	private func toggleFlashState()
	{
		var newFlashState = (currentFlashState.rawValue + 1)%flashStateImages.count
		let flashImage = UIImage(named: flashStateImages[newFlashState])
		self.rightButton.setImage(flashImage, forState: UIControlState.Normal)
		currentFlashState = FlashState(rawValue: newFlashState)!
		NSNotificationCenter.defaultCenter().postNotificationName(FlashChangedNotification, object: nil, userInfo: [FlashStateKey : newFlashState])
	}
	
	private func toggleTimerState()
	{
		currentTimerIndex = (currentTimerIndex + 1)%timerStateImages.count
		let timerImage = UIImage(named: timerStateImages[currentTimerIndex].0)
		self.middleButton.setImage(timerImage, forState: UIControlState.Normal)
		
	}
	
	func zeroFlashState()
	{
		currentFlashState = FlashState.Auto
		self.rightButton.setTitle(nil, forState: UIControlState.Normal)
		self.rightButton.setImage(UIImage(named: "flash_auto"), forState: UIControlState.Normal)
		NSNotificationCenter.defaultCenter().postNotificationName(FlashChangedNotification, object: nil, userInfo: [FlashStateKey : currentFlashState.rawValue])
	}
	
}
