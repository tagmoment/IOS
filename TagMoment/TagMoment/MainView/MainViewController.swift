//
//  ViewController.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 1/2/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit
import AVFoundation
import JPSVolumeButtonHandler

// MARK: - Notifications Declarations
let ImageFromCameraChosenNotificationName = "ImageFromCameraChosenNotificationName"
let ImageFromCameraNotificationKey = "Image"

let CameraRollWillAppearNotificationName = "CameraRollWillAppearNotificationName"
let CameraRollDidDisappearNotificationName = "CameraRollDidDisappearNotificationName"
let CameraRollWillDisappearNotificationName = "CameraRollWillDisappearNotificationName"
let CameraRollDidSelectImageNotificationName = "CameraRollDidSelectImageNotificationName"

let MenuWillDisappearNotificationName = "MenuWillDisappearNotificationName"
let MenuDidDisappearNotificationName = "MenuDidDisappearNotificationName"
let MenuDidAppearNotificationName = "MenuDidAppearNotificationName"
let MenuWillAppearNotificationName = "MenuWillAppearNotificationName"

class MainViewController: UIViewController, ChooseMasksControllerDelegate, ChooseFiltesControllerDelegate, NavBarDelegate, SharingControllerDelegate, InAppPurchaseDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate{
	
	var inAppPurchaseDataProvider = InAppPurchaseDataProvider()
	
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
	let viewChoreographer = ViewChoreographer()
	
	var blurredView : UIView?
	var workingImageView : UIImageView?
	var initialized = false
	var controlsContainerHeight : CGFloat = CGFloat(0)
	
	var canvasZoomControl : TWImageScrollView?
	var secondZoomControl : TWImageScrollView?
	var workingZoomControl : TWImageScrollView?
	
	var timerHandler : TimerHandler?
	var volumeButtonsHandler : JPSVolumeButtonHandler?
	var capturingImage : Bool = false
	let imageService = PhotosLibraryService()

	
	
