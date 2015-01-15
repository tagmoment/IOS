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
	var frontCamera : AnyObject?
	var backCamera : AnyObject?
	
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
		var input : AnyObject! = AVCaptureDeviceInput.deviceInputWithDevice(frontCamera as AVCaptureDevice, error: &err)
		
		if (input != nil) {
			if let error = err? {
				println("ERROR: trying to open camera:" + error.localizedDescription)
				
			}
		}
		
		self.startRunningSession(input: input as AVCaptureInput)
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
		
		self.startRunningSession(input: input as AVCaptureInput)
		
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
		prepareOutput()
		self.captureSession?.addOutput(self.stillImageOutputRef);
		self.captureSession?.startRunning()
	}
	
	func captureImage(#endBlock: (UIImage?, NSError!) -> Void){
		var videoConnection : AVCaptureConnection?
		var connectionsArray = self.stillImageOutputRef!.connections as [AVCaptureConnection]
		
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
		var devices = AVCaptureDevice.devices()
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