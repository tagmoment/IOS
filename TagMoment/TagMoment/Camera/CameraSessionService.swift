//
//  CameraSessionHandler.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 1/13/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation
import AVFoundation

class CameraSessionService : NSObject{
	var captureSession : AVCaptureSession?
	var stillImageOutputRef : AVCaptureStillImageOutput?
	var frontCamera : AnyObject?
	var backCamera : AnyObject?
	
	func initializeSessionForCaptureLayer() -> AVCaptureVideoPreviewLayer {
		
		self.captureSession = AVCaptureSession()
		self.captureSession?.sessionPreset = AVCaptureSessionPresetPhoto;
		
		var captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
		
		captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
		
		return captureVideoPreviewLayer;
		
	}
	
	func startSessionOnBackCamera() {
		if (backCamera == nil)
		{
			initCameras()
		}
		
		var err : NSError? = nil
		var input : AnyObject! = AVCaptureDeviceInput.deviceInputWithDevice(backCamera as AVCaptureDevice, error: &err)
			
		if (input != nil) {
			if let error = err? {
				println("ERROR: trying to open camera:" + error.localizedDescription)

			}
		}
		self.captureSession?.addInput(input as AVCaptureInput)
		prepareOutput()
		self.captureSession?.addOutput(self.stillImageOutputRef);
		self.captureSession?.startRunning()
		
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
		let devices = AVCaptureDevice.devices()
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
	}
}