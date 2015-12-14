//
//  FeedbackViewController.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 6/1/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit
import MessageUI

let DislikeAlertMessage = "We Want to Make You Happy! Please Tell Us More About Your Experience"
let LikeMessage = "Thank You for Your Positive Feedback. Please Rate Us On The App Store"
let RateUsTitle = "Rate Us"
let WriteUsTitle = "Write Us"
let NotNowTitle = "Not Now"
let TagMomentTeamMail = "team@tagmoment.me"

protocol FeedbackViewControllerDelegate : class{
	func backPressed()
}

class FeedbackViewController: UIViewController, UIAlertViewDelegate, MFMailComposeViewControllerDelegate{
	@IBOutlet weak var backButton: UIButton!
	var alertView : UIAlertView?
	weak var feedbackDelegate: FeedbackViewControllerDelegate?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
	
	@IBAction func dislikeButtonPressed(sender: AnyObject) {
		alertView = UIAlertView(title: nil, message: DislikeAlertMessage, delegate: self, cancelButtonTitle: WriteUsTitle)
		alertView?.addButtonWithTitle(NotNowTitle)
		alertView?.show()
	}
	
	@IBAction func backButtonPressed(sender: AnyObject) {
		if let delegate = self.feedbackDelegate
		{
			delegate.backPressed()
		}
	}
	@IBAction func likeButtonPressed(sender: AnyObject) {
		alertView = UIAlertView(title: nil, message: LikeMessage, delegate: self, cancelButtonTitle: RateUsTitle)
		alertView?.addButtonWithTitle(NotNowTitle)
		alertView?.show()
	}
	
	func composeMail()
	{
		let emailTitle = "Dear #moment Team"
		let toRecipents = [TagMomentTeamMail]
		let mc: MFMailComposeViewController = MFMailComposeViewController()
		mc.mailComposeDelegate = self
		mc.setSubject(emailTitle)
		mc.setToRecipients(toRecipents)
		
		self.presentViewController(mc, animated: true, completion: nil)
	}
	
	
	func prepareForSmallScreen()
	{
		if MainViewController.isSmallestScreen()
		{
			self.backButton.hidden = true
		}
		
	}
	// MARK: - UIAlertViewDelegate
	func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int) {
		let title = alertView.buttonTitleAtIndex(buttonIndex)
		if title == RateUsTitle
		{
			let appUrl = NSURL(string: "itms-apps://itunes.apple.com/app/id1055459044")
			UIApplication.sharedApplication().openURL(appUrl!)
		}
		else if title == WriteUsTitle
		{
			composeMail()
		}
		
		
	}
	
	// MARK: - MFMailComposeViewControllerDelegate
	func mailComposeController(controller:MFMailComposeViewController, didFinishWithResult result:MFMailComposeResult, error:NSError?) {
		switch result.rawValue {
		case MFMailComposeResultCancelled.rawValue:
			NSLog("Mail cancelled")
		case MFMailComposeResultSaved.rawValue:
			NSLog("Mail saved")
		case MFMailComposeResultSent.rawValue:
			NSLog("Mail sent")
		case MFMailComposeResultFailed.rawValue:
			NSLog("Mail sent failure: %@", [error!.localizedDescription])
		default:
			break
		}
		self.dismissViewControllerAnimated(true, completion: nil)
		
	}
	
}
