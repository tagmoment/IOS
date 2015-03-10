//
//  ViewController.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 1/2/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit
import AVFoundation

enum FlashState{
	case None
	case On
	case Auto
}

class MainViewController: UIViewController, ChooseMasksControllerDelegate, ChooseFiltesControllerDelegate, NavBarDelegate, SharingControllerDelegate{
	
	let CachedImagePathKey = "cachedImagePathKey"
	
	var masksViewController : ChooseMasksViewController!
	var filtersViewController : ChooseFiltersViewController!
	var sharingController : SharingViewController!
	var navigationView : TakeImageNavBar!
	
	var secondImageView : UIImageView!
	var frontCamSessionView : UIView!
	var backCamSessionView : UIView!
	
	
	var sessionService : CameraSessionService!
	
	var blurredView : UIView?
	
	@IBOutlet weak var logoLabel: UILabel!
	@IBOutlet weak var userLabel: UILabel!
	@IBOutlet weak var infoTopConstraint: NSLayoutConstraint!
	@IBOutlet weak var controlContainerHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var canvas: UIImageView!
	@IBOutlet weak var controlContainer: SlidingView!
	@IBOutlet weak var infobarHolder: UIView!
	
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
		controlContainer.addViewWithConstraints(masksViewController.view, toTheRight: true)
		masksViewController.masksChooseDelegate = self

		secondImageView = UIImageView()
		secondImageView.contentMode = UIViewContentMode.ScaleAspectFill
		canvas.pinSubViewToAllEdges(secondImageView)
		initBlurredOverLay(toView: secondImageView)
		canvas.layer.masksToBounds = true
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		initStageOne()
		
		
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
		navigationView = NSBundle.mainBundle().loadNibNamed("NavbarView", owner: nil, options: nil)[0] as TakeImageNavBar
		infobarHolder.pinSubViewToAllEdges(navigationView)
		navigationView.viewDelegate = self
#if (arch(i386) || arch(x86_64)) && os(iOS)

