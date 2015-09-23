//
//  TimerHandler.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 9/23/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation

class TimerHandler : NSObject{
	var counting = false
	weak var numberImageView : UIImageView?
	var timer : NSTimer?
	
	func applyCountDownEffectWithCount(count : Int, onView view : UIView)
	{
		if counting
		{
			return
		}
		
		counting = !counting
		
		let numberImage = UIImage(named: "\(count)")
		let imageView = UIImageView(image: numberImage)
		imageView.backgroundColor = UIColor.clearColor()
		imageView.tag = count
		numberImageView = imageView
		view.pinSubViewToAllEdges(numberImageView!)
		timer = NSTimer.scheduledTimerWithTimeInterval(0.8, target: self, selector: Selector("timerInterval:"), userInfo: nil, repeats: false)
		
		
	}
	func cancelTimer()
	{
		timer?.invalidate()
		timer = nil
		numberImageView?.removeFromSuperview()
		numberImageView = nil
	}
	func timerInterval(sender : AnyObject!)
	{
		numberImageView!.tag--;
		timer?.invalidate()
		timer = nil
		if numberImageView!.tag == 0
		{
			
			numberImageView!.removeFromSuperview()
			numberImageView = nil
			counting = !counting
			let mainController = UIApplication.sharedApplication().delegate?.window!?.rootViewController! as! MainViewController
			mainController.captureButtonPressed()
			return
		}
		
		let numberImage = UIImage(named: "\(numberImageView!.tag)")
		numberImageView?.image = numberImage
		timer = NSTimer.scheduledTimerWithTimeInterval(0.8, target: self, selector: Selector("timerInterval:"), userInfo: nil, repeats: false)
	}
	
	
}