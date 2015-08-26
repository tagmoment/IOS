//
//  ViewController.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 1/2/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - Notifications Declarations
let ImageFromCameraChosenNotificationName = "ImageFromCameraChosenNotificationName"
let ImageFromCameraNotificationKey = "Image"

let CameraRollWillAppearNotificationName = "CameraRollWillAppearNotificationName"
let CameraRollDidDisappearNotificationName = "CameraRollDidDisappearNotificationName"
let CameraRollWillDisappearNotificationName = "CameraRollWillDisappearNotificationName"
let CameraRollDidSelectImageNotificationName = "CameraRollDidSelectImageNotificationName"


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
	
	var secondImageView : ClippingViewWithTouch!
	var frontCamSessionView : UIView!
	var backCamSessionView : UIView!
	
	var originalImageCanvas : UIImage?
	var originalImageSecondary : UIImage?
	
	var sessionService : CameraSessionService!
	let viewChoreographer : ViewChoreographer = ViewChoreographer()
	
	var blurredView : UIView?
	var workingImageView : UIImageView?
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
		viewChoreographer.mainViewController = self
	}
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		workingImageView = canvas
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("imageFromCameraChosenNotification:"), name: ImageFromCameraChosenNotificationName, object: nil)
		masksViewController = ChooseMasksViewController(nibName: "ChooseMasksViewController", bundle: nil)
		controlContainer.addViewWithConstraints(masksViewController.view, toTheRight: true)
		
		masksViewController.masksChooseDelegate = self

		secondImageView = ClippingViewWithTouch()
		secondImageView.userInteractionEnabled = true
		var tapRecog = UITapGestureRecognizer()
		tapRecog.addTarget(self, action: "croppedImageDidPress:")
		secondImageView.addGestureRecognizer(tapRecog)
		tapRecog = UITapGestureRecognizer()
		tapRecog.addTarget(self, action: "croppedImageDidPress:")
		canvas.addGestureRecognizer(tapRecog)
		secondImageView.contentMode = UIViewContentMode.ScaleAspectFill
		secondImageView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleHeight;
		secondImageView.frame = canvas.bounds;
		canvas.addSubview(secondImageView);
		navigationView = NSBundle.mainBundle().loadNibNamed("NavbarView", owner: nil, options: nil)[0] as! TakeImageNavBar
		infobarHolder.pinSubViewToAllEdges(navigationView)
		navigationView.viewDelegate = self
		changeMasksCarouselPositionIfNeeded()
		blurredView = VisualEffectsUtil.initBlurredOverLay(UIBlurEffectStyle.Light, toView: secondImageView)
		canvas.layer.masksToBounds = true
		
    }
	
	deinit
	{
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	func croppedImageDidPress(sender: AnyObject)
	{
		let tapRecog = sender as! UITapGestureRecognizer
		
		
		if (filtersViewController != nil)
		{
			let value = (self.secondImageView === tapRecog.view)
			filtersViewController.changeJumperSelectionState(toState: value)
		}
		else if (masksViewController != nil)
		{
			if (frontCamSessionView == nil && backCamSessionView == nil)
			{
				return;
			}
			
			if (!isOnFirstStage() && tapRecog.view == self.canvas)
			{
				return;
			}
			
			let innerViewTouched = (self.secondImageView === tapRecog.view && self.frontCamSessionView != nil) ? self.secondImageView : self.canvas
			
			
			let point = tapRecog.locationInView(innerViewTouched)
			let focus = CircleRectView(frame: CGRect(x: 0,y: 0,width: 50,height: 50))
			focus.center = point
			if innerViewTouched === self.secondImageView
			{
				focus.dashedLineColor = UIColor(red: 210/255, green: 105/255, blue: 30/255, alpha: 1.0)
			}
			innerViewTouched.addSubview(focus)
			focus.animateDisappearance()
			let layerHolder = frontCamSessionView ?? backCamSessionView
			sessionService.focus(innerViewTouched === self.secondImageView, layerHolder: layerHolder!, touchPoint: point)
		}
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		if (!initialized)
		{
			initialized = true
			initStageOne()
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
		workingImageView = secondImageView
		changeSingleCaptureBehaviour()
	}
	
	func initStageThree()
	{
		removeMasksIfNeeded()
		originalImageCanvas = self.canvas.image?.copy() as? UIImage
		originalImageSecondary = self.secondImageView.image?.copy() as? UIImage
		filtersViewController = ChooseFiltersViewController(nibName: "ChooseFiltersViewController", bundle: nil)
		filtersViewController.maskViewModel = masksViewController.getSelectedViewModel()
		filtersViewController.filtersChooseDelegate = self
		
		controlContainer.addViewWithConstraints(filtersViewController.view, toTheRight: true)
		changeFiltersLayoutIfNeeded()
		controlContainer.animateEnteringView()
		viewChoreographer.editingStageAppearance(true)
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
			sessionView.tag = 1000
			secondImageView.pinSubViewToAllEdges(sessionView)
			sessionView.frame = secondImageView.bounds
		}
		
		addVideoLayer(toView: sessionView)
		forwardMasksToFrontIfNeeded()
		return sessionView
	}
	
	
	private func addVideoLayer(toView host: UIView){
		let captureVideoPreviewLayer = sessionService.initializeSessionForCaptureLayer()
		captureVideoPreviewLayer.frame = host.bounds
		host.layer.addSublayer(captureVideoPreviewLayer)
		
	}

	func maskChosen(name: String?) {
		if (name != nil){
			let maskLayerAndBounds = maskLayerAndBoundsForMaskName(name)
			self.changeSingleCaptureBehaviour()
			UIView.animateWithDuration(0.10, animations: { () -> Void in
				self.secondImageView.alpha = 0.0
				}, completion: { (finished: Bool) -> Void in
					if (finished)
					{
						self.secondImageView.frame = maskLayerAndBounds.1!
						self.changeMaskViewFrame(self.secondImageView.bounds)
						self.secondImageView.layer.mask = maskLayerAndBounds.0!
						UIView.animateWithDuration(0.10, animations: { () -> Void in
							self.secondImageView.alpha = 1.0
						})
					}
			})
		}
	}
	
	func changeSingleCaptureBehaviour()
	{
		if (!isOnFirstStage() && self.masksViewController != nil)
		{
			if (self.masksViewController.maskAllowsSecondCapture())
			{
				self.viewChoreographer.takingImageStageAppearance(false)
				self.masksViewController.takeButton.enabled = true
				self.masksViewController.switchCamButton.enabled = true
				
			}
			else
			{
				self.viewChoreographer.editingStageAppearance(false)
				self.masksViewController.takeButton.enabled = false
				self.masksViewController.switchCamButton.enabled = false
			}
		}
	}
	
	func saveTempImage()
	{
		
		let imageData = UIImagePNGRepresentation(imageForCaching())
		
		let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true);
		let documentsDirectory = paths[0] as! String
		let imagePath = documentsDirectory + "/ShareMe.png"
		
		let filemanager = NSFileManager.defaultManager()
		var error : NSError?
		if (filemanager.fileExistsAtPath(imagePath))
		{
			
			filemanager.removeItemAtPath(imagePath, error: &error)
		}
		if !imageData.writeToFile(imagePath, options: NSDataWritingOptions.DataWritingFileProtectionNone, error: &error)
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
		let newBounds = CGRect(x: 0, y: 0, width: self.canvas.frame.size.width*2, height: self.canvas.frame.size.height*2)
		let newBoundsForLabel = CGRect(x: self.userLabel.frame.origin.x, y: self.canvas.frame.size.height*2 - 28.0 - self.userLabel.frame.size.height*2, width: self.userLabel.frame.size.width*2, height: self.userLabel.frame.size.height*2)
		let newBoundsForMaskView = CGRect(x: self.secondImageView.frame.origin.x*2, y: self.secondImageView.frame.origin.y*2 , width: self.secondImageView.frame.size.width*2, height: self.secondImageView.frame.size.height*2)
		UIGraphicsBeginImageContextWithOptions(newBounds.size, true, UIScreen.mainScreen().scale)
		self.canvas.image?.drawInRect(newBounds);
		self.secondImageView.drawViewHierarchyInRect(newBoundsForMaskView, afterScreenUpdates: true)
		
		self.userLabel.drawViewHierarchyInRect(newBoundsForLabel, afterScreenUpdates: true)
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext();
		println("newImage size \(newImage.size)")
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
	
	
	func nextStageRequested() {
		
		for cont in self.childViewControllers
		{
			if cont is CameraRollViewController
			{
				closeCameraRoll(cont as! CameraRollViewController)
//					self.navigationView.showLeftButton(true, animated: true)
				
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

				
				return;
			}
			
		}
		
		
		if (self.masksViewController != nil)
		{
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
		changeSharingLayoutIfNeeded()
		controlContainer.animateEnteringView()
		infoTopConstraint.constant = -infobarHolder.frame.height
		logoLabel.hidden = false
		logoLabel.alpha = 0.0
		UIView .animateWithDuration(0.5, animations: { () -> Void in
			
			self.view.layoutIfNeeded()
			self.logoLabel.alpha = 1.0
		})
	}
	
	private func closeCameraRoll(cameraRollCont : CameraRollViewController)
	{
		
		cameraRollCont.closeView()
	}
	
	func retakeImageRequested() {
		for cont in self.childViewControllers
		{
			if cont is CameraRollViewController
			{
				workingImageView!.image = nil
				closeCameraRoll(cont as! CameraRollViewController)
				
				if (self.backCamSessionView == nil && self.frontCamSessionView == nil)
				{
					startSessionOnBackCam()
				}
				
				return;
			}
			
		}
		
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
		
		self.canvas.image = nil
		self.secondImageView.image = nil
		self.viewChoreographer.takingImageStageAppearance(true)
		sessionService.stopCurrentSession()
		self.frontCamSessionView?.removeFromSuperview()
		self.frontCamSessionView = nil
		self.backCamSessionView?.removeFromSuperview()
		self.backCamSessionView = nil
		blurredView = VisualEffectsUtil.initBlurredOverLay(UIBlurEffectStyle.Light, toView: self.secondImageView)
		startSessionOnBackCam()
		if (masksViewController == nil)
		{
			masksViewController = ChooseMasksViewController(nibName: "ChooseMasksViewController", bundle: nil)
			masksViewController.masksChooseDelegate = self
			controlContainer.addViewWithConstraints(masksViewController.view, toTheRight: false)
			changeMasksCarouselPositionIfNeeded()
			controlContainer.animateExitingView()
			filtersViewController = nil
		}
		self.masksViewController.takeButton.enabled = true
		self.masksViewController.switchCamButton.enabled = true
		workingImageView = canvas
		
		
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
			infoTopConstraint.constant = controlsContainerHeight - endFrame.height - 150
			sharingController.tagsHeightConstraint.constant = 150
			
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
			self.userLabel.attributedText = nil
		}
		else
		{
			self.userLabel.hidden = false
			self.userLabel.text = newText
//			self.userLabel.attributedText =  fixBaselineForUserLabelText(newText, textBaselineOffset: -2, emojiBaselineOffset: -3)
//			self.sharingController.textField.attributedText = fixBaselineForUserLabelText(newText, textBaselineOffset: -2, emojiBaselineOffset: -4)
		}
	}
	
//	private func fixBaselineForUserLabelText(text : String, textBaselineOffset : Int, emojiBaselineOffset : Int) -> NSAttributedString
//	{
//		let words = text.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
//		var attrString = NSMutableAttributedString(string: text)
//		
//		let totalRange = NSRange(location: 0,length: count(text))
//		for word in words
//		{
//			let regex = NSRegularExpression(pattern: word, options: NSRegularExpressionOptions(0), error: nil)
//			regex?.enumerateMatchesInString(text, options: NSMatchingOptions(0), range: totalRange, usingBlock: { (checkingResult : NSTextCheckingResult!, matchingFlags: NSMatchingFlags, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
//				
//				let subRange = checkingResult.rangeAtIndex(0)
//				let baselineValue = contains(self.sharingController.TagsDataSourceeEmojis, word) ? emojiBaselineOffset : textBaselineOffset
//
//				attrString.addAttribute(NSBaselineOffsetAttributeName, value: baselineValue, range: subRange)
//			})
//			
//		}
//		
//		return attrString
//	}
	
	func textEditingDidEnd() {
		saveTempImage()
	}
	
	func imageForSharing() -> NSURL {
		let path = NSUserDefaults.standardUserDefaults().objectForKey(CachedImagePathKey) as! String
		return NSURL(fileURLWithPath: path)!
	}
	
	func captureButtonPressed() {
#if (arch(i386) || arch(x86_64)) && os(iOS)
		canvas.image = UIImage(named: "image1.jpeg")
		secondImageView.image = UIImage(named: "image2.jpeg")
		initStageThree()
#else
	
		makeSnapshotEffect()
		UIApplication.sharedApplication().beginIgnoringInteractionEvents()
		sessionService.captureImage { (image: UIImage?, error: NSError!) -> Void in
			UIApplication.sharedApplication().endIgnoringInteractionEvents()
			if (error != nil)
			{
				/* print error message */
				return
			}
			
			if (image != nil)
			{
				self.processImage(image)
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
		
		if (self.backCamSessionView == nil && self.frontCamSessionView == nil)
		{
			startSessionOnFrontCam()
		}
	}
	
	func isOnFirstStage() -> Bool{
		return (self.canvas.image == nil)
	}
	
	
	func isOnSecondStage() -> Bool{
		return (self.secondImageView.image != nil)
	}
	
	private func processImage(image: UIImage?) {
		if (image != nil)
		{
			let viewToOperateOn = self.backCamSessionView == nil ? self.frontCamSessionView : self.backCamSessionView
			
			let newImage = ImageProcessingUtil.imageFromVideoView(viewToOperateOn, originalImage: image!, shouldMirrorImage: self.frontCamSessionView != nil)
			println("image width is \(image!.size.width) and height \(image!.size.height)")
			println("newImage width is \(newImage.size.width) and canvas height \(newImage.size.height)")
			
			
			self.populateCanvasWithImage(newImage)
		}
	}
	func imageFromCameraChosenNotification(notif : NSNotification)
	{
		let image = notif.userInfo?[ImageFromCameraNotificationKey] as! UIImage
		
		processImageFromPhotoAlbum(image)
	}
	
	private func processImageFromPhotoAlbum(image: UIImage?) {
		if (image != nil)
		{
			println("image width is \(image!.size.width) and height \(image!.size.height)")
			let newImage = ImageProcessingUtil.imageByScalingAndCroppingForSize(image!, viewSize: workingImageView!.frame.size)
			println("newImage width is \(newImage.size.width) and canvas height \(newImage.size.height)")

			self.populateCanvasWithImage(newImage)
			sessionService.stopCurrentSession()
			
			if (self.frontCamSessionView != nil)
			{
				self.frontCamSessionView.removeFromSuperview()
				self.frontCamSessionView = nil
			}
			else if (self.backCamSessionView != nil)
			{
				self.backCamSessionView.removeFromSuperview()
				self.backCamSessionView = nil
			}

		}
	}
	
	private func populateCanvasWithImage(image : UIImage)
	{
		
		workingImageView!.image = image
	}
	
}