		print("In smulator stage 1")
#else
		startSessionOnBackCam()
#endif
}
	
	func initStageTwo()
	{
		
	}
	
	func initStageThree()
	{
		filtersViewController = ChooseFiltersViewController(nibName: "ChooseFiltersViewController", bundle: nil)
		filtersViewController.maskViewModel = masksViewController.getSelectedViewModel()
		filtersViewController.workingImageView = canvas
		filtersViewController.filtersChooseDelegate = self
		controlContainer.addViewWithConstraints(filtersViewController.view, toTheRight: true)
		controlContainer.animateEnteringView()
		navigationView.editingStageAppearance(true)
		masksViewController = nil;
		
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
			sessionView.frame = canvas.bounds

		}
		else
		{
			secondImageView.pinSubViewToAllEdges(sessionView)
//			secondImageView.backgroundColor = UIColor.clearColor()
			sessionView.frame = canvas.bounds
		}
		
		addVideoLayer(toView: sessionView)
		return sessionView
	}
	
	
	private func addVideoLayer(toView host: UIView){
		var captureVideoPreviewLayer = sessionService.initializeSessionForCaptureLayer()
		captureVideoPreviewLayer.frame = host.bounds
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
	
	func saveTempImage()
	{
		
		let imageData = UIImagePNGRepresentation(imageForCaching())
		
		let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true);
		let documentsDirectory = paths[0] as String
		let imagePath = documentsDirectory + "/cached.png"
		
		if !imageData.writeToFile(imagePath, atomically: false)
		{
			print("Failed to cache image data to disk")
		}
		else
		{
			NSUserDefaults.standardUserDefaults().setObject(imagePath, forKey: CachedImagePathKey)
			print("the cachedImagedPath is %@",imagePath)
		}
	}
	
	func imageForCaching() -> UIImage
	{
		UIGraphicsBeginImageContext(self.canvas.frame.size);
		self.canvas.image?.drawInRect(self.canvas.bounds);
		self.secondImageView.drawViewHierarchyInRect(self.canvas.bounds, afterScreenUpdates: true)
		self.logoLabel.drawTextInRect(self.logoLabel.frame)
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext();
		return newImage;
	}
	// MARK: - NavBarDelegation 
	func sharingRequested() {
		sharingController = SharingViewController(nibName: "SharingViewController", bundle: nil)
		sharingController.sharingDelegate = self
		controlContainer.addViewWithConstraints(sharingController.view, toTheRight: true)
		controlContainer.animateEnteringView()
		infoTopConstraint.constant = -infobarHolder.frame.height
		controlContainerHeightConstraint.constant += infobarHolder.frame.height
		logoLabel.hidden = false
		logoLabel.alpha = 0.0
		UIView .animateWithDuration(0.5, animations: { () -> Void in
			
			self.view.layoutIfNeeded()
			self.logoLabel.alpha = 1.0
		})
		saveTempImage()
	}
	
	func retakeImageRequested() {
		if (self.infoTopConstraint.constant != 0)
		{
			self.infoTopConstraint.constant = 0
			self.controlContainerHeightConstraint.constant = 204
			UIView.animateWithDuration(0.3, animations: { () -> Void in
				self.view.layoutIfNeeded()
			})
		}
		self.logoLabel.hidden = false
		self.navigationView.takingImageStageAppearance(true)
		self.canvas.image = nil
		self.secondImageView.image = nil
		sessionService.stopCurrentSession()
		self.frontCamSessionView?.removeFromSuperview()
		self.frontCamSessionView = nil
		self.backCamSessionView?.removeFromSuperview()
		self.backCamSessionView = nil
		self.initBlurredOverLay(toView: self.secondImageView)
		startSessionOnBackCam()
		if (masksViewController == nil)
		{
			masksViewController = ChooseMasksViewController(nibName: "ChooseMasksViewController", bundle: nil)
			masksViewController.masksChooseDelegate = self
			controlContainer.addViewWithConstraints(masksViewController.view, toTheRight: false)
			controlContainer.animateExitingView()
		}
		
		
	}
	//MARK: - SharingControllerDelegate
	func taggingKeyboardWillChange(animationTime: Double, endFrame: CGRect) {
		if endFrame.origin.y == self.view.frame.height
		{
			infoTopConstraint.constant = -infobarHolder.frame.height
			controlContainerHeightConstraint.constant = 204 + infobarHolder.frame.height
		}
		else
		{
			infoTopConstraint.constant = -infobarHolder.frame.height - endFrame.height - 144
			controlContainerHeightConstraint.constant = endFrame.height + 100
		}
		
		UIView .animateWithDuration(animationTime, animations: { () -> Void in
			
			self.view.layoutIfNeeded()
		})
	}
	
	func updateUserInfoText(newText: String)
	{
		if newText.isEmpty
		{
			self.userLabel.hidden = true
		}
		else
		{
			self.userLabel.hidden = false
			self.userLabel.text = newText
		}
	}
	
	func imageForSharing() -> NSURL {
		let path = NSUserDefaults.standardUserDefaults().objectForKey(CachedImagePathKey) as String
		return NSURL(fileURLWithPath: path)!
	}
	
	func captureButtonPressed() {
#if (arch(i386) || arch(x86_64)) && os(iOS)
		canvas.image = UIImage(named: "image1.jpeg")
		secondImageView.image = UIImage(named: "image2.jpeg")
		initStageThree()
#else
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
					self.backCamSessionView?.removeFromSuperview()
					self.backCamSessionView = nil
					self.frontCamSessionView?.removeFromSuperview()
					self.frontCamSessionView = nil
					self.initStageThree()
					
				}
				else
				{
					if (self.blurredView != nil)
					{
						self.blurredView!.removeFromSuperview()
						self.blurredView = nil
					}
					self.navigationView.showLeftButton(true)
					self.switchCamButtonPressed()
					self.initStageTwo()
					
				}
			}
		}
#endif
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
	
	func jumperSwitched() {
		self.filtersViewController.workingImageView = self.filtersViewController.workingImageView == canvas ? self.secondImageView : self.canvas
		
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
			let viewToOperateOn = self.backCamSessionView == nil ? self.frontCamSessionView : self.backCamSessionView
			
			let newImage = ImageProcessingUtil.imageFromVideoView(viewToOperateOn, originalImage: image!, shouldMirrorImage: self.frontCamSessionView != nil)
			println("image width is \(image!.size.width) and height \(image!.size.height)")
			println("canvas width is \(newImage.size.width) and canvas height \(newImage.size.height)")
			if (self.canvas.image == nil)
			{
				
				self.canvas.image =	 newImage//Populating first stage
			}
			else
			{
				self.secondImageView.image = newImage
			}
		}
	}
	
}
