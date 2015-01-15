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
	var secondImageView : UIImageView!
	var frontCamSessionView : UIView!
	var backCamSessionView : UIView!
	
	var sessionService : CameraSessionService!
	
	@IBOutlet weak var canvas: UIImageView!
	@IBOutlet weak var controlContainer: UIView!
	
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
		controlContainer.pinSubViewToAllEdges(masksViewController.view)
		masksViewController.masksChooseDelegate = self
		canvas.image = UIImage(named: "image1.jpeg")
		
		canvas.layer.masksToBounds = true
		
		secondImageView = UIImageView(image: UIImage(named: "image2.jpeg"))
		canvas.pinSubViewToAllEdges(secondImageView)
		initStageOne()
		
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.masksViewController.masksCollectionView.selectItemAtIndexPath(NSIndexPath(forItem: 3, inSection: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.CenteredHorizontally)
		self.masksViewController.collectionView(self.masksViewController.masksCollectionView, didSelectItemAtIndexPath: NSIndexPath(forItem: 3, inSection: 0))
	}
	
	func initStageOne()
	{
		startSessionOnBackCam()
	}
	
	
	func startSessionOnBackCam()
	{
		backCamSessionView = createSessionView()
		sessionService.startSessionOnBackCamera()
	}
	
	func startSessionOnFrontCam()
	{
		frontCamSessionView = createSessionView()
		sessionService.startSessionOnFrontCamera()
	}
	
	private func createSessionView() -> UIView {
		var sessionView = UIView()
		canvas.pinSubViewToAllEdges(sessionView)
		canvas.bringSubviewToFront(secondImageView)
		sessionView.frame = canvas.frame
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
			var mask = MaskFactory.maskForName(name!, rect: canvas.bounds)
			var maskLayer = CAShapeLayer()
			maskLayer.path = mask!.clippingPath.CGPath
			secondImageView.layer.mask = maskLayer
		}
	}
	
	func captureButtonPressed() {
		sessionService.captureImage { (image: UIImage?, error: NSError!) -> Void in
			if (error != nil)
			{
				self.processImage(image)
				/* Move to stage II */
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
	
	private func processImage(image: UIImage?) {
		if (image != nil)
		{
			backCamSessionView.hidden = true;
			self.canvas.image = image
		}
	}
	
	
	
	
}
