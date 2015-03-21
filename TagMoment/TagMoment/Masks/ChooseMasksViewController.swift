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
	
	let CellIdent = "CellIdent"

	@IBOutlet weak var masksCarousel: iCarousel!
	@IBOutlet weak var takeButton: UIButton!
	
	weak var masksChooseDelegate: ChooseMasksControllerDelegate?
	
	var masksViewModels : [TMMaskViewModel]?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		masksCarousel.type = .Linear
		masksCarousel.pagingEnabled = true
		self.masksViewModels = MaskFactory.getViewModels()
		masksCarousel.reloadData()
		masksCarousel.scrollToItemAtIndex(2, animated: false)
    }

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		self.masksChooseDelegate?.maskChosen(self.masksViewModels?[masksCarousel.currentItemIndex].name!)

	}
	
	// MARK: - UICollectionView delegation & datasource
	func numberOfItemsInCarousel(carousel: iCarousel!) -> Int {
		if let count = self.masksViewModels?.count
		{
			return count;
		}
		return 0
	}
	
	func carousel(carousel: iCarousel!, viewForItemAtIndex index: Int, var reusingView view: UIView!) -> UIView!
	{
		
		if (view == nil)
		{
			view = NSBundle.mainBundle().loadNibNamed("MaskCollectionViewCell", owner: nil, options: nil)[0] as UIView
		}
		
		let cell = view as MaskCollectionViewCell
		var maskModel = self.masksViewModels![index]
		cell.maskImage.image = UIImage(named: maskModel.name!.lowercaseString + "_off")
		cell.maskImage.highlightedImage = UIImage(named: maskModel.name!.lowercaseString + "_on")
		cell.maskName.text = maskModel.name
	
		return cell;
	}
	
	func carouselItemWidth(carousel: iCarousel!) -> CGFloat {
		return CGFloat(50.0)
	}
	
	func carouselCurrentItemIndexDidChange(carousel: iCarousel!) {
		for view in carousel.visibleItemViews
		{
			let subview = view as MaskCollectionViewCell
			subview.highlighted = false;
			subview.labelHeightConstraint.constant = 0;
		}
		let view = carousel.currentItemView as MaskCollectionViewCell
		view.highlighted = true
		view.labelHeightConstraint.constant = 20.0;
		let index = masksCarousel.indexOfItemView(view)
		self.masksChooseDelegate?.maskChosen(self.masksViewModels?[index].name!)
	}
	
	func carousel(carousel: iCarousel!, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
		
		if option == .Spacing
		{
			return 1.2
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

}
