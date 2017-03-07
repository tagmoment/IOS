//
//  CameraSessionHandler.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 1/13/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class CameraSessionService : NSObject{
	var captureSession : AVCaptureSession?
	var stillImageOutputRef : AVCaptureStillImageOutput?
	var frontCamera : AVCaptureDevice?
	var backCamera : AVCaptureDevice?
	
	var flashState = FlashState.auto
	
	override init()
	{
		super.init()
		
		NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: FlashChangedNotification), object: nil, queue: nil) { (notif: Notification) -> Void in
			let dictObject : AnyObject? = notif.userInfo?[FlashStateKey] as AnyObject?
			if let newState = dictObject as? FlashState.RawValue
			{
				self.flashState = FlashState(rawValue: newState)!
				self.flashStateChanged(AVCaptureFlashMode(rawValue: newState)!)
			}
		}
	}
	
	
	deinit
	{
		NotificationCenter.default.removeObserver(self)
	}
	
	func initializeSessionForCaptureLayer() -> AVCaptureVideoPreviewLayer {
		
		self.captureSession = AVCaptureSession()
		self.captureSession?.sessionPreset = AVCaptureSessionPresetPhoto;
		
		let captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		
		captureVideoPreviewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill;
		
		return captureVideoPreviewLayer!;
		
	}
	
	func startSessionOnFrontCamera() {
		initCameras()
		checkForCameraPermissions(continueSessionOnDevice, device: frontCamera)
	}
	
	func startSessionOnBackCamera() {
		initCameras()
		checkForCameraPermissions(continueSessionOnDevice, device: backCamera)
	}
	
	func continueSessionOnDevice(_ device : AVCaptureDevice?)
	{
		if (device == nil)
		{
			print("ERROR: trying to open camera")
			return
		}
		
		var err : NSError? = nil
		var input : AnyObject!
		do {
			input = try AVCaptureDeviceInput(device: device)
		} catch let error as NSError {
			err = error
			input = nil
		}
		
		if (input == nil) {
			if let error = err {
				print("ERROR: trying to open camera:" + error.localizedDescription)
				
			}
			return
		}
		
		self.startRunningSession(input: input as! AVCaptureInput)
	}
	
	func checkForCameraPermissions(_ successfulCallback : @escaping (AVCaptureDevice?) -> Void, device : AVCaptureDevice?)
	{
		let CameraAuthStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
		switch CameraAuthStatus {
			case .authorized:
				successfulCallback(device)
			case .restricted:
				fallthrough
			case .denied:
				self.showAlertRequestingCameraPermission()
			case .notDetermined:
			AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { (granted :Bool) -> Void in
				if granted == true
				{
					DispatchQueue.main.async {
						successfulCallback(device)
					}
				
				}
				else
				{
					DispatchQueue.main.async {
						self.showAlertRequestingCameraPermission()
					}
				}
			});
		}
	}
	
	func showAlertRequestingCameraPermission()
	{
		let alert = UIAlertController(title: "IMPORTANT", message: "This app requires Camera permissions", preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "Settings", style: .cancel) { alert in
				UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
				})
		let mainController = UIApplication.shared.delegate?.window!?.rootViewController! as! MainViewController
			mainController.present(alert, animated: true, completion: nil)
	}
	
	func flashStateChanged(_ newFlashState : AVCaptureFlashMode)
	{
		if let device = self.backCamera
		{
			if (device.isFlashModeSupported(newFlashState) != false)
			{
				self.captureSession?.beginConfiguration()
				do {
					try device.lockForConfiguration()
				} catch _ {
				}
				device.flashMode = newFlashState
				device.unlockForConfiguration()
				self.captureSession?.commitConfiguration()
			}
			
		}
	}
	
	func stopCurrentSession() {
		self.captureSession?.stopRunning()
		cleanup()
	}
	
	fileprivate func cleanup () {
		self.stillImageOutputRef = nil
		self.captureSession = nil
	}
	
	
	fileprivate func startRunningSession(input : AVCaptureInput)
	{
		self.captureSession?.addInput(input)
		flashStateChanged(AVCaptureFlashMode(rawValue: self.flashState.rawValue)!)
		prepareOutput()
		self.captureSession?.addOutput(self.stillImageOutputRef);
		self.captureSession?.startRunning()
	}
	func focus(_ isFrontCamera : Bool, layerHolder : UIView, touchPoint : CGPoint)
	{
		let device = isFrontCamera ? frontCamera : backCamera
		let captureLayer = layerHolder.layer.sublayers![0] as! AVCaptureVideoPreviewLayer
		let convertedPoint = captureLayer.captureDevicePointOfInterest(for: touchPoint)
		
		if (device!.isFocusModeSupported(AVCaptureFocusMode.autoFocus) && device!.isFocusPointOfInterestSupported)
		{
			do {
				try device!.lockForConfiguration()
			} catch _ as NSError {
				print("There was an error with locking the device for configuration")
				return;
				
			}
			
			device!.focusPointOfInterest = convertedPoint
			device!.focusMode = AVCaptureFocusMode.autoFocus
			device!.unlockForConfiguration()
		}
		
	}
	
	func captureImage(endBlock: @escaping (UIImage?, Error?) -> Void){
		var videoConnection : AVCaptureConnection?
		
		let connectionsArray = self.stillImageOutputRef?.connections as? [AVCaptureConnection]
		
		if let connectionsArray = connectionsArray
		{
			for connection in connectionsArray {
				
				for port in connection.inputPorts {
					
					if ((port as AnyObject).mediaType == AVMediaTypeVideo) {
						videoConnection = connection;
						break;
					}
				}
				
				if (videoConnection != nil) {
					break;
				}
		}
		
		}
		
		if (videoConnection == nil)
		{
			return
		}
		
		self.stillImageOutputRef?.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (buffer: CMSampleBuffer? , error: Error? ) -> Void in
			if (error != nil)
			{
				endBlock(nil, error)
			}
			
			if (buffer != nil)
			{
				let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
				let image = UIImage(data: imageData!)
				endBlock(image, error)
			}
		})
	}
	
	fileprivate func prepareOutput(){
		if (self.stillImageOutputRef != nil)
		{
			return
		}
		
		self.stillImageOutputRef = AVCaptureStillImageOutput()
		let outputSettings = [ AVVideoCodecKey : AVVideoCodecJPEG]
		self.stillImageOutputRef?.outputSettings = outputSettings
		
		
	}
	
	
	fileprivate func initCameras() {
		let devices = AVCaptureDevice.devices(withMediaType: AVMediaTypeVideo)
		for device in devices! {
			
			print("Device name: " + (device as AnyObject).localizedName!!)
			
			if ((device as AnyObject).hasMediaType(AVMediaTypeVideo)) {
				
				if ((device as AnyObject).position == AVCaptureDevicePosition.back && backCamera == nil) {
					print("Device position : back")
					backCamera = device as? AVCaptureDevice
				}
				else if ((device as AnyObject).position == AVCaptureDevicePosition.front && frontCamera == nil){
					print("Device position : front")
					frontCamera = device as? AVCaptureDevice
				}
				
				
			}
		}
	}
	

}
