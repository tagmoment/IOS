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
		let blurredView = VisualEffectsUtil.initBlurredOverLay(TagMomentBlurEffect.extraLight, toView: self.view)
		if (blurredView != nil)
		{
			self.view.sendSubview(toBack: blurredView!)
		}
		
		if MainViewController.isSmallestScreen()
		{
			self.view.backgroundColor = UIColor(white: 0.7, alpha: 0.8)
		}
		
		
    }

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		GoogleAnalyticsReporter.ReportPageView("AboutUs View");

		self.bottomConstraint.constant = 0
		UIView.animate(withDuration: 0.5, animations: { () -> Void in
			self.view.superview?.layoutIfNeeded()
		})
		
	}
	@IBAction func closePressed(_ sender: AnyObject) {
		self.bottomConstraint.constant = self.view.superview!.frame.height
		UIView.animate(withDuration: 0.5, animations: { () -> Void in
			self.view.superview?.layoutIfNeeded()
			}, completion: { (done: Bool) -> Void in
				self.removeFromParentViewController()
				self.view.removeFromSuperview()
		})
	}
	
	func addToView(_ superview : UIView)
	{
		self.bottomConstraint = superview.pinSubViewToBottom(self.view, heightContraint: superview.frame.height)
		let heightContraint = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: superview.frame.height)
		self.view.addConstraint(heightContraint)
	}
}
