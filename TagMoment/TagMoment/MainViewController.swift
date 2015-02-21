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

class MainViewController: UIViewController, ChooseMasksControllerDelegate, ChooseFiltesControllerDelegate, NavBarDelegate{
	var masksViewController : ChooseMasksViewController!
	var filtersViewController : ChooseFiltersViewController!
	var navigationView : TakeImageNavBar!
	
	var secondImageView : UIImageView!
	var frontCamSessionView : UIView!
	var backCamSessionView : UIView!
	
	
	var sessionService : CameraSessionService!
	
	var blurredView : UIView?
	
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
		println(controlContainer.frame.width)
		controlContainer.addViewWithConstraints(masksViewController.view)
		masksViewController.masksChooseDelegate = self
//		canvas.image = UIImage(named: "image1.jpeg")
		
		secondImageView = UIImageView()
		secondImageView.contentMode = UIViewContentMode.ScaleAspectFill
		canvas.pinSubViewToAllEdges(secondImageView)
		initBlurredOverLay(toView: secondImageView)
		canvas.layer.masksToBounds = true
		
		
    }
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		initStageOne()
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
		navigationView = NSBundle.mainBundle().loadNibNamed("NavbarView", owner: nil, options: nil)[0] as TakeImageNavBar
		infobarHolder.pinSubViewToAllEdges(navigationView)
		navigationView.viewDelegate = self
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
		filtersViewController.filtersChooseDelegate = self
		controlContainer.addViewWithConstraints(filtersViewController.view)
		controlContainer.animateEnteringView()
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
	
	// MARK: - NavBarDelegation 
	func retakeImageRequested() {
		self.canvas.image = nil
		self.secondImageView.image = nil
		sessionService.stopCurrentSession()
		self.frontCamSessionView?.removeFromSuperview()
		self.frontCamSessionView = nil
		self.backCamSessionView?.removeFromSuperview()
		self.backCamSessionView = nil
		self.initBlurredOverLay(toView: self.secondImageView)
		startSessionOnBackCam()
		self.navigationView.hideLeftButton(true)
	}
	
	
	func captureButtonPressed() {
		
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
					if (self.backCamSessionView != nil)
					{
						self.backCamSessionView.removeFromSuperview()
						self.backCamSessionView = nil
					}
					else
					{
						self.frontCamSessionView.removeFromSuperview()
						self.frontCamSessionView = nil
					}
					
					
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
			let layer: AVCaptureVideoPreviewLayer = viewToOperateOn.layer.sublayers[0] as AVCaptureVideoPreviewLayer
			
			let outputRect = layer.metadataOutputRectOfInterestForRect(self.canvas.bounds)
			var originalSize = image!.size
			
			if (UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation))
			{
   				let temp = originalSize.width;
				originalSize.width = originalSize.height;
				originalSize.height = temp;
			}
			
			
			// metaRect is fractional, that's why we multiply here
			
			var cropRect = CGRect(x: outputRect.origin.x * originalSize.width, y: outputRect.origin.y * originalSize.height, width:outputRect.size.width * originalSize.width, height: outputRect.size.height * originalSize.height)
			
			cropRect = CGRectIntegral(cropRect);
			
			let cropCGImage = CGImageCreateWithImageInRect(image?.CGImage, cropRect);
			let newImage = UIImage(CGImage: resizeCGImage(cropCGImage, toWidth: viewToOperateOn.frame.width, toHeight: viewToOperateOn.frame.height), scale: 1.0, orientation: image!.imageOrientation)
			println("image width is \(image!.size.width) and height \(image!.size.height)")
			println("canvas width is \(newImage!.size.width) and canvas height \(newImage!.size.height)")
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
	
	private func resizeCGImage(cgimage : CGImage, toWidth : CGFloat, toHeight: CGFloat) -> CGImage
	{
		let colorSpace = CGImageGetColorSpace(cgimage)
		let context = CGBitmapContextCreate(nil, UInt(toWidth), UInt(toHeight), CGImageGetBitsPerComponent(cgimage), CGImageGetBytesPerRow(cgimage), colorSpace, CGImageGetBitmapInfo(cgimage))
		CGContextDrawImage(context, CGRect(x: 0, y: 0, width: toWidth, height: toHeight), cgimage)
		return CGBitmapContextCreateImage(context)
	}
}
