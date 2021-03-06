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
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewChoreographer.cameraRollWillAppear(_:)), name: CameraRollWillAppearNotificationName, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewChoreographer.cameraRollWillDisappear(_:)), name: CameraRollWillDisappearNotificationName, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewChoreographer.cameraRollDidSelectImage(_:)), name: ImageFromCameraChosenNotificationName, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewChoreographer.menuWillAppear(_:)), name: MenuWillAppearNotificationName, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewChoreographer.menuWillDisppear(_:)), name: MenuWillDisappearNotificationName, object: nil)
		
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
	
	func menuWillAppear(notification : NSNotification)
	{
		self.dimButtons(false)
	}
	func menuWillDisppear(notification : NSNotification)
	{
		self.dimButtons(true)
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
	
	private func dimButtons(restore : Bool)
	{
		let value : CGFloat = restore ? 1.0 : 0.5
		let navbar = mainViewController?.navigationView
		UIView.animateWithDuration(0.3, animations: { () -> Void in
			if navbar?.backButton.alpha != 0.0
			{
				navbar?.backButton.alpha = value
			}
			
			navbar?.rightButton.alpha = value
			navbar?.middleButton.alpha = value
			}, completion:  nil )
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