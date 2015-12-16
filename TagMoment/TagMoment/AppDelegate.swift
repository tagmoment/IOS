//
//  AppDelegate.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 1/2/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit
//import TestFairy

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

	var window: UIWindow?


	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		
		TestFairy.begin("008e0e4a9e585f7bb42687114d30b36e864c2a4b")
		UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
		self.window = UIWindow(frame: UIScreen .mainScreen().bounds)
		self.window!.rootViewController = MainViewController(nibName: "MainViewController",bundle: nil)
		
		self.window!.makeKeyAndVisible()
		
		return true
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		SettingsHelper.registerSettingsIfNeeded()
	}

	func applicationWillTerminate(application: UIApplication) {
//		InAppPurchaseRepo.clear()
	}

	

}

