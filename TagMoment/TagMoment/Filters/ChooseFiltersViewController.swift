//
//  ChooseFiltersViewController.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 1/15/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit


let CellIdent = "CellIdentifier"

protocol ChooseFiltesControllerDelegate : class{
	func workingImage(mainImage : Bool) -> UIImage
	func workingImageView(mainImage : Bool) -> UIImageView
}

class ChooseFiltersViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{

	@IBOutlet weak var filterButtonsCollecionView: UICollectionView!
	@IBOutlet weak var someSlider : UISlider!
	
	@IBOutlet weak var sliderCenterYConstraint : NSLayoutConstraint!
	
	@IBOutlet weak var disabledSliderCenterYConstraint : NSLayoutConstraint!
	weak var filtersChooseDelegate: ChooseFiltesControllerDelegate?
	
	var currentContext : CIContext!
	var currentFilterModel : TMFilterBase!
	var currentCIImage : CIImage!
	var lastFilterModel : TMFilterBase!
	var lastSelectedIndex : NSInteger = 0
	var lastSliderValue : Float = 0.0
	
	@IBOutlet var jumperButton: UIButton!
	var maskViewModel: TMMaskViewModel!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		filterButtonsCollecionView.registerNib(UINib(nibName: "FilterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CellIdent)
		self.jumperButton.setImage(UIImage(named: maskViewModel.getJumperImageName() + "1"), forState: UIControlState.Normal)
		if (maskViewModel.hasOneCapture)
		{
			self.jumperButton.enabled = false
		}
		else
		{
			self.jumperButton.setImage(UIImage(named: maskViewModel.getJumperImageName() + "2"), forState: UIControlState.Selected)
		}
		self.applySliderVisuals()
		
		currentCIImage = CIImage(CGImage: self.workingImage().CGImage)
		currentContext = CIContext(options:nil)
		
		
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		self.filterButtonsCollecionView.selectItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.CenteredHorizontally)
		self.collectionView(self.filterButtonsCollecionView, didSelectItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
	}
	func workingImage() -> UIImage!
	{
		if let delegate = filtersChooseDelegate
		{
			return delegate.workingImage(isWorkingOnOuterImage())
		}
		
		return nil
	}
	
	func workingImageView() -> UIImageView!
	{
		if let delegate = filtersChooseDelegate
		{
			return delegate.workingImageView(isWorkingOnOuterImage())
		}
		
		return nil
	}
	
	@IBAction func sliderValueChanged(sender: AnyObject) {
		var slider : UISlider = sender as! UISlider
		let sliderValue = slider.value
		
		slider.thumbTintColor = UIColor(white: CGFloat (sliderValue*0.7 + 0.3) , alpha: 1.0);
		currentFilterModel.applyFilterValue(sliderValue)
		let outputImage = currentFilterModel.outputImage()
		if (outputImage != nil)
		{
			let cgimg = currentContext.createCGImage(outputImage, fromRect: outputImage.extent())
			
			let newImage = UIImage(CGImage: cgimg, scale: UIScreen.mainScreen().scale, orientation: self.workingImage().imageOrientation)
			
			self.workingImageView().image = newImage
		}
		
	}

	private func isWorkingOnOuterImage() -> Bool
	{
		return !jumperButton.selected
	}
	
	func changeJumperSelectionState(toState selected: Bool)
	{
		if (self.jumperButton.selected != selected)
		{
			self.jumperButtonPressed(self.jumperButton)
		}
	}
	
	@IBAction func jumperButtonPressed(sender: AnyObject) {
		self.jumperButton.selected = !self.jumperButton.selected
		currentCIImage = CIImage(CGImage: self.workingImage().CGImage)
		currentContext = CIContext(options:nil)
		if (self.lastFilterModel == nil)
		{
			saveCurrentState()
			self.filterButtonsCollecionView.deselectItemAtIndexPath(NSIndexPath(forItem: lastSelectedIndex, inSection: 0), animated: false)
			self.collectionView(self.filterButtonsCollecionView, didDeselectItemAtIndexPath: NSIndexPath(forItem: lastSelectedIndex, inSection: 0))
			self.filterButtonsCollecionView.selectItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.CenteredHorizontally)
			self.collectionView(self.filterButtonsCollecionView, didSelectItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
		}
		else
		{
			restoreFilterState()
		}
	}
	
	func prepareForSmallScreenLayout()
	{
		self.jumperButton.removeFromSuperview()
		self.disabledSliderCenterYConstraint.constant = 35
		self.sliderCenterYConstraint.constant = 35
	}
	
	/*
	// MARK: - Collection View Delegation
	*/
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return TMFilterFactory.getFilters().count
	}
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		
		var cell = filterButtonsCollecionView.dequeueReusableCellWithReuseIdentifier(CellIdent, forIndexPath: indexPath) as! FilterCollectionViewCell
		
		var filterModel = TMFilterFactory.getFilters()[indexPath.item]
		
