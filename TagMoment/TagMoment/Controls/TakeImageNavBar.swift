//
//  TakeImageNavBar.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 2/20/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit

enum FlashState: Int{
	case off
	case on
	case auto
}

enum TimerState: Int{
	case off = 0
	case three = 3
	case five = 5
}

protocol NavBarDelegate : class
{
	func retakeImageRequested()
	func backButtonRequested()
	func doneButtonPressed()
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
	var currentFlashState = FlashState.auto
	var currentTimerIndex = 0
	var flashStateImages = ["flash_off", "flash_on", "flash_auto"]
	var timerStateImages = [("timericon_off", TimerState.off), ("timericon_3sec", TimerState.three), ("timericon_5sec", TimerState.five)]
	
	
	override func awakeFromNib() {
		self.backButton.alpha = 0.0
		if (UIScreen.main.bounds.height > 480)
		{
			self.changeMasksButton.isHidden = true
		}
	}
	
	@IBAction func backButtonPressed(_ sender: AnyObject)
	{
		if let delegate = viewDelegate
		{
			if (self.backButton.currentTitle == "Back")
			{
				delegate.backButtonRequested()
			}
			else
			{
				delegate.retakeImageRequested()
			}
			
		}
	}
	
	@IBAction func middleButtonPressed(_ sender: AnyObject)
	{
		toggleTimerState()
	}
	
	@IBAction func rightButtonPressed(_ sender: AnyObject)
	{
		if (rightButton.title(for: UIControlState()) == nil) //flash button
		{
			toggleFlashState()
		}
		else if (rightButton.currentTitle == "Done")
		{
			if let delegate = viewDelegate
			{
				delegate.doneButtonPressed()
			}
		}
		else
		{
			if let delegate = viewDelegate
			{
				delegate.nextStageRequested()
			}
		}
	}
	
	@IBAction func maskButtonPressed(_ sender: AnyObject) {
		self.changeMasksButton.isSelected = !self.changeMasksButton.isSelected
		if let delegate = viewDelegate
		{
			delegate.maskButtonPressed()
		}
	}
	
	func replicateJumperButtonToMiddleButton(_ jumper : UIButton)
	{
		self.middleButton.setImage(nil, for: UIControlState())
		jumper.removeConstraints(jumper.constraints)
		jumper.tag = 1222
		self.middleButtonHeightConstraint.constant = 34
		self.middleButtonWidthConstraint.constant = 34
		self.middleButton.pinSubViewToAllEdges(jumper)
		UIView.animate(withDuration: 0.5, animations: { () -> Void in
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
			self.middleButton.setImage(UIImage(named: timerStateImages[currentTimerIndex].0), for: UIControlState())
		}
		
	}
	
	
	func timerState() -> TimerState
	{
		return timerStateImages[currentTimerIndex].1
	}
	
	
	
	func showLeftButton(_ show: Bool, animated: Bool)
	{
		self.showButton(self.backButton, show: show, animated: animated)
	}
	
	func showRightButton(_ show: Bool, animated: Bool)
	{
		self.showButton(self.rightButton, show: show, animated: animated)
	}
	
	func showMiddleButton(_ show: Bool, animated: Bool)
	{
		
		self.showButton(self.middleButton, show: show, animated: animated)
	}
	
	func hideMasksButton(_ animated: Bool)
	{
		if animated
		{
			UIView.animate(withDuration: 0.5, animations: { () -> Void in
				self.changeMasksButton.alpha = 0.0
			})
		}else
		{
			self.changeMasksButton.alpha = 0.0
		}
	}

	fileprivate func showButton(_ view : UIView, show : Bool, animated : Bool)
	{
		let alpha : CGFloat = show ? 1.0 : 0.0
		
		if alpha == view.alpha { return }
		
		if animated
		{
			UIView.animate(withDuration: DefaultAppearanceAnimationTime, animations: { () -> Void in
				view.alpha = alpha
			})
		}else
		{
			view.alpha = alpha
		}
	}
	
	func applyNextButtonAppearanceToRightButton()
	{
		self.rightButton.setTitle("Next", for: UIControlState())
		self.rightButton.setImage(nil, for: UIControlState())
		self.rightButton.setTitleColor(UIColor.white, for: UIControlState())
	}
	
	func applyDoneButtonAppearanceToRightButton()
	{
		self.rightButton.setTitle("Done", for: UIControlState())
		self.rightButton.setImage(nil, for: UIControlState())
		self.rightButton.setTitleColor(UIColor(red: 255.0/255.0, green: 107.0/255.0, blue: 106.0/255.0, alpha: 1.0), for: UIControlState())
	}
	
	func applyCancelButtonAppearanceToBackButton()
	{
		self.backButton.setTitle("Cancel", for: UIControlState())
		self.backButton.setImage(nil, for: UIControlState())
	}
	
	func applyRetakeButtonAppearanceToBackButton()
	{
		self.backButton.setTitle("Retake", for: UIControlState())
		self.backButton.setImage(nil, for: UIControlState())
	}
	
	func applyBackAppearanceToBackButton()
	{
		self.backButton.setTitle("Back", for: UIControlState())
		self.backButton.setImage(nil, for: UIControlState())
	}
	
	
	fileprivate func toggleFlashState()
	{
		let newFlashState = (currentFlashState.rawValue + 1)%flashStateImages.count
		let flashImage = UIImage(named: flashStateImages[newFlashState])
		self.rightButton.setImage(flashImage, for: UIControlState())
		currentFlashState = FlashState(rawValue: newFlashState)!
		NotificationCenter.default.post(name: Notification.Name(rawValue: FlashChangedNotification), object: nil, userInfo: [FlashStateKey : newFlashState])
	}
	
	fileprivate func toggleTimerState()
	{
		currentTimerIndex = (currentTimerIndex + 1)%timerStateImages.count
		let timerImage = UIImage(named: timerStateImages[currentTimerIndex].0)
		self.middleButton.setImage(timerImage, for: UIControlState())
		
	}
	
	func zeroFlashState()
	{
		currentFlashState = FlashState.auto
		self.rightButton.setTitle(nil, for: UIControlState())
		self.rightButton.setImage(UIImage(named: "flash_auto"), for: UIControlState())
		NotificationCenter.default.post(name: Notification.Name(rawValue: FlashChangedNotification), object: nil, userInfo: [FlashStateKey : currentFlashState.rawValue])
	}
	
}
