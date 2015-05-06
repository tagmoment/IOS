//
//  MainViewController+CameraViews.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 5/6/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation
import AVFoundation
extension MainViewController
{
	func changeMaskViewFrame(newFrame : CGRect)
	{
		let sessionView = self.secondImageView.viewWithTag(1000)
		if let holder = sessionView
		{
			let captureVideoLayer = holder.layer.sublayers[0] as! AVCaptureVideoPreviewLayer
			captureVideoLayer.frame = newFrame
		}
	}
}