	@IBOutlet weak var logoLabel: UILabel!
	@IBOutlet weak var userLabel: UILabel!
	@IBOutlet weak var infoTopConstraint: NSLayoutConstraint!
	@IBOutlet weak var canvas: UIImageView!
	@IBOutlet weak var controlContainer: SlidingView!
	@IBOutlet weak var infobarHolder: UIView!
	
	
	
	
	required override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		commonInit()
	}

	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	fileprivate func commonInit() {
		sessionService = CameraSessionService()
		viewChoreographer.mainViewController = self
		inAppPurchaseDataProvider.delegate = self
		inAppPurchaseDataProvider.fetchProducts()
		self.startObservingVolumeChange()
	}
	
	
    override func viewDidLoad() {
        super.viewDidLoad()
		workingImageView = canvas
		NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.imageFromCameraChosenNotification(_:)), name: NSNotification.Name(rawValue: ImageFromCameraChosenNotificationName), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(UIApplicationDelegate.applicationWillTerminate(_:)), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
		
		masksViewController = ChooseMasksViewController(nibName: "ChooseMasksViewController", bundle: nil)
		controlContainer.addViewWithConstraints(masksViewController.view, toTheRight: true)
		
		masksViewController.masksChooseDelegate = self

		secondImageView = ClippingViewWithTouch()
		secondImageView.isUserInteractionEnabled = true
		var tapRecog = UILongPressGestureRecognizer()
		tapRecog.minimumPressDuration = 0
		tapRecog.allowableMovement = 20
		tapRecog.addTarget(self, action: #selector(MainViewController.croppedImageDidPress(_:)))
		tapRecog.delegate = self
		secondImageView.addGestureRecognizer(tapRecog)
		tapRecog = UILongPressGestureRecognizer()
		tapRecog.minimumPressDuration = 0
		tapRecog.allowableMovement = 20
		tapRecog.addTarget(self, action: #selector(MainViewController.croppedImageDidPress(_:)))
		tapRecog.delegate = self
		canvas.addGestureRecognizer(tapRecog)
		secondImageView.contentMode = UIViewContentMode.scaleAspectFill
		secondImageView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight];
		secondImageView.frame = canvas.bounds;
		canvas.addSubview(secondImageView);
		navigationView = Bundle.main.loadNibNamed("NavbarView", owner: nil, options: nil)?[0] as! TakeImageNavBar
		infobarHolder.pinSubViewToAllEdges(navigationView)
		navigationView.viewDelegate = self
		changeMasksCarouselPositionIfNeeded()
		blurredView = VisualEffectsUtil.initBlurredOverLay(TagMomentBlurEffect.light, toView: secondImageView)
		canvas.layer.masksToBounds = true
		
    }
	
	deinit
	{
		NotificationCenter.default.removeObserver(self)
	}
	//MARK - Gesture Handling
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		
		
		if self.masksViewController != nil && self.canvas != nil && MainViewController.isSmallestScreen()
		{
			let touchPoint = touch.location(in: self.canvas)
			let frame = self.masksViewController.masksCarousel.frame
			if (frame.contains(touchPoint))
			{
				return false;
			}
		}
		

		return self.canvasZoomControl == nil && self.secondZoomControl == nil
	}

	
	func croppedImageDidPress(_ sender: AnyObject)
	{
		let tapRecog = sender as! UILongPressGestureRecognizer
		
		if (tapRecog.state == UIGestureRecognizerState.began)
		{
			if (filtersViewController != nil)
			{
				let value = (self.secondImageView === tapRecog.view)
				
				if value == filtersViewController.jumperButton.isSelected
				{
					filtersViewController.changeSliderValueTo(0)
				}
				
			}
			return
		}
		
		if (tapRecog.state != UIGestureRecognizerState.ended && tapRecog.state != UIGestureRecognizerState.cancelled)
		{
			return
		}
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
			
			
			let point = tapRecog.location(in: innerViewTouched)
			let focus = CircleRectView(frame: CGRect(x: 0,y: 0,width: 50,height: 50))
			focus.center = point
			if innerViewTouched === self.secondImageView
			{
				focus.dashedLineColor = UIColor(red: 210/255, green: 105/255, blue: 30/255, alpha: 1.0)
			}
			innerViewTouched?.addSubview(focus)
			focus.animateDisappearance()
			let layerHolder = frontCamSessionView ?? backCamSessionView
			sessionService.focus(innerViewTouched === self.secondImageView, layerHolder: layerHolder!, touchPoint: point)
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		GoogleAnalyticsReporter.ReportPageView("Main View");
		if (!initialized)
		{
			initialized = true
			initStageOne()
		}
		
	}
	
	func initStageOne()
	{
#if (arch(i386) || arch(x86_64)) && os(iOS)

		print("In smulator stage 1", terminator: "")
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
		filtersViewController = ChooseFiltersViewController(nibName: "ChooseFiltersViewController", bundle: nil, restoreState: false)
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
		#if (arch(i386) || arch(x86_64)) && os(iOS)
			print("Moved here");
		#else
			backCamSessionView = createSessionView()
			backCamSessionView.hidden = false;
			sessionService.startSessionOnBackCamera()
		#endif
		
	}
	
	func startSessionOnFrontCam()
	{
		#if (arch(i386) || arch(x86_64)) && os(iOS)
		print("Moved here");
		#else
		frontCamSessionView = createSessionView()
		sessionService.startSessionOnFrontCamera()
		#endif
	}
	
	fileprivate func createSessionView() -> UIView {
		let sessionView = UIView()
		if (self.isOnFirstStage())
		{
			canvas.pinSubViewToAllEdges(sessionView)
			canvas.bringSubview(toFront: secondImageView)
			
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
	
	
	fileprivate func addVideoLayer(toView host: UIView){
		let captureVideoPreviewLayer = sessionService.initializeSessionForCaptureLayer()
		captureVideoPreviewLayer.frame = host.bounds
		host.layer.addSublayer(captureVideoPreviewLayer)
		
	}

	func maskChosen(_ name: String?) {
		if (name != nil){
			let maskLayerAndBounds = maskLayerAndBoundsForMaskName(name)
			self.changeSingleCaptureBehaviour()
			UIView.animate(withDuration: 0.10, animations: { () -> Void in
				self.secondImageView.alpha = 0.0
				}, completion: { (finished: Bool) -> Void in
					if (finished)
					{
						self.secondImageView.frame = maskLayerAndBounds.1!
						self.changeMaskViewFrame(self.secondImageView.bounds)
						self.secondImageView.layer.mask = maskLayerAndBounds.0!
						UIView.animate(withDuration: 0.10, animations: { () -> Void in
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
				self.masksViewController.takeButton.isEnabled = true
				self.masksViewController.switchCamButton.isEnabled = true
				
			}
			else
			{
				self.viewChoreographer.editingStageAppearance(false)
				self.masksViewController.takeButton.isEnabled = false
				self.masksViewController.switchCamButton.isEnabled = false
			}
		}
	}
	
	func saveTempImage()
	{
		FileHandlingService.SaveImageToSources(imageForCaching());
	}
	
	func imageForCaching() -> UIImage
	{
		let newBounds = CGRect(x: 0, y: 0, width: self.canvas.frame.size.width*2, height: self.canvas.frame.size.height*2)
		let newBoundsForLabel = CGRect(x: self.userLabel.frame.origin.x, y: self.canvas.frame.size.height*2 - 28.0 - self.userLabel.frame.size.height*2, width: self.userLabel.frame.size.width*2, height: self.userLabel.frame.size.height*2)
		let newBoundsForMaskView = CGRect(x: self.secondImageView.frame.origin.x*2, y: self.secondImageView.frame.origin.y*2 , width: self.secondImageView.frame.size.width*2, height: self.secondImageView.frame.size.height*2)
		UIGraphicsBeginImageContextWithOptions(newBounds.size, true, UIScreen.main.scale)
		self.canvas.image?.draw(in: newBounds);
		self.secondImageView.drawHierarchy(in: newBoundsForMaskView, afterScreenUpdates: true)
		self.userLabel.drawHierarchy(in: newBoundsForLabel, afterScreenUpdates: true)
		let newImage = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext();
		print("newImage size \(newImage?.size)")
		return newImage!;
	}
	
	
	// MARK: - Filters delegation
	func workingImage(_ outerImage : Bool) -> UIImage {
		return outerImage ? originalImageCanvas! : originalImageSecondary!
	}
	
	func workingImageView(_ outerImage : Bool) -> UIImageView {
		return outerImage ? self.canvas : self.secondImageView
	}
	
	// MARK: - NavBarDelegation 
	
	
	func nextStageRequested() {
		
		for cont in self.childViewControllers
		{
			if cont is CameraRollViewController
			{
				if (!isOnFirstStage() && self.masksViewController.getSelectedViewModel().locked == true)
				{
					inAppPurchaseDataProvider.showMessageForMask(self.masksViewController.getSelectedViewModel(), presentingViewController: self)
					return;
				}
				
				takeImageFromCameraRoll(true)
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
			self.filtersViewController.persistState()
			sharingRequested()
		}
	}
	
	func sharingRequested() {
		let xibName = "SmallScreenSharingViewController"
		sharingController = SharingViewController(nibName: xibName, bundle: nil)
		sharingController.sharingDelegate = self
		controlsContainerHeight = controlContainer.frame.height;
		controlContainer.addViewWithConstraints(sharingController.view, toTheRight: true)
		if !MainViewController.isSmallestScreen()
		{
			sharingController.tagsHeightConstraint.constant = controlsContainerHeight - 68 - 44;
		}
		else
		{
			sharingController.tagsCollectionView.superview!.removeConstraint(sharingController.tagsCenterConstraint)
			let constraint = NSLayoutConstraint(item: sharingController.tagsCollectionView, attribute: .top, relatedBy: .equal, toItem: sharingController.tagsCollectionView.superview, attribute: .top, multiplier: 1, constant: 0)
			sharingController.tagsCollectionView.superview?.addConstraint(constraint)
		}
		
		changeSharingLayoutIfNeeded()
		controlContainer.animateEnteringView()
		logoLabel.isHidden = false
		viewChoreographer.sharingStageAppearance(true)

	}
	
	fileprivate func closeCameraRoll(_ cameraRollCont : CameraRollViewController)
	{
		
		cameraRollCont.closeView()
	}
	
	func backButtonRequested()
	{
		if (sharingController != nil)
		{
			sharingController.clearState()
		}
		self.logoLabel.isHidden = true
		self.userLabel.isHidden = true
		self.userLabel.text = ""
		filtersViewController = ChooseFiltersViewController(nibName: "ChooseFiltersViewController", bundle: nil, restoreState: true)
		filtersViewController.filtersChooseDelegate = self
		
		controlContainer.addViewWithConstraints(filtersViewController.view, toTheRight: false)
		changeFiltersLayoutIfNeeded()
		controlContainer.animateExitingView()
		viewChoreographer.editingStageAppearance(true)
	}
	
	
	func retakeImageRequested() {
		for cont in self.childViewControllers
		{
			if cont is CameraRollViewController
			{
				workingImageView!.image = nil
				self.cancelZoomOperation()
				closeCameraRoll(cont as! CameraRollViewController)
				
				if (self.backCamSessionView == nil && self.frontCamSessionView == nil)
				{
					startSessionOnBackCam()
				}
				
				return;
			}
			
		}
		
		if (sharingController != nil)
		{
			sharingController.clearState()
		}
		
		FilterStateRepository.clearFiltersState()
		
		if (self.infoTopConstraint.constant != 0)
		{
			self.infoTopConstraint.constant = 0
			UIView.animate(withDuration: 0.3, animations: { () -> Void in
				self.view.layoutIfNeeded()
			})
		}
		self.logoLabel.isHidden = true
		self.userLabel.isHidden = true
		self.userLabel.text = ""
		
		self.canvas.image = nil
		self.secondImageView.image = nil
		self.viewChoreographer.takingImageStageAppearance(true)
		sessionService.stopCurrentSession()
		self.frontCamSessionView?.removeFromSuperview()
		self.frontCamSessionView = nil
		self.backCamSessionView?.removeFromSuperview()
		self.backCamSessionView = nil
		blurredView = VisualEffectsUtil.initBlurredOverLay(TagMomentBlurEffect.light, toView: self.secondImageView)
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
		self.masksViewController.takeButton.isEnabled = true
		self.masksViewController.switchCamButton.isEnabled = true
		workingImageView = canvas
		
		
	}
	
	func doneButtonPressed() {
		
		if self.sharingController != nil
		{
			self.sharingController.uploadImage()
			self.sharingController.imageShared = false;
		}
		
		if (SettingsHelper.shouldPrompt())
		{
			
			let alertViewMessage = "Do you want to save the new moment to your phone album?"
			
			let view = UIAlertView(title: "", message: alertViewMessage, delegate: self, cancelButtonTitle: "Cancel", otherButtonTitles: "Save", "No")
			
			view.show()
			return;
		}
		
		if (SettingsHelper.shouldSaveToCameraRoll())
		{
			let imageToSave = imageForCaching()
			self.imageService.saveImageToAlbum(imageToSave)
		}
		
		self.retakeImageRequested()
	}
	
	
	//MARK: - AlertViewDelegation
	func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int)
	{
		switch buttonIndex
		{
			case 1:
				SettingsHelper.saveToCameraRollSaveState()
				let imageToSave = imageForCaching()
				self.imageService.saveImageToAlbum(imageToSave)
				
			self.retakeImageRequested()
			case 2:
				SettingsHelper.neverSaveToCameraRollSameState()
				self.retakeImageRequested()
			default:
				print("Cancelling")
		}
		
		
	}
	
	//MARK: - SharingControllerDelegate
	func taggingKeyboardWillChange(_ animationTime: Double, endFrame: CGRect) {
		if endFrame.origin.y == self.view.frame.height
		{
			infoTopConstraint.constant = 0
			if (MainViewController.isSmallestScreen())
			{
				sharingController.tagsHeightConstraint.constant = 2
			}
			else
			{
				sharingController.tagsCenterConstraint.constant = 0
			}
		}
		else
		{
			if (MainViewController.isSmallestScreen())
			{
				infoTopConstraint.constant = controlsContainerHeight - endFrame.height - 150
				sharingController.tagsHeightConstraint.constant = 150
			}
			else
			{
				infoTopConstraint.constant = controlsContainerHeight - 144 - endFrame.height
				sharingController.tagsCenterConstraint.constant = -100
			}
			
		}
		
		UIView .animate(withDuration: animationTime, animations: { () -> Void in
			
			self.view.layoutIfNeeded()
		})
	}
	
	func updateUserInfoText(_ newText: String)
	{
		if newText.isEmpty
		{
			self.userLabel.isHidden = true
			self.userLabel.attributedText = nil
		}
		else
		{
			self.userLabel.isHidden = false
			self.userLabel.text = newText

		}
	}
	
	func textEditingDidEnd() {
		saveTempImage()
	}
	
	func imageForSharing() -> URL {
		let path = UserDefaults.standard.object(forKey: CachedImagePathKey) as! String
		return URL(fileURLWithPath: path)
	}
	
	func captureButtonPressed() {
		if (self.capturingImage)
		{
			return;
		}
		
		
#if (arch(i386) || arch(x86_64)) && os(iOS)
		canvas.image = UIImage(named: "image1.jpeg")
		secondImageView.image = UIImage(named: "image2.jpeg")
		initStageThree()
#else
	
		if (!isOnFirstStage() && self.masksViewController.getSelectedViewModel().locked == true)
		{
			inAppPurchaseDataProvider.showMessageForMask(self.masksViewController.getSelectedViewModel(), presentingViewController: self) 
			return;
		}
	
	
		if timerHandler == nil && navigationView.timerState() != TimerState.Off
		{
			timerHandler = TimerHandler()
		timerHandler?.applyCountDownEffectWithCount(self.navigationView.timerState().rawValue, onView: self.canvas)
			return
			
		}
		else if (timerHandler != nil)
		{
			let wasCounting = timerHandler?.counting
			timerHandler?.cancelTimer()
			timerHandler = nil
			
			if (wasCounting == true)
			{
				return
			}
			
		}
	
		self.capturingImage = true
		self.reportCameraCapture(self.isOnFirstStage())

		makeSnapshotEffect()
		UIApplication.sharedApplication().beginIgnoringInteractionEvents()
		sessionService.captureImage { (image: UIImage?, error: NSError!) -> Void in
			UIApplication.sharedApplication().endIgnoringInteractionEvents()
			if (error != nil)
			{
				print("\(error)")
				self.capturingImage = false;
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
			self.capturingImage = false;
		}
#endif
	}
	
	fileprivate func makeSnapshotEffect()
	{
		let effectView = UIView(frame: self.canvas.bounds)
		effectView.backgroundColor = UIColor.white
		effectView.alpha = 1.0
		let superview = isOnFirstStage() ? self.canvas : self.secondImageView
		superview?.addSubview(effectView)
		UIView.animate(withDuration: 0.1, animations: { () -> Void in
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
	
	fileprivate func processImage(_ image: UIImage?) {
		if (image != nil)
		{
			let viewToOperateOn = self.backCamSessionView == nil ? self.frontCamSessionView : self.backCamSessionView
			
			let newImage = ImageProcessingUtil.imageFromVideoView(viewToOperateOn!, originalImage: image!, shouldMirrorImage: self.frontCamSessionView != nil)
			print("image width is \(image!.size.width) and height \(image!.size.height)")
			print("newImage width is \(newImage.size.width) and canvas height \(newImage.size.height)")
			
			
			self.populateCanvasWithImage(newImage)
		}
	}
	func imageFromCameraChosenNotification(_ notif : Notification)
	{
		let image = notif.userInfo?[ImageFromCameraNotificationKey] as! UIImage
		prepareZoomControlWithImage(image)
//		processImageFromPhotoAlbum(image)
	}
	
	func applicationWillTerminate(_ notif : Notification)
	{
		FilterStateRepository.clearFiltersState()
	}
	
	func processImageFromPhotoAlbum(_ image: UIImage?) {
		if (image != nil)
		{
			print("image width is \(image!.size.width) and height \(image!.size.height)")
			let newImage = ImageProcessingUtil.imageByScalingAndCroppingForSize(image!, viewSize: workingImageView!.frame.size)
			print("newImage width is \(newImage.size.width) and canvas height \(newImage.size.height)")

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
	
	fileprivate func populateCanvasWithImage(_ image : UIImage)
	{
		
		workingImageView!.image = image
	}
	
	
	func masksLockedViewModels() -> [TMMaskViewModel]!
	{
		if (self.masksViewController != nil)
		{
			return self.masksViewController.masksViewModels?.filter({ (mask : TMMaskViewModel!) -> Bool  in
				return mask.locked == true
			})
		}
		
		return nil;
	}
	
	func maskPurchaseComplete(_ maskViewModel: TMMaskViewModel) {
		
		InAppPurchaseRepo.addProductId(maskViewModel.maskProductId)
		guard let cell = self.masksViewController.getLockedViewForUnlocking(maskViewModel) else {
			return;
		}
		
		cell.lockIcon.isHidden = true;
		let newImageView = UIImageView(image: cell.lockIcon.image)
		newImageView.frame = self.view.convert(cell.lockIcon.frame, from: cell)
		self.view.addSubview(newImageView)
		UIView.animate(withDuration: 0.5, animations: { () -> Void in
			newImageView.transform = CGAffineTransform(scaleX: 3, y: 3)
			newImageView.alpha = 0.0
			}, completion: { (finished: Bool) -> Void in
				newImageView.removeFromSuperview()
		}) 
		
		
		
	}
	
	func maskPurchaseFailed(_ maskViewModel: TMMaskViewModel) {
		
	}
	
}
