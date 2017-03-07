//
//  GoogleAnalyticsReporter.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 13/04/2016.
//  Copyright © 2016 TagMoment. All rights reserved.
//

class GoogleAnalyticsReporter: NSObject {

	static func ReportPageView(_ screenName : String)
	{
		let tracker = GAI.sharedInstance().defaultTracker
		tracker?.set(kGAIScreenName, value: screenName)
		
		let builder = GAIDictionaryBuilder.createScreenView()
		tracker?.send(builder?.build() as [NSObject: AnyObject]!)
	}
	
	static func reportEvent(_ category: String, action: String, label: String?, value: NSNumber?)
	{
		let tracker = GAI.sharedInstance().defaultTracker
		let builder = GAIDictionaryBuilder.createEvent(withCategory: category, action: action, label: label, value: value)
		tracker?.send(builder?.build() as [NSObject: AnyObject]!)
	}
}