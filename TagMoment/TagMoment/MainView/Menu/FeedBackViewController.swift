//
//  FeedbackViewController.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 6/1/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit
import MessageUI
import DeviceKit

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
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		GoogleAnalyticsReporter.ReportPageView("FeedBack View")
	}
	
	@IBAction func dislikeButtonPressed(_ sender: AnyObject) {
		alertView = UIAlertView(title: nil, message: DislikeAlertMessage, delegate: self, cancelButtonTitle: WriteUsTitle)
		alertView?.addButton(withTitle: NotNowTitle)
		alertView?.show()
	}
	
	@IBAction func backButtonPressed(_ sender: AnyObject) {
		if let delegate = self.feedbackDelegate
		{
			delegate.backPressed()
		}
	}
	@IBAction func likeButtonPressed(_ sender: AnyObject) {
		alertView = UIAlertView(title: nil, message: LikeMessage, delegate: self, cancelButtonTitle: RateUsTitle)
		alertView?.addButton(withTitle: NotNowTitle)
		alertView?.show()
	}
	
	func composeMail()
	{
		let emailTitle = "Dear Tagmoment Team"
		let toRecipents = [TagMomentTeamMail]
		let mc: MFMailComposeViewController = MFMailComposeViewController()
		mc.mailComposeDelegate = self
		mc.setSubject(emailTitle)
		mc.setToRecipients(toRecipents)
		mc.setMessageBody(self.messageBody(), isHTML: false)
		self.present(mc, animated: true, completion: nil)
	}
	
	fileprivate func messageBody() -> String
	{
		let device = Device()
		let appVersionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String

		return ("Hi,\n I'm using \(device) on iOS \(device.systemVersion) with app version \(appVersionString)...\n")
	}
	
	
	func prepareForSmallScreen()
	{
		if MainViewController.isSmallestScreen()
		{
			self.backButton.isHidden = true
		}
		
	}
	// MARK: - UIAlertViewDelegate
	func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
		let title = alertView.buttonTitle(at: buttonIndex)
		if title == RateUsTitle
		{
			let appUrl = URL(string: "itms-apps://itunes.apple.com/app/id1090349311")
			UIApplication.shared.openURL(appUrl!)
		}
		else if title == WriteUsTitle
		{
			composeMail()
		}
		
		
	}
	
	// MARK: - MFMailComposeViewControllerDelegate
	func mailComposeController(_ controller:MFMailComposeViewController, didFinishWith result:MFMailComposeResult, error:Error?) {
		switch result.rawValue {
		case MFMailComposeResult.cancelled.rawValue:
			NSLog("Mail cancelled")
		case MFMailComposeResult.saved.rawValue:
			NSLog("Mail saved")
		case MFMailComposeResult.sent.rawValue:
			NSLog("Mail sent")
		case MFMailComposeResult.failed.rawValue:
			NSLog("Mail sent failure: %@", [error!.localizedDescription])
		default:
			break
		}
		self.dismiss(animated: true, completion: nil)
		
	}
	
}
