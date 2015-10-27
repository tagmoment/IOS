	//
//  ViewChoreographer.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 6/29/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation

class ViewChoreographer : NSObject
{
	weak var mainViewController : MainViewController?
	
	
	
	override init()
	{
		super.init()
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("cameraRollWillAppear:"), name: CameraRollWillAppearNotificationName, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("cameraRollWillDisappear:"), name: CameraRollWillDisappearNotificationName, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("cameraRollDidSelectImage:"), name: ImageFromCameraChosenNotificationName, object: nil)
		
	}
	
	func cameraRollDidSelectImage(notification : NSNotification)
	{
		
		mainViewController?.navigationView?.showRightButton(true, animated: true)
	}
	
	func cameraRollWillDisappear(notification : NSNotification)
	{
		if !self.mainViewController!.isOnSecondStage() && self.mainViewController!.masksViewController.maskAllowsSecondCapture() || self.mainViewController!.canvas.image == nil
		{
			self.takingImageStageAppearance(true)
		}
	
	}
	
	func cameraRollWillAppear(notification : NSNotification)
	{
		self.takingPhotoFromAlbumAppearance(true)
	}
	
	func takingImageStageAppearance(animated: Bool)
	{
		let navbar = mainViewController?.navigationView
		
		if (animated)
		{
			UIView.animateWithDuration(0.5, animations: { () -> Void in
				navbar?.showRightButton(false, animated: false)
				navbar?.showMiddleButton(false, animated: false)
				navbar?.showLeftButton(false, animated: false)
				}, completion: { (finished) -> Void in
					navbar?.applyRetakeButtonAppearanceToBackButton()
					navbar?.zeroFlashState()
					navbar?.restoreMiddleButton()
					UIView.animateWithDuration(0.5, animations: { () -> Void in
						if !self.mainViewController!.isOnFirstStage()
						{
							navbar?.showLeftButton(true, animated: true)
						}
						navbar?.showRightButton(true, animated: true)
						navbar?.showMiddleButton(true, animated: true)
						navbar?.changeMasksButton.alpha = 1.0
					})
			})
		}
		else
		{
			navbar?.zeroFlashState()
			navbar?.restoreMiddleButton()
			navbar?.applyRetakeButtonAppearanceToBackButton()
			navbar?.showRightButton(true, animated: false)
			navbar?.showMiddleButton(true, animated: false)
			navbar?.showLeftButton(true, animated: false)
		}
		
		
	}
	
	func editingStageAppearance(animated: Bool)
	{
		let navbar = mainViewController?.navigationView
		
		if animated
		{
			
			UIView.animateWithDuration(0.5, animations: { () -> Void in
				navbar?.showLeftButton(false, animated: false)
				navbar?.showRightButton(false, animated: false)
				navbar?.showMiddleButton(false, animated: false)
				}, completion: { (finished) -> Void in
					navbar?.applyNextButtonAppearanceToRightButton()
					navbar?.applyRetakeButtonAppearanceToBackButton()
					UIView.animateWithDuration(0.5, animations: { () -> Void in
						navbar?.showRightButton(true, animated: true)
						navbar?.showLeftButton(true, animated: true)
						if let delegate = navbar?.viewDelegate
						{
							delegate.editingStageWillAppear()
						}
					})
			})
			
		}else
		{
			navbar?.applyNextButtonAppearanceToRightButton()
			navbar?.showRightButton(true, animated: false)
			navbar?.showMiddleButton(false, animated: false)
			
		}
	}
	
	func sharingStageAppearance(animated: Bool)
	{
		let navbar = mainViewController?.navigationView
		
		if animated
		{
			
			UIView.animateWithDuration(0.5, animations: { () -> Void in
				navbar?.showLeftButton(false, animated: false)
				navbar?.showRightButton(false, animated: false)
				navbar?.showMiddleButton(false, animated: false)
				}, completion: { (finished) -> Void in
					navbar?.applyDoneButtonAppearanceToRightButton()
					navbar?.applyBackAppearanceToBackButton()
					UIView.animateWithDuration(0.5, animations: { () -> Void in
						navbar?.showRightButton(true, animated: true)
						navbar?.showLeftButton(true, animated: true)
					})
			})
			
		}else
		{
			navbar?.applyDoneButtonAppearanceToRightButton()
			navbar?.applyBackAppearanceToBackButton()
			navbar?.showRightButton(true, animated: false)
			navbar?.showMiddleButton(false, animated: false)
			
		}
	}

	
	private func takingPhotoFromAlbumAppearance(animated: Bool)
	{
		let navbar = mainViewController?.navigationView
		
		
		if (animated)
		{
			
			UIView.animateWithDuration(0.5, animations: { () -> Void in
				navbar?.showRightButton(false, animated: false)
				navbar?.showMiddleButton(false, animated: false)
				navbar?.showLeftButton(false, animated: false)
				}, completion: { (finished) -> Void in
					navbar?.applyNextButtonAppearanceToRightButton()
					navbar?.applyCancelButtonAppearanceToBackButton()
					UIView.animateWithDuration(0.5, animations: { () -> Void in
//						navbar?.showRightButton(true, animated: true)
						navbar?.showLeftButton(true, animated: true)
						
					})
			})
		}
		else
		{
			navbar?.applyNextButtonAppearanceToRightButton()
			navbar?.applyCancelButtonAppearanceToBackButton()
//			navbar?.showRightButton(true, animated: false)
//			navbar?.showLeftButton(true, animated: false)
			
		}
	}
	
	
	
	deinit
	{
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
}