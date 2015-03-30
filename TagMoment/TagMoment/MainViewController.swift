//
//  ViewController.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 1/2/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit
import AVFoundation

enum FlashState: Int{
	case Off
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
	
	var originalImageCanvas : UIImage?
	var originalImageSecondary : UIImage?
	
	var sessionService : CameraSessionService!
	
	var blurredView : UIView?
	
	var initialized = false
	var controlsContainerHeight : CGFloat = CGFloat(0)
	
	@IBOutlet weak var logoLabel: UILabel!
	@IBOutlet weak var userLabel: UILabel!
	@IBOutlet weak var infoTopConstraint: NSLayoutConstraint!
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
		navigationView = NSBundle.mainBundle().loadNibNamed("NavbarView", owner: nil, options: nil)[0] as TakeImageNavBar
		infobarHolder.pinSubViewToAllEdges(navigationView)
		applyShadowOnLabels()
		navigationView.viewDelegate = self
		changeMasksCarouselPositionIfNeeded()
		initBlurredOverLay(toView: secondImageView)
		canvas.layer.masksToBounds = true
		
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		if (!initialized)
		{
			initialized = true
			initStageOne()
		}
	}
	
	func applyShadowOnLabels()
	{
		userLabel.layer.shadowRadius = 4.0
		userLabel.layer.shadowOpacity = 0.5
		userLabel.layer.shadowOffset = CGSize(width: 0.0, height: -1.0)
		logoLabel.layer.shadowRadius = 4.0
		logoLabel.layer.shadowOpacity = 0.5
		logoLabel.layer.shadowOffset = CGSize(width: 0.0, height: -1.0)
	}
	
	func changeMasksCarouselPositionIfNeeded()
	{
		if (UIScreen.mainScreen().bounds.height <= 480)
		{
			masksViewController.masksCarousel.removeFromSuperview()
			
			self.canvas.pinSubViewToTop(masksViewController.masksCarousel, heightContraint: 88)
			masksViewController.settingsButtonTopConstraint.constant = 38
			masksViewController.switchCamButtonTopConstraint.constant = 38
			masksViewController.centerTakeImageButton()
			self.navigationView.changeMasksButton.selected = true
			turnOffMasks(true)
		}
	}
	
	func turnOffMasks(delay: Bool)
	{
		UIView.animateWithDuration(0.7, delay: delay ? 1.0 : 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
			
				self.masksViewController.masksCarousel.alpha = 0.0
			}, completion: { (finished : Bool) -> Void in
				self.navigationView.changeMasksButton.selected = false
		})
	}
	
	func turnOnMasks()
	{
		UIView.animateWithDuration(0.7, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
			
			self.masksViewController.masksCarousel.alpha = 1.0
			}, nil)
	}
	
	
	
	func initBlurredOverLay(toView holder: UIView)
	{
		if let theClass: AnyClass = NSClassFromString("UIVisualEffectView") {
			if !UIAccessibilityIsReduceTransparencyEnabled() {
				let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
				blurredView = UIVisualEffectView(effect: blurEffect)
				blurredView?.alpha = 0.5
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
#if (arch(i386) || arch(x86_64)) && os(iOS)

		print("In smulator stage 1")
#else
		startSessionOnBackCam()
#endif
}
	
	func initStageTwo()
	{
		changeSingleCaptureBehaviour()
	}
	
	func initStageThree()
	{
		originalImageCanvas = self.canvas.image?.copy() as? UIImage
		originalImageSecondary = self.secondImageView.image?.copy() as? UIImage
		filtersViewController = ChooseFiltersViewController(nibName: "ChooseFiltersViewController", bundle: nil)
		filtersViewController.maskViewModel = masksViewController.getSelectedViewModel()
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
			
			
			changeSingleCaptureBehaviour()
			UIView.animateWithDuration(0.10, animations: { () -> Void in
				self.secondImageView.alpha = 0.0
				}, completion: { (finished: Bool) -> Void in
				self.secondImageView.layer.mask = maskLayer
				UIView.animateWithDuration(0.10, animations: { () -> Void in
					self.secondImageView.alpha = 1.0
				})
			})
		}
	}
	
	func changeSingleCaptureBehaviour()
	{
		if (!isOnFirstStage())
		{
			if (self.masksViewController.maskAllowsSecondCapture())
			{
				self.navigationView.takingImageStageAppearance(false)
				self.masksViewController.takeButton.enabled = true
				self.masksViewController.switchCamButton.enabled = true
			}
			else
			{
				self.navigationView.editingStageAppearance(false)
				self.masksViewController.takeButton.enabled = false
				self.masksViewController.switchCamButton.enabled = false
			}
		}
	}
	
	func saveTempImage()
	{
		
		let imageData = UIImagePNGRepresentation(imageForCaching())
		
		let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true);
		let documentsDirectory = paths[0] as String
		let imagePath = documentsDirectory + "/ShareMe.png"
		
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
		self.userLabel.drawTextInRect(self.userLabel.frame)
		self.logoLabel.drawTextInRect(self.logoLabel.frame)
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext();
		return newImage;
	}
	
	// MARK: - Filters delegation
	func workingImage(outerImage : Bool) -> UIImage {
		return outerImage ? originalImageCanvas! : originalImageSecondary!
	}
	
	func workingImageView(outerImage : Bool) -> UIImageView {
		return outerImage ? self.canvas : self.secondImageView
	}
	
	// MARK: - NavBarDelegation 
	func maskButtonPressed() {
		if (navigationView.changeMasksButton.selected)
		{
			self.turnOnMasks()
		}
		else
		{
			self.turnOffMasks(false)
		}
	}
	
	func nextStageRequested() {
		
		
		
		
		if (self.masksViewController != nil)
		{
			if (UIScreen.mainScreen().bounds.height <= 480)
			{
				self.turnOffMasks(false)
				navigationView.hideMasksButton(true)
				
			}
			
			initStageThree()
		}
		else
		{
			sharingRequested()
		}
	}
	
	func sharingRequested() {
		
		sharingController = SharingViewController(nibName: "SharingViewController", bundle: nil)
		sharingController.sharingDelegate = self
		controlsContainerHeight = controlContainer.frame.height;
		controlContainer.addViewWithConstraints(sharingController.view, toTheRight: true)
		controlContainer.animateEnteringView()
		infoTopConstraint.constant = -infobarHolder.frame.height
		logoLabel.hidden = false
		logoLabel.alpha = 0.0
		UIView .animateWithDuration(0.5, animations: { () -> Void in
			
			self.view.layoutIfNeeded()
			self.logoLabel.alpha = 1.0
		})
	}
	
	func retakeImageRequested() {
		if (self.infoTopConstraint.constant != 0)
		{
			self.infoTopConstraint.constant = 0
			UIView.animateWithDuration(0.3, animations: { () -> Void in
				self.view.layoutIfNeeded()
			})
		}
		self.logoLabel.hidden = true
		self.userLabel.hidden = true
		self.userLabel.text = ""
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
			sharingController.tagsHeightConstraint.constant = 0
		}
		else
		{
			infoTopConstraint.constant = controlsContainerHeight - endFrame.height - 104
			sharingController.tagsHeightConstraint.constant = 104
			
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
	
	func textEditingDidEnd() {
		saveTempImage()
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
		makeSnapshotEffect()
	
		sessionService.captureImage { (image: UIImage?, error: NSError!) -> Void in
			if (error != nil)
			{
				/* print error message */
				return
			}
			
			if (image != nil)
			{
				self.processImage(image)
				self.navigationView.showLeftButton(true)
				
				if (self.blurredView != nil)
				{
					self.blurredView!.removeFromSuperview()
					self.blurredView = nil
				}
				
				if (!self.isOnSecondStage() && self.masksViewController.maskAllowsSecondCapture())
				{
					
					
					self.switchCamButtonPressed()
					self.initStageTwo()
				}
				else
				{
					self.sessionService.stopCurrentSession()
					self.backCamSessionView?.removeFromSuperview()
					self.backCamSessionView = nil
					self.frontCamSessionView?.removeFromSuperview()
					self.frontCamSessionView = nil
					self.initStageThree()
					
					
				}
			}
		}
#endif
	}
	
	private func makeSnapshotEffect()
	{
		let effectView = UIView(frame: self.canvas.bounds)
		effectView.backgroundColor = UIColor.blackColor()
		effectView.alpha = 1.0
		let superview = isOnFirstStage() ? self.canvas : self.secondImageView
		superview.addSubview(effectView)
		UIView.animateWithDuration(0.1, animations: { () -> Void in
			effectView.alpha = 0.0
			}, completion: { (finished : Bool) -> Void in
				effectView.removeFromSuperview()
		})
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
