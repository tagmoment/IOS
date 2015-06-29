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
	
	@IBAction func cameraRollButtonPressed(sender: AnyObject) {
		let presentor = self.presentingViewController
		presentor?.dismissViewControllerAnimated(true, completion: { () -> Void in
			let cameraRollCont = CameraRollViewController(nibName: "CameraRollViewController", bundle: nil)
			self.addCameraRollController(cameraRollCont)
			
		})

	}
	
	
	@IBAction func closeButtonPressed(sender: AnyObject) {
		self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
	}
	
	@IBAction func feedbackButtonPressed(sender: AnyObject) {
		let presentor = self.presentingViewController
		presentor?.dismissViewControllerAnimated(true, completion: { () -> Void in
				let feedbackCont = FeedbackViewController(nibName: "FeedbackViewController", bundle: nil)
			UIApplication.sharedApplication().delegate?.window!?.rootViewController!.presentViewController(feedbackCont, animated: true, completion: nil)
			})
		
	}
	
	private func addCameraRollController(toController : CameraRollViewController)
	{
		let mainController = UIApplication.sharedApplication().delegate?.window!?.rootViewController! as! MainViewController
		toController.originalHeight = mainController.masksViewController.view.frame.height
		toController.addToView(mainController.view)
		mainController.addChildViewController(toController)
	}
	
	deinit
	{
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
}
