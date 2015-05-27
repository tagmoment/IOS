//
//  ChooseMasksViewController.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 1/2/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit



protocol ChooseMasksControllerDelegate : class{
	func maskChosen(name : String?)
	func captureButtonPressed()
	func switchCamButtonPressed()
}

class ChooseMasksViewController: UIViewController, iCarouselDataSource, iCarouselDelegate{
	
	static var didMasksScroll = false
	
	let CellIdent = "CellIdent"

	@IBOutlet var masksCarousel: iCarousel!
	@IBOutlet weak var takeButton: UIButton!
	
	@IBOutlet weak var switchCamButton: UIButton!
	
	@IBOutlet weak var captureButtonCenterYConstraint: NSLayoutConstraint!
	
	weak var masksChooseDelegate: ChooseMasksControllerDelegate?
	
	var masksViewModels : [TMMaskViewModel]?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		masksCarousel.type = .Linear
		masksCarousel.pagingEnabled = true
		self.masksViewModels = MaskFactory.getViewModels()
		masksCarousel.reloadData()
		
		let startIndex = ChooseMasksViewController.didMasksScroll ? 0 : 5
		masksCarousel.scrollToItemAtIndex(startIndex, animated: false)
    }

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		if let view = masksCarousel.itemViewAtIndex(masksCarousel.currentItemIndex)
		{
			let subview = view as! MaskCollectionViewCell
			subview.highlighted = true
			self.masksChooseDelegate?.maskChosen(self.masksViewModels?[masksCarousel.currentItemIndex].name!)
		}
		
		if !ChooseMasksViewController.didMasksScroll
		{
			ChooseMasksViewController.didMasksScroll = true
			NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: Selector("scrollAnimation:"), userInfo: nil, repeats: false)
		}
	}
	
	@objc func scrollAnimation(sender : AnyObject!)
	{
		masksCarousel.scrollToItemAtIndex(0, duration: 2.5)
	}
	// MARK: - UICollectionView delegation & datasource
	func numberOfItemsInCarousel(carousel: iCarousel!) -> Int {
		if let count = self.masksViewModels?.count
		{
			return count;
		}
		return 0
	}
	
	func carousel(carousel: iCarousel!, viewForItemAtIndex index: Int,reusingView view: UIView!) -> UIView!
	{
		var cell : MaskCollectionViewCell;
		if (view == nil)
		{
			cell = NSBundle.mainBundle().loadNibNamed("MaskCollectionViewCell", owner: nil, options: nil)[0] as! MaskCollectionViewCell
		}
		else
		{
			cell = view as! MaskCollectionViewCell
		}
		
		var maskModel = self.masksViewModels![index]
		cell.maskImage.image = UIImage(named: maskModel.name!.lowercaseString + "_off")
		cell.maskImage.highlightedImage = UIImage(named: maskModel.name!.lowercaseString + "_on")
		cell.maskName.text = maskModel.name
	
		return cell;
	}
	
	func carouselItemWidth(carousel: iCarousel!) -> CGFloat {
		return CGFloat(70.0)
	}
	
	func carouselCurrentItemIndexDidChange(carousel: iCarousel!) {
		for view in carousel.visibleItemViews
		{
			let subview = view as! MaskCollectionViewCell
			subview.highlighted = false;
		}
		if let view = carousel.currentItemView
		{
			let subview = view as! MaskCollectionViewCell
			subview.highlighted = true
			let index = masksCarousel.indexOfItemView(view)
			self.masksChooseDelegate?.maskChosen(self.masksViewModels?[index].name!)
		}
		
		
	}
	
	func carousel(carousel: iCarousel!, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
		
		if option == .Spacing
		{
			return 1.05
		}
		return value;
	}
	
	@IBAction func takeButtonPressed(sender: AnyObject) {
		UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
					self.takeButton.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI), 0, 0, 1)
					}, completion: {(Bool) -> () in
						UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
							self.takeButton.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI*2), 0, 0, 1)
							}, completion: {(Bool) -> Void in
								self.takeButton.layer.transform = CATransform3DIdentity
							}
						)
					}
		)
		if (self.masksChooseDelegate != nil)
		{
			self.masksChooseDelegate?.captureButtonPressed()
		}
	}
	@IBAction func switchCamButtonPressed(sender: AnyObject) {
		if (self.masksChooseDelegate != nil)
		{
			self.masksChooseDelegate?.switchCamButtonPressed()
		}
	}
	
	func getSelectedViewModel() -> TMMaskViewModel
	{
		return self.masksViewModels![self.masksCarousel.currentItemIndex];
	}
	
	func maskAllowsSecondCapture() -> Bool
	{
		return !getSelectedViewModel().hasOneCapture
	}

	func centerTakeImageButton()
	{
		captureButtonCenterYConstraint.constant = 0
	}
}
