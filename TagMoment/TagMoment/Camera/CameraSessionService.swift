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
		
		NSNotificationCenter.defaultCenter().addObserverForName(FlashChangedNotification, object: nil, queue: nil) { (notif: NSNotification) -> Void in
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
		
		let captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		
		captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
		
		return captureVideoPreviewLayer;
		
	}
	
	func startSessionOnFrontCamera() {
		if (frontCamera == nil)
		{
			initCameras()
		}
		
		var err : NSError? = nil
		var input : AnyObject!
		do {
			input = try AVCaptureDeviceInput(device: frontCamera)
		} catch let error as NSError {
			err = error
			input = nil
		}
		
		if (input != nil) {
			if let error = err {
				print("ERROR: trying to open camera:" + error.localizedDescription)
				
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
		var input : AnyObject!
		do {
			input = try AVCaptureDeviceInput(device: backCamera)
		} catch let error as NSError {
			err = error
			input = nil
		}
		
		if (input != nil) {
			if let error = err {
				print("ERROR: trying to open camera:" + error.localizedDescription)

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
	
	private func cleanup () {
		self.stillImageOutputRef = nil
		self.captureSession = nil
	}
	
	
	private func startRunningSession(input input : AVCaptureInput)
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
		let captureLayer = layerHolder.layer.sublayers![0] as! AVCaptureVideoPreviewLayer
		let convertedPoint = captureLayer.captureDevicePointOfInterestForPoint(touchPoint)
		
		if (device!.isFocusModeSupported(AVCaptureFocusMode.AutoFocus) && device!.focusPointOfInterestSupported)
		{
			let error = NSErrorPointer()
			do {
				try device!.lockForConfiguration()
			} catch let error1 as NSError {
				error.memory = error1
			}
			if (error == nil)
			{
				device!.focusPointOfInterest = convertedPoint
				device!.focusMode = AVCaptureFocusMode.AutoFocus
				device!.unlockForConfiguration()
			}
		}
		
	}
	
	func captureImage(endBlock endBlock: (UIImage?, NSError!) -> Void){
		var videoConnection : AVCaptureConnection?
		let connectionsArray = self.stillImageOutputRef!.connections as! [AVCaptureConnection]
		
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
				let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(buffer)
				let image = UIImage(data: imageData)
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
		let outputSettings = [ AVVideoCodecKey : AVVideoCodecJPEG]
		self.stillImageOutputRef?.outputSettings = outputSettings
		
		
	}
	
	
	private func initCameras() {
		let devices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
		for device in devices {
			
			print("Device name: " + device.localizedName!!)
			
			if (device.hasMediaType(AVMediaTypeVideo)) {
				
				if (device.position == AVCaptureDevicePosition.Back) {
					print("Device position : back")
					backCamera = device as? AVCaptureDevice
				}
				else if (device.position == AVCaptureDevicePosition.Front){
					print("Device position : front")
					frontCamera = device as? AVCaptureDevice
				}
				
				
			}
		}
	}
	

}