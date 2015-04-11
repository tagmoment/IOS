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
		if isSmallestScreen()
		{
			masksViewController.masksCarousel.removeFromSuperview()
			
			self.canvas.pinSubViewToTop(masksViewController.masksCarousel, heightContraint: 88)
			self.canvas.bringSubviewToFront(masksViewController.masksCarousel)
			masksViewController.centerTakeImageButton()
			self.navigationView.changeMasksButton.selected = true
			turnOffMasks(true)
		}
	}
	
	func changeFiltersLayoutIfNeeded()
	{
		if isSmallestScreen()
		{
			filtersViewController.prepareForSmallScreenLayout()
			
		}
	}
	
	func changeSharingLayoutIfNeeded()
	{
		if isSmallestScreen()
		{
			sharingController.prepareForSmallScreenLayout()
			
		}
	}
	
	func forwardMasksToFrontIfNeeded()
	{
		if isSmallestScreen()
		{
			if (masksViewController != nil)
			{
				self.canvas.bringSubviewToFront(masksViewController.masksCarousel)
			}
			
		}
	}
	
	func changeNavigationViewForFiltersIfNeeded()
	{
		if isSmallestScreen()
		{
			self.navigationView.replicateJumperButtonToMiddleButton(filtersViewController.jumperButton)
		}
	}
	
	func turnOffMasks(delay: Bool)
	{
		UIView.animateWithDuration(0.7, delay: delay ? 1.0 : 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
			
			self.masksViewController.masksCarousel.alpha = 0.0
			}, completion: { (finished : Bool) -> Void in
				self.navigationView.changeMasksButton.selected = false
		})
	}
	
	func turnOnMasks()
	{
		UIView.animateWithDuration(0.7, delay: 0.0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
			
			self.masksViewController.masksCarousel.alpha = 1.0
			}, nil)
	}
	
	func removeMasksIfNeeded()
	{
		if isSmallestScreen()
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
	private func isSmallestScreen() -> Bool
	{
		return UIScreen.mainScreen().bounds.height <= 480
	}
}