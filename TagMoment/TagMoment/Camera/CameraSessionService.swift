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
	
	var flashState = FlashState.Auto
	
	override init()
	{
		super.init()
		
		NSNotificationCenter.defaultCenter().addObserverForName(FlashChangedNotification, object: nil, queue: nil) { (notif: NSNotification!) -> Void in
			let dictObject : AnyObject? = notif.userInfo?[FlashStateKey]
			if let newState = dictObject as? FlashState.RawValue
			{
				self.flashState = FlashState(rawValue: newState)!
				self.flashStateChanged(AVCaptureFlashMode(rawValue: newState)!)
			}
		}
	}
	
	
	deinit
	{
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	func initializeSessionForCaptureLayer() -> AVCaptureVideoPreviewLayer {
		
		self.captureSession = AVCaptureSession()
		self.captureSession?.sessionPreset = AVCaptureSessionPresetPhoto;
		
		var captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		
		captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
		
		return captureVideoPreviewLayer;
		
	}
	
	func startSessionOnFrontCamera() {
		if (frontCamera == nil)
		{
			initCameras()
		}
		
		var err : NSError? = nil
		var input : AnyObject! = AVCaptureDeviceInput.deviceInputWithDevice(frontCamera , error: &err)
		
		if (input != nil) {
			if let error = err {
				println("ERROR: trying to open camera:" + error.localizedDescription)
				
			}
		}
		
		self.startRunningSession(input: input as! AVCaptureInput)
	}
	
	func startSessionOnBackCamera() {
		if (backCamera == nil)
		{
			initCameras()
		}
		
		
		var err : NSError? = nil
		var input : AnyObject! = AVCaptureDeviceInput.deviceInputWithDevice(backCamera, error: &err)
		
		if (input != nil) {
			if let error = err {
				println("ERROR: trying to open camera:" + error.localizedDescription)

			}
		}
		
		self.startRunningSession(input: input as! AVCaptureInput)
		
	}
	
	func flashStateChanged(newFlashState : AVCaptureFlashMode)
	{
		if let device = self.backCamera
		{
			if (device.isFlashModeSupported(newFlashState) != false)
			{
				self.captureSession?.beginConfiguration()
				device.lockForConfiguration(nil)
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
	
	private func cleanup () {
		self.stillImageOutputRef = nil
		self.captureSession = nil
	}
	
	
	private func startRunningSession(#input : AVCaptureInput)
	{
		self.captureSession?.addInput(input)
		flashStateChanged(AVCaptureFlashMode(rawValue: self.flashState.rawValue)!)
		prepareOutput()
		self.captureSession?.addOutput(self.stillImageOutputRef);
		self.captureSession?.startRunning()
	}
	func focus(isFrontCamera : Bool, layerHolder : UIView, touchPoint : CGPoint)
	{
		let device = isFrontCamera ? frontCamera : backCamera
		let captureLayer = layerHolder.layer.sublayers[0] as! AVCaptureVideoPreviewLayer
		let convertedPoint = captureLayer.captureDevicePointOfInterestForPoint(touchPoint)
		
		if (device!.isFocusModeSupported(AVCaptureFocusMode.AutoFocus) && device!.focusPointOfInterestSupported)
		{
			var error = NSErrorPointer()
			device!.lockForConfiguration(error)
			if (error == nil)
			{
				device!.focusPointOfInterest = convertedPoint
				device!.focusMode = AVCaptureFocusMode.AutoFocus
				device!.unlockForConfiguration()
			}
		}
		
	}
	
	func captureImage(#endBlock: (UIImage?, NSError!) -> Void){
		var videoConnection : AVCaptureConnection?
		var connectionsArray = self.stillImageOutputRef!.connections as! [AVCaptureConnection]
		
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
		self.stillImageOutputRef?.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: { (buffer: CMSampleBuffer! , error: NSError! ) -> Void in
			if (error != nil)
			{
				endBlock(nil, error)
			}
			
			if (buffer != nil)
			{
				var imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
				var image = UIImage(data: imageData)
				endBlock(image, error)
			}
		})
	}
	
	private func prepareOutput(){
		if (self.stillImageOutputRef != nil)
		{
			return
		}
		
		self.stillImageOutputRef = AVCaptureStillImageOutput()
		var outputSettings = [ AVVideoCodecKey : AVVideoCodecJPEG]
		self.stillImageOutputRef?.outputSettings = outputSettings
		
		
	}
	
	
	private func initCameras() {
		var devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
		for device in devices {
			
			println("Device name: " + device.localizedName!!)
			
			if (device.hasMediaType(AVMediaTypeVideo)) {
				
				if (device.position == AVCaptureDevicePosition.Back) {
					println("Device position : back")
					backCamera = device as? AVCaptureDevice
				}
				else if (device.position == AVCaptureDevicePosition.Front){
					println("Device position : front")
					frontCamera = device as? AVCaptureDevice
				}
				
				
			}
		}
	}
	

}