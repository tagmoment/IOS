//
//  MenuViewController.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 31/10/2015.
//  Copyright © 2015 TagMoment. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController, FeedbackViewControllerDelegate, UIGestureRecognizerDelegate{

	@IBOutlet weak var closeButton: UIButton!
	@IBOutlet weak var container: UIView!
	@IBOutlet weak var closeButtonLeftConstraint: NSLayoutConstraint!
	@IBOutlet weak var containerHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var closeButtonBottomConstraint: NSLayoutConstraint!
	weak var bottomConstraint: NSLayoutConstraint!
	
	var containerHeight : CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
		containerHeightConstraint.constant = containerHeight
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(MenuViewController.closePressed(_:)))
		tapGesture.delegate = self
		self.view.addGestureRecognizer(tapGesture)
		self.view.userInteractionEnabled = true
    }
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		GoogleAnalyticsReporter.ReportPageView("Menu View");
		self.bottomConstraint.constant = 0
		UIView.animateWithDuration(0.3		, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
			self.view.superview?.layoutIfNeeded()
			}, completion: nil)
		
	}
	
	func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool
	{
		if (self.childViewControllers.count > 0 && self.childViewControllers[0] is AboutUsViewController)
		{
			return false
		}
		
		return true
	}
	
	@IBAction func restoreInAppPurchaseRequested(sender: AnyObject) {
		let mainController = UIApplication.sharedApplication().delegate?.window!?.rootViewController! as! MainViewController
		mainController.inAppPurchaseDataProvider.restorePayments()
	}
	func backPressed() {
		let controller = self.childViewControllers[0]
		controller.removeFromParentViewController()
		UIView.animateWithDuration(0.3, animations: { () -> Void in
			controller.view.alpha = 0.0
			
			}, completion: { (done: Bool) -> Void in
				controller.view.removeFromSuperview()
				UIView.animateWithDuration(0.3, animations: { () -> Void in
					
				for view in self.container.subviews
				{
					view.alpha = 1.0
				}
				})
		})
	}
	
	@IBAction func ourStoryPressed(sender: AnyObject) {
		let aboutUs = AboutUsViewController(nibName:"AboutUsViewController", bundle:  nil)
		aboutUs.addToView(self.view)
		self.addChildViewController(aboutUs)
	}
	
	@IBAction func inviteFriendsPressed(sender: AnyObject) {
		let message = "Easily and creatively be a part of your pictures and capture your life moments. Download for free: https://itunes.apple.com/us/app/moment/id1090349311"
		let activityViewController = UIActivityViewController(activityItems: [message], applicationActivities: nil)
		if let controller = UIApplication.sharedApplication().delegate?.window?!.rootViewController
		{
			controller.presentViewController(activityViewController, animated: true, completion: { () -> Void in
				print("something")
			})
		}
		
	}

	@IBAction func feedbackPressed(sender: AnyObject) {
		
		let feedBackCont = FeedbackViewController(nibName:"FeedbackViewController", bundle:  nil)
		feedBackCont.feedbackDelegate = self
		self.addChildViewController(feedBackCont)
		UIView.animateWithDuration(0.3, animations: { () -> Void in
			for view in self.container.subviews
			{
				view.alpha = 0.0
			}
			}, completion: { (done: Bool) -> Void in
				feedBackCont.view.alpha = 0.0
				self.container.pinSubViewToAllEdges(feedBackCont.view)
				feedBackCont.prepareForSmallScreen()
				UIView.animateWithDuration(0.3, animations: { () -> Void in
					feedBackCont.view.alpha = 1.0
				})
		})
		
		
	}
	
	
	@IBAction func closePressed(sender: AnyObject) {
		NSNotificationCenter.defaultCenter().postNotificationName(MenuWillDisappearNotificationName, object: nil)
		self.closeView({ (finished : Bool) -> Void in
			self.view.removeFromSuperview()
			self.removeFromParentViewController()
		})

	}
	
	
	func prepareForSmallScreen()
	{
		if MainViewController.isSmallestScreen()
		{
			self.closeButton.hidden = true
		}
		
	}
	
	private func closeView(completion : ((Bool) -> Void)?)
	{
		self.bottomConstraint.constant = containerHeight
		UIView.animateWithDuration(0.3 , delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
			self.view.superview?.layoutIfNeeded()
			}, completion: completion)
	}
	
	func addToView(superview : UIView)
	{
		
		NSNotificationCenter.defaultCenter().postNotificationName(MenuWillAppearNotificationName, object: nil)
		self.bottomConstraint = superview.pinSubViewToBottom(self.view, heightContraint: containerHeight)
		let heightContraint = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: superview.frame.height)
		self.view.addConstraint(heightContraint)
		containerHeightConstraint.constant = containerHeight
	}
	
	
}
