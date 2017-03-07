//
//  VolumeButtonsHandler.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 16/04/2016.
//  Copyright © 2016 TagMoment. All rights reserved.
//

import JPSVolumeButtonHandler

let TMVolumeUpButtonPressedNotificationName = "TMVolumeUpButtonPressedNotification"

let TMVolumeDownButtonPressedNotificationName = "TMVolumeDownButtonPressedNotification"

extension MainViewController {
	
	
	
	func startObservingVolumeChange()
	{
		self.volumeButtonsHandler = JPSVolumeButtonHandler(up: { 
				self.handleVolumeUp()
			}, downBlock: { 
				self.handleVolumeDown()
		})
	}
	
	func handleVolumeDown()
	{
		self.sendNotification(TMVolumeDownButtonPressedNotificationName)
	}

	func handleVolumeUp()
	{
		self.sendNotification(TMVolumeUpButtonPressedNotificationName)
	}
	
	fileprivate func sendNotification(_ name : String)
	{
		NotificationCenter.default.post(name: Notification.Name(rawValue: name) , object: nil)
	}
}