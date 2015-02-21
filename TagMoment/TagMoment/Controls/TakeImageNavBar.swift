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
			UIView.animateWithDuration(0.3, animations: { () -> Void in
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
			UIView.animateWithDuration(0.3, animations: { () -> Void in
				self.backButton.alpha = 0.0
			})
		}else
		{
			self.backButton.alpha = 0.0
		}
	}
	
}
