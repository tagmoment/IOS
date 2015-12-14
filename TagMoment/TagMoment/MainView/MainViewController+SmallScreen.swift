//
//  MainViewController+SmallScreen.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 4/11/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation
extension MainViewController
{
	func changeMasksCarouselPositionIfNeeded()
	{
		if MainViewController.isSmallestScreen()
		{
			masksViewController.masksCarousel.removeFromSuperview()
			
			self.canvas.pinSubViewToTop(masksViewController.masksCarousel, heightContraint: 88)
			self.canvas.bringSubviewToFront(masksViewController.masksCarousel)
			masksViewController.prepareForSmallScreenLayout()
			self.navigationView.changeMasksButton.selected = true
			turnOffMasks(true)
		}
	}
	
	func changeFiltersLayoutIfNeeded()
	{
		if MainViewController.isSmallestScreen()
		{
			filtersViewController.prepareForSmallScreenLayout()
			
		}
	}
	
	func changeSharingLayoutIfNeeded()
	{
		if MainViewController.isSmallestScreen()
		{
			sharingController.prepareForSmallScreenLayout()
			
		}
	}

	func forwardMasksToFrontIfNeeded()
	{
		if MainViewController.isSmallestScreen()
		{
			if (masksViewController != nil)
			{
				self.canvas.bringSubviewToFront(masksViewController.masksCarousel)
			}
			
		}
	}
	
	func changeNavigationViewForFiltersIfNeeded()
	{
		if MainViewController.isSmallestScreen()
		{
			self.navigationView.replicateJumperButtonToMiddleButton(filtersViewController.jumperButton)
		}
	}
	
	func turnOffMasks(delay: Bool)
	{
		UIView.animateWithDuration(0.3, delay: delay ? 1.0 : 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
			
			self.masksViewController.masksCarousel.alpha = 0.0
			}, completion: { (finished : Bool) -> Void in
				self.navigationView.changeMasksButton.selected = false
		})
	}
	
	func turnOnMasks()
	{
		UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
			
			self.masksViewController.masksCarousel.alpha = 1.0
			}, completion: nil)
	}
	
	func removeMasksIfNeeded()
	{
		if MainViewController.isSmallestScreen()
		{
			self.turnOffMasks(false)
			navigationView.hideMasksButton(true)
			masksViewController.masksCarousel.removeFromSuperview()
		}
	}
	
	// MARK: - NavBarDelegation 
	func editingStageWillAppear()
	{
		changeNavigationViewForFiltersIfNeeded()
	}
	
	func maskButtonPressed() {
		if (navigationView.changeMasksButton.selected)
		{
			self.turnOnMasks()
		}
		else
		{
			self.turnOffMasks(false)
		}
	}
	
	// MARK: - Private
	class func isSmallestScreen() -> Bool
	{
		return UIScreen.mainScreen().bounds.height <= 480
	}
}