		var imageName = filterModel.iconName
		var imageOn = imageName + "_on"
		cell.iconImageView.image = UIImage(named: imageOn)
		cell.iconImageView.alpha = cell.selected ? 1.0 : 0.3
		cell.filterName.text = filterModel.displayName.lowercaseString
		return cell
	}
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		
		var filterModel = TMFilterFactory.getFilters()[indexPath.item]
		
		let cell = collectionView.cellForItemAtIndexPath(indexPath) as? FilterCollectionViewCell
		if (cell != nil)
		{
			cell!.iconImageView.alpha = 1.0
		}

		
		self.currentFilterModel = filterModel
		filterModel.inputImage(self.currentCIImage)
		if (filterModel.supportsChangingValues())
		{
			self.someSlider.hidden = false
			
		}
		else
		{
			self.workingImageView().image = self.workingImage()
			self.someSlider.hidden = true
			
		}
		self.someSlider.value = 1.0;
		sliderValueChanged(self.someSlider)
		scrollToMoreVisibleCellsIfNeeded()

	}
	
	
	
	func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
		let filterModel = TMFilterFactory.getFilters()[indexPath.item]
		let cell = collectionView.cellForItemAtIndexPath(indexPath)
		
		if (cell != nil)
		{
			let casted = cell as! FilterCollectionViewCell
			casted.iconImageView.alpha = 0.3
		}
		
	}
	
	private func scrollToMoreVisibleCellsIfNeeded()
	{
		let selected = self.filterButtonsCollecionView.indexPathsForSelectedItems()
		let indexPath = selected[0] as! NSIndexPath
		let cell = self.filterButtonsCollecionView.cellForItemAtIndexPath(indexPath)
		
		if (cell != nil)
		{
			if (cell!.frame.origin.x - self.filterButtonsCollecionView.contentOffset.x < 0)
			{
				var indexPathItem = indexPath.item == 0 ? indexPath.item : indexPath.item - 1
				self.filterButtonsCollecionView.scrollToItemAtIndexPath(NSIndexPath(forItem: indexPathItem, inSection: indexPath.section), atScrollPosition: UICollectionViewScrollPosition.Left, animated: true)
			}
			else if (cell!.frame.maxX > self.filterButtonsCollecionView.contentOffset.x + self.filterButtonsCollecionView.frame.width)
			{
				var indexPathItem = indexPath.item == TMFilterFactory.getFilters().count - 1 ? indexPath.item : indexPath.item + 1
				self.filterButtonsCollecionView.scrollToItemAtIndexPath(NSIndexPath(forItem: indexPathItem, inSection: indexPath.section), atScrollPosition: UICollectionViewScrollPosition.Right, animated: true)
			}
		}
	}
	
	private func applySliderVisuals()
	{
		let minImage = self.sliderImageWithColor(UIColor.whiteColor())
		self.someSlider.setMinimumTrackImage(minImage, forState: .Normal)
		let maxImage = self.sliderImageWithColor(UIColor.darkGrayColor())
		self.someSlider.setMaximumTrackImage(maxImage, forState: .Normal)
		self.someSlider.setThumbImage(UIImage(named: "opacity_button_50"), forState: .Normal)
	}
	
	private func sliderImageWithColor(color: UIColor) -> UIImage
	{
		let rect = CGRect(x: 0,y: 0,width: 1,height: 1)
		UIGraphicsBeginImageContextWithOptions(rect.size, false, 0);
		color.setFill()
		UIRectFill(rect);
		let image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		return image;
	}
	
	func saveCurrentState()
	{
		lastFilterModel = currentFilterModel
		lastSliderValue = self.someSlider.value
		lastSelectedIndex = self.filterButtonsCollecionView.indexPathsForSelectedItems()[0].item

	}
	
	func restoreFilterState()
	{
		let tempIndex = self.filterButtonsCollecionView.indexPathsForSelectedItems()[0].item
		self.filterButtonsCollecionView.deselectItemAtIndexPath(NSIndexPath(forItem: tempIndex, inSection: 0), animated: false)
		self.collectionView(self.filterButtonsCollecionView, didDeselectItemAtIndexPath: NSIndexPath(forItem: tempIndex, inSection: 0))
		self.filterButtonsCollecionView.selectItemAtIndexPath(NSIndexPath(forItem: lastSelectedIndex, inSection: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.CenteredHorizontally)
		var filterModel = TMFilterFactory.getFilters()[lastSelectedIndex]
		
		var imageName = filterModel.iconName
		var imageOn = imageName + "_on"
		var cell = self.filterButtonsCollecionView.cellForItemAtIndexPath(NSIndexPath(forItem: lastSelectedIndex, inSection: 0)) as? FilterCollectionViewCell
		if (cell != nil)
		{
			cell!.iconImageView.image = UIImage(named: imageOn)
		}
		
		lastSelectedIndex = tempIndex
		let tempModel = self.currentFilterModel
		self.currentFilterModel = lastFilterModel
		lastFilterModel = tempModel
		if (self.currentFilterModel.supportsChangingValues())
		{
			self.someSlider.hidden = false
			self.currentFilterModel.inputImage(self.currentCIImage)
			
		}
		else
		{
			self.workingImageView().image = self.workingImage()
			self.someSlider.hidden = true
		}
		let tempSliderValue = self.someSlider.value
		self.someSlider.value = lastSliderValue;
		lastSliderValue = tempSliderValue
		if (self.currentFilterModel.supportsChangingValues())
		{
			sliderValueChanged(self.someSlider)
		}
		
		
		
	}
	
}
