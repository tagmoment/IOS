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
		self.view.isUserInteractionEnabled = true
    }
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		GoogleAnalyticsReporter.ReportPageView("Menu View");
		self.bottomConstraint.constant = 0
		UIView.animate(withDuration: 0.3		, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
			self.view.superview?.layoutIfNeeded()
			}, completion: nil)
		
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool
	{
		if (self.childViewControllers.count > 0 && self.childViewControllers[0] is AboutUsViewController)
		{
			return false
		}
		
		return true
	}
	
	@IBAction func restoreInAppPurchaseRequested(_ sender: AnyObject) {
		let mainController = UIApplication.shared.delegate?.window!?.rootViewController! as! MainViewController
		mainController.inAppPurchaseDataProvider.restorePayments()
	}
	func backPressed() {
		let controller = self.childViewControllers[0]
		controller.removeFromParentViewController()
		UIView.animate(withDuration: 0.3, animations: { () -> Void in
			controller.view.alpha = 0.0
			
			}, completion: { (done: Bool) -> Void in
				controller.view.removeFromSuperview()
				UIView.animate(withDuration: 0.3, animations: { () -> Void in
					
				for view in self.container.subviews
				{
					view.alpha = 1.0
				}
				})
		})
	}
	
	@IBAction func ourStoryPressed(_ sender: AnyObject) {
		let aboutUs = AboutUsViewController(nibName:"AboutUsViewController", bundle:  nil)
		aboutUs.addToView(self.view)
		self.addChildViewController(aboutUs)
	}
	
	@IBAction func inviteFriendsPressed(_ sender: AnyObject) {
		let message = "Easily and creatively be a part of your pictures and capture your life moments. Download for free: https://itunes.apple.com/us/app/moment/id1090349311"
		let activityViewController = UIActivityViewController(activityItems: [message], applicationActivities: nil)
		if let controller = UIApplication.shared.delegate?.window?!.rootViewController
		{
			controller.present(activityViewController, animated: true, completion: { () -> Void in
				print("something")
			})
		}
		
	}

	@IBAction func feedbackPressed(_ sender: AnyObject) {
		
		let feedBackCont = FeedbackViewController(nibName:"FeedbackViewController", bundle:  nil)
		feedBackCont.feedbackDelegate = self
		self.addChildViewController(feedBackCont)
		UIView.animate(withDuration: 0.3, animations: { () -> Void in
			for view in self.container.subviews
			{
				view.alpha = 0.0
			}
			}, completion: { (done: Bool) -> Void in
				feedBackCont.view.alpha = 0.0
				self.container.pinSubViewToAllEdges(feedBackCont.view)
				feedBackCont.prepareForSmallScreen()
				UIView.animate(withDuration: 0.3, animations: { () -> Void in
					feedBackCont.view.alpha = 1.0
				})
		})
		
		
	}
	
	
	@IBAction func closePressed(_ sender: AnyObject) {
		NotificationCenter.default.post(name: Notification.Name(rawValue: MenuWillDisappearNotificationName), object: nil)
		self.closeView({ (finished : Bool) -> Void in
			self.view.removeFromSuperview()
			self.removeFromParentViewController()
		})

	}
	
	
	func prepareForSmallScreen()
	{
		if MainViewController.isSmallestScreen()
		{
			self.closeButton.isHidden = true
		}
		
	}
	
	fileprivate func closeView(_ completion : ((Bool) -> Void)?)
	{
		self.bottomConstraint.constant = containerHeight
		UIView.animate(withDuration: 0.3 , delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
			self.view.superview?.layoutIfNeeded()
			}, completion: completion)
	}
	
	func addToView(_ superview : UIView)
	{
		
		NotificationCenter.default.post(name: Notification.Name(rawValue: MenuWillAppearNotificationName), object: nil)
		self.bottomConstraint = superview.pinSubViewToBottom(self.view, heightContraint: containerHeight)
		let heightContraint = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: superview.frame.height)
		self.view.addConstraint(heightContraint)
		containerHeightConstraint.constant = containerHeight
	}
	
	
}
