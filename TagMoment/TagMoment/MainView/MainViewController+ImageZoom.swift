//
//  MainViewController+ImageZoom.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 9/20/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation

extension MainViewController
{

	func takeImageFromCameraRoll(removeView : Bool)
	{
		let zoomControl = self.canvasZoomControl ?? self.secondZoomControl
		if (zoomControl != nil)
		{
			let image = zoomControl!.capture()
			self.processImageFromPhotoAlbum(image)
		}
		
		if !removeView
		{
			return
		}
		
		zoomControl?.removeFromSuperview()
		self.canvasZoomControl = nil
		self.secondZoomControl = nil
		self.workingZoomControl = nil
	}
	
	func cancelZoomOperation()
	{
		let zoomControl = self.canvasZoomControl ?? self.secondZoomControl
		zoomControl?.removeFromSuperview()
		self.canvasZoomControl = nil
		self.secondZoomControl = nil
		self.workingZoomControl = nil
	}
	
	func prepareZoomControlWithImage(image : UIImage)
	{
		if self.isOnFirstStage() && self.canvasZoomControl == nil
		{
			self.canvasZoomControl = TWImageScrollView(frame: self.canvas.bounds)
			self.canvasZoomControl!.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
			self.canvas.pinSubViewToAllEdges(self.canvasZoomControl!)
			self.workingZoomControl = self.canvasZoomControl
			self.canvas.sendSubviewToBack(self.canvasZoomControl!)
			self.canvas.sendSubviewToBack(self.backCamSessionView ?? self.frontCamSessionView)
			
		}
		else if (self.canvasZoomControl == nil && self.secondZoomControl == nil)
		{
			self.secondZoomControl = TWImageScrollView(frame: self.canvas.bounds)
			self.secondZoomControl!.backgroundColor = UIColor(white: 0.1, alpha: 1.0)
			self.secondImageView.pinSubViewToAllEdges(self.secondZoomControl!)
			self.workingZoomControl = self.secondZoomControl
			self.secondImageView.sendSubviewToBack(self.secondZoomControl!)
			self.secondImageView.sendSubviewToBack(self.backCamSessionView ?? self.frontCamSessionView)
		}
		
		self.workingZoomControl!.displayImage(image)
	}
	
}