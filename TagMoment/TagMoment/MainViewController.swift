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
	var frontSessionView : UIView!
	
	var captureSession : AVCaptureSession!
	var stillImageOutput : AVCaptureStillImageOutput?
	
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
		frontSessionView = UIView()
		
		canvas.pinSubViewToAllEdges(frontSessionView)
		frontSessionView.frame = canvas.frame
		initStageOne()
		secondImageView = UIImageView(image: UIImage(named: "image2.jpeg"))
		canvas.pinSubViewToAllEdges(secondImageView)
		
    }
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.masksViewController.masksCollectionView.selectItemAtIndexPath(NSIndexPath(forItem: 3, inSection: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.CenteredHorizontally)
		self.masksViewController.collectionView(self.masksViewController.masksCollectionView, didSelectItemAtIndexPath: NSIndexPath(forItem: 3, inSection: 0))
	}
	
	func initStageOne()
	{
		addVideoLayer(toView: self.frontSessionView)
		sessionService.startSessionOnBackCamera()
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
//		captureSession.stopRunning()
		var videoConnection : AVCaptureConnection?
		var connectionsArray = self.stillImageOutput!.connections as [AVCaptureConnection]
		
		for connection in connectionsArray {
			
			for port in connection.inputPorts {
				
				if (port.mediaType == AVMediaTypeVideo) {
					videoConnection = connection;
					break;
				}
			}
			
			if (videoConnection != nil) {
				break;
			}
		}
		self.stillImageOutput?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (buffer: CMSampleBuffer! , error: NSError! ) -> Void in
			
			if (buffer != nil)
			{
				var imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
				self.processImage(imageData)
			}
		})
		
	}
	
	func processImage(imageData: NSData!) {
		if (imageData != nil)
		{
			var image = UIImage(data: imageData)
			frontSessionView.hidden = true;
			self.canvas.image = image
		}
	}
	
//	func createBlurredImage() -> UIImage {
//		
//	}
//	
	
	
	
}
