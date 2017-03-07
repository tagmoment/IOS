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
		NotificationCenter.default.addObserver(self, selector: #selector(ViewChoreographer.cameraRollWillAppear(_:)), name: NSNotification.Name(rawValue: CameraRollWillAppearNotificationName), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(ViewChoreographer.cameraRollWillDisappear(_:)), name: NSNotification.Name(rawValue: CameraRollWillDisappearNotificationName), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(ViewChoreographer.cameraRollDidSelectImage(_:)), name: NSNotification.Name(rawValue: ImageFromCameraChosenNotificationName), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(ViewChoreographer.menuWillAppear(_:)), name: NSNotification.Name(rawValue: MenuWillAppearNotificationName), object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(ViewChoreographer.menuWillDisppear(_:)), name: NSNotification.Name(rawValue: MenuWillDisappearNotificationName), object: nil)
		
	}
	
	func cameraRollDidSelectImage(_ notification : Notification)
	{
		
		mainViewController?.navigationView?.showRightButton(true, animated: true)
	}
	
	func cameraRollWillDisappear(_ notification : Notification)
	{
		if !self.mainViewController!.isOnSecondStage() && self.mainViewController!.masksViewController.maskAllowsSecondCapture() || self.mainViewController!.canvas.image == nil
		{
			self.takingImageStageAppearance(true)
		}
	
	}
	
	func cameraRollWillAppear(_ notification : Notification)
	{
		self.takingPhotoFromAlbumAppearance(true)
	}
	
	func menuWillAppear(_ notification : Notification)
	{
		self.dimButtons(false)
	}
	func menuWillDisppear(_ notification : Notification)
	{
		self.dimButtons(true)
	}
	func takingImageStageAppearance(_ animated: Bool)
	{
		let navbar = mainViewController?.navigationView
		
		if (animated)
		{
			UIView.animate(withDuration: 0.5, animations: { () -> Void in
				navbar?.showRightButton(false, animated: false)
				navbar?.showMiddleButton(false, animated: false)
				navbar?.showLeftButton(false, animated: false)
				}, completion: { (finished) -> Void in
					navbar?.applyRetakeButtonAppearanceToBackButton()
					navbar?.zeroFlashState()
					navbar?.restoreMiddleButton()
					UIView.animate(withDuration: 0.5, animations: { () -> Void in
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
	
	fileprivate func dimButtons(_ restore : Bool)
	{
		let value : CGFloat = restore ? 1.0 : 0.5
		let navbar = mainViewController?.navigationView
		UIView.animate(withDuration: 0.3, animations: { () -> Void in
			if navbar?.backButton.alpha != 0.0
			{
				navbar?.backButton.alpha = value
			}
			
			navbar?.rightButton.alpha = value
			navbar?.middleButton.alpha = value
			}, completion:  nil )
	}
	
	func editingStageAppearance(_ animated: Bool)
	{
		let navbar = mainViewController?.navigationView
		
		if animated
		{
			
			UIView.animate(withDuration: 0.5, animations: { () -> Void in
				navbar?.showLeftButton(false, animated: false)
				navbar?.showRightButton(false, animated: false)
				navbar?.showMiddleButton(false, animated: false)
				}, completion: { (finished) -> Void in
					navbar?.applyNextButtonAppearanceToRightButton()
					navbar?.applyRetakeButtonAppearanceToBackButton()
					UIView.animate(withDuration: 0.5, animations: { () -> Void in
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
	
	func sharingStageAppearance(_ animated: Bool)
	{
		let navbar = mainViewController?.navigationView
		
		if animated
		{
			
			UIView.animate(withDuration: 0.5, animations: { () -> Void in
				navbar?.showLeftButton(false, animated: false)
				navbar?.showRightButton(false, animated: false)
				navbar?.showMiddleButton(false, animated: false)
				}, completion: { (finished) -> Void in
					navbar?.applyDoneButtonAppearanceToRightButton()
					navbar?.applyBackAppearanceToBackButton()
					UIView.animate(withDuration: 0.5, animations: { () -> Void in
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

	
	fileprivate func takingPhotoFromAlbumAppearance(_ animated: Bool)
	{
		let navbar = mainViewController?.navigationView
		
		
		if (animated)
		{
			
			UIView.animate(withDuration: 0.5, animations: { () -> Void in
				navbar?.showRightButton(false, animated: false)
				navbar?.showMiddleButton(false, animated: false)
				navbar?.showLeftButton(false, animated: false)
				}, completion: { (finished) -> Void in
					navbar?.applyNextButtonAppearanceToRightButton()
					navbar?.applyCancelButtonAppearanceToBackButton()
					UIView.animate(withDuration: 0.5, animations: { () -> Void in
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
		NotificationCenter.default.removeObserver(self)
	}
	
}
