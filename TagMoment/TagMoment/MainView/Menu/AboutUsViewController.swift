//
//  AboutUsViewController.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 31/10/2015.
//  Copyright © 2015 TagMoment. All rights reserved.
//

import UIKit

class AboutUsViewController: UIViewController {
	
	weak var bottomConstraint : NSLayoutConstraint!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		let blurredView = VisualEffectsUtil.initBlurredOverLay(TagMomentBlurEffect.ExtraLight, toView: self.view)
		if (blurredView != nil)
		{
			self.view.sendSubviewToBack(blurredView!)
		}
		
		if MainViewController.isSmallestScreen()
		{
			self.view.backgroundColor = UIColor(white: 0.7, alpha: 0.8)
		}
		
		
    }

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		GoogleAnalyticsReporter.ReportPageView("AboutUs View");

		self.bottomConstraint.constant = 0
		UIView.animateWithDuration(0.5, animations: { () -> Void in
			self.view.superview?.layoutIfNeeded()
		})
		
	}
	@IBAction func closePressed(sender: AnyObject) {
		self.bottomConstraint.constant = self.view.superview!.frame.height
		UIView.animateWithDuration(0.5, animations: { () -> Void in
			self.view.superview?.layoutIfNeeded()
			}, completion: { (done: Bool) -> Void in
				self.removeFromParentViewController()
				self.view.removeFromSuperview()
		})
	}
	
	func addToView(superview : UIView)
	{
		self.bottomConstraint = superview.pinSubViewToBottom(self.view, heightContraint: superview.frame.height)
		let heightContraint = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: superview.frame.height)
		self.view.addConstraint(heightContraint)
	}
}
