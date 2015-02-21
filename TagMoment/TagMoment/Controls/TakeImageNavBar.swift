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
}


class TakeImageNavBar: UIView {
	weak var viewDelegate : NavBarDelegate?
	
	@IBOutlet weak var backButton: UIButton!
	
	@IBOutlet weak var rightButton: UIButton!
	
	@IBOutlet weak var middleButton: UIButton!
	
	
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
		
	}
	
	func flashState() -> FlashState
	{
		return .None
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
		}
	}
	
	func takingImageStageAppearance(animated: Bool)
	{
		if (self.rightButton.titleForState(UIControlState.Normal) == nil)
		{
			return
		}
		UIView.animateWithDuration(0.5, animations: { () -> Void in
			self.rightButton.alpha = 0.0
			
			}, completion: { (finished) -> Void in
				self.rightButton.setTitle(nil, forState: UIControlState.Normal)
				self.rightButton.setImage(UIImage(named: "flash_auto"), forState: UIControlState.Normal)
				UIView.animateWithDuration(0.5, animations: { () -> Void in
					self.rightButton.alpha = 1.0
					self.middleButton.alpha = 1.0
				})
		})
	}
	
}
