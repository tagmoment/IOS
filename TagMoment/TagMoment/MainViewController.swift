//
//  ViewController.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 1/2/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController, ChooseMasksControllerDelegate{
	var masksViewController : ChooseMasksViewController!
	var filtersViewController : ChooseFiltersViewController!
	
	var secondImageView : UIImageView!
	var frontCamSessionView : UIView!
	var backCamSessionView : UIView!
	
	var sessionService : CameraSessionService!
	
	var blurredView : UIView?
	
	@IBOutlet weak var canvas: UIImageView!
	@IBOutlet weak var controlContainer: SlidingView!
	
	required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		commonInit()
	}

	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit() {
		sessionService = CameraSessionService()
	}
	
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		masksViewController = ChooseMasksViewController(nibName: "ChooseMasksViewController", bundle: nil)
		println(controlContainer.frame.width)
		controlContainer.addViewWithConstraints(masksViewController.view)
		masksViewController.masksChooseDelegate = self
//		canvas.image = UIImage(named: "image1.jpeg")
		
		secondImageView = UIImageView()
		canvas.pinSubViewToAllEdges(secondImageView)
		initBlurredOverLay(toView: secondImageView)
		canvas.layer.masksToBounds = true
		
		initStageOne()
		
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		self.masksViewController.masksCollectionView.selectItemAtIndexPath(NSIndexPath(forItem: 3, inSection: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.CenteredHorizontally)
		self.masksViewController.collectionView(self.masksViewController.masksCollectionView, didSelectItemAtIndexPath: NSIndexPath(forItem: 3, inSection: 0))
		
	}
	
	
	
	func initBlurredOverLay(toView holder: UIView)
	{
		if let theClass: AnyClass = NSClassFromString("UIVisualEffectView") {
			if !UIAccessibilityIsReduceTransparencyEnabled() {
				let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
				blurredView = UIVisualEffectView(effect: blurEffect)
				holder.pinSubViewToAllEdges(blurredView!);
				
			} else {
				holder.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
			}
		} else {
			holder.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
		}
	}
	
	func initStageOne()
	{
		startSessionOnBackCam()
	}
	
	func initStageTwo()
	{
		
	}
	
	func initStageThree()
	{
		filtersViewController = ChooseFiltersViewController(nibName: "ChooseFiltersViewController", bundle: nil)
		filtersViewController.maskViewModel = masksViewController.getSelectedViewModel()
		filtersViewController.workingImageView = canvas
		controlContainer.addViewWithConstraints(filtersViewController.view)
		controlContainer.animateEnteringView()
		
	}


	func startSessionOnBackCam()
	{
		backCamSessionView = createSessionView()
		backCamSessionView.hidden = false;
		sessionService.startSessionOnBackCamera()
	}
	
	func startSessionOnFrontCam()
	{
		frontCamSessionView = createSessionView()
		sessionService.startSessionOnFrontCamera()
	}
	
	private func createSessionView() -> UIView {
		var sessionView = UIView()
		if (self.isOnFirstStage())
		{
			canvas.pinSubViewToAllEdges(sessionView)
			canvas.bringSubviewToFront(secondImageView)
			sessionView.frame = canvas.frame

		}
		else
		{
			secondImageView.pinSubViewToAllEdges(sessionView)
			secondImageView.backgroundColor = UIColor.clearColor()
			sessionView.frame = canvas.frame
		}
		
		addVideoLayer(toView: sessionView)
		return sessionView
	}
	
	
	private func addVideoLayer(toView host: UIView){
		var captureVideoPreviewLayer = sessionService.initializeSessionForCaptureLayer()
		captureVideoPreviewLayer.frame = host.bounds;
		host.layer.addSublayer(captureVideoPreviewLayer)
		
	}

	func maskChosen(name: String?) {
		if (name != nil){
			var workingRect = CGRect(x: 0.0, y: 0.0, width: self.view.frame.size.width, height: self.canvas.frame.size.height)
			var mask = MaskFactory.maskForName(name!, rect: workingRect)
			var maskLayer = CAShapeLayer()
			maskLayer.path = mask!.clippingPath.CGPath
			secondImageView.layer.mask = maskLayer
		}
	}
	
	func captureButtonPressed() {
//		initStageThree()
		
		sessionService.captureImage { (image: UIImage?, error: NSError!) -> Void in
			if (error != nil)
			{
				/* print error message */
				return
			}
			if (image != nil)
			{
				self.processImage(image)
				if (self.isOnSecondStage())
				{
					self.sessionService.stopCurrentSession()
					self.frontCamSessionView.removeFromSuperview()
					self.frontCamSessionView = nil
					
					self.initStageThree()
					
				}
				else
				{
//					if (self.blurredView != nil)
//					{
//						self.blurredView?.removeFromSuperview()
//					}
					self.switchCamButtonPressed()
					self.initStageTwo()
				}
			}
		}

	}
	
	func switchCamButtonPressed() {
		sessionService.stopCurrentSession()
		
		if (self.frontCamSessionView != nil)
		{
			self.frontCamSessionView.removeFromSuperview()
			self.frontCamSessionView = nil
			startSessionOnBackCam()
		}
		else if (self.backCamSessionView != nil)
		{
			self.backCamSessionView.removeFromSuperview()
			self.backCamSessionView = nil
			startSessionOnFrontCam()
		}
	}
	
	private func isOnFirstStage() -> Bool{
		return (self.canvas.image == nil)
	}
	
	
	private func isOnSecondStage() -> Bool{
		return (self.secondImageView.image != nil)
	}
	
	private func processImage(image: UIImage?) {
		if (image != nil)
		{
			if (self.canvas.image == nil)
			{
				self.canvas.image = image //Populating first stage
			}
			else
			{
				self.secondImageView.image = image
			}
		}
	}
	
	
	
	
}
