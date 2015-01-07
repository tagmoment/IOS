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
	
	@IBOutlet weak var canvas: UIImageView!
	@IBOutlet weak var controlContainer: UIView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		masksViewController = ChooseMasksViewController(nibName: "ChooseMasksViewController", bundle: nil)
		controlContainer.pinSubViewToAllEdges(masksViewController.view)
		masksViewController.masksChooseDelegate = self
		canvas.image = UIImage(named: "image1.jpeg")
		
		canvas.layer.masksToBounds = true
		frontSessionView = UIView()
		
		canvas.pinSubViewToAllEdges(frontSessionView)
		initializeCamera()
		
//		secondImageView = UIImageView(image: UIImage(named: "image2.jpeg"))
//		canvas.pinSubViewToAllEdges(secondImageView)
    }
	
//	override func viewDidLayoutSubviews() {
//		if (secondImageView.layer.mask == nil){
//			var maskLayer = CAShapeLayer()
//			var bezierMask = TMTraingleMask(rect: canvas.bounds)
//			maskLayer.path = bezierMask.clippingPath.CGPath
//			secondImageView.layer.mask = maskLayer
//			
//			
//		}

//	}
	
	func initializeCamera() {
		captureSession = AVCaptureSession()
		captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
		
		var captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		
		captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
		
		captureVideoPreviewLayer.frame = self.canvas.bounds;
		self.frontSessionView.layer.addSublayer(captureVideoPreviewLayer);
		
		let devices = AVCaptureDevice.devices()
		var frontCamera : AnyObject?
		var backCamera : AnyObject?
		
		for device in devices {
			
			println("Device name: " + device.localizedName!!)
			
			if (device.hasMediaType(AVMediaTypeVideo)) {
				
				if (device.position == AVCaptureDevicePosition.Back) {
					println("Device position : back")
					backCamera = device
				}
				else if (device.position == AVCaptureDevicePosition.Front){
					println("Device position : front")
					frontCamera = device
				}
			}
		}
		
		if (backCamera != nil) {
			var err : NSError? = nil
			var input: AnyObject! = AVCaptureDeviceInput.deviceInputWithDevice(backCamera as AVCaptureDevice, error: &err)
			
			if (input != nil) {
				println("ERROR: trying to open camera:" /*+ err!.localizedDescription()*/)
			}
			captureSession.addInput(input as AVCaptureInput)
		}
		
		self.stillImageOutput = AVCaptureStillImageOutput()
		var outputSettings = [ AVVideoCodecKey : AVVideoCodecJPEG]
		
		stillImageOutput?.outputSettings = outputSettings
		
		captureSession.addOutput(stillImageOutput);
		
		captureSession.startRunning();
		
	}

	func maskChosen(name: String?) {
		if (name != nil){
			var mask = MaskFactory.maskForName(name!, rect: canvas.bounds)
			var maskLayer = CAShapeLayer()
			maskLayer.path = mask?.clippingPath.CGPath
			secondImageView.layer.mask = maskLayer
		}
	}
	
	func captureButtonPressed() {
//		captureSession.stopRunning()
		var videoConnection : AVCaptureConnection?
		var connectionsArray = self.stillImageOutput?.connections as [AVCaptureConnection]
		
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
	
	
	
	
	
}
