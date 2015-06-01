//
//  MenuViewController.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 6/1/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
	
    override func viewDidLoad() {
        super.viewDidLoad()
		let blurredView = VisualEffectsUtil.initBlurredOverLay(UIBlurEffectStyle.ExtraLight, toView: self.view)
		if (blurredView != nil)
		{
			self.view.sendSubviewToBack(blurredView!)
		}
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("applicationDidBeComeActive"), name: UIApplicationDidEnterBackgroundNotification, object: nil)
    }

	func applicationDidBeComeActive()
	{
		self.presentingViewController?.dismissViewControllerAnimated(false, completion: nil)
	}
	
	@IBAction func closeButtonPressed(sender: AnyObject) {
		self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
	}
	
	deinit
	{
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
}
