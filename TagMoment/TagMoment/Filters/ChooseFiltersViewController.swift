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
	weak var filtersChooseDelegate: ChooseFiltesControllerDelegate?
	
	var currentContext : CIContext!
	var currentFilterModel : TMFilterBase!
	var currentCIImage : CIImage!
	var lastFilterModel : TMFilterBase!
	var lastSelectedIndex : NSInteger = 0
	var lastSliderValue : Float = 0.0
	
	@IBOutlet weak var jumperButton: UIButton!
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
		self.someSlider.setThumbImage(UIImage(named: "opacity_button_50"), forState: .Normal)
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
		var slider : UISlider = sender as UISlider
		let sliderValue = slider.value
		
		slider.thumbTintColor = UIColor(white: CGFloat(sliderValue) , alpha: 1.0);
		
		currentFilterModel.applyFilterValue(sliderValue)
		let outputImage = currentFilterModel.outputImage()
		
		let cgimg = currentContext.createCGImage(outputImage, fromRect: outputImage.extent())
		
		let newImage = UIImage(CGImage: cgimg, scale: UIScreen.mainScreen().scale, orientation: self.workingImage().imageOrientation)
		
		self.workingImageView().image = newImage
	}

	private func isWorkingOnOuterImage() -> Bool
	{
		return !jumperButton.selected
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
	
	/*
	// MARK: - Collection View Delegation
	*/
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return TMFilterFactory.getFilters().count
	}
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		
		var cell = filterButtonsCollecionView.dequeueReusableCellWithReuseIdentifier(CellIdent, forIndexPath: indexPath) as FilterCollectionViewCell
		
		var filterModel = TMFilterFactory.getFilters()[indexPath.item]
		
		var imageName = filterModel.iconName
		var imageOn = imageName + "_on"
		var imageOff = imageName + "_off"
		
		if cell.selected
		{
			cell.iconImageView.image = UIImage(named: imageOn)
		}
		else
		{
			cell.iconImageView.image = UIImage(named: imageOff)
		}
	
		
		return cell
	}
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		
		var filterModel = TMFilterFactory.getFilters()[indexPath.item]
		
		var imageName = filterModel.iconName
		var imageOn = imageName + "_on"
		var cell = collectionView.cellForItemAtIndexPath(indexPath) as? FilterCollectionViewCell
		if (cell != nil)
		{
			cell!.iconImageView.image = UIImage(named: imageOn)
		}

		
		self.currentFilterModel = filterModel
		filterModel.inputImage(self.currentCIImage)
		self.someSlider.value = 0.5;
		sliderValueChanged(self.someSlider)
	}
	
	func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
		var filterModel = TMFilterFactory.getFilters()[indexPath.item]
		
		var imageName = filterModel.iconName
		var imageOff = imageName + "_off"
		
		var cell = collectionView.cellForItemAtIndexPath(indexPath)
		
		if (cell != nil)
		{
			var casted = cell as FilterCollectionViewCell
			casted.iconImageView.image = UIImage(named: imageOff)
		}
		
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
		self.currentFilterModel.inputImage(self.currentCIImage)
		let tempSliderValue = self.someSlider.value
		self.someSlider.value = lastSliderValue;
		lastSliderValue = tempSliderValue
		sliderValueChanged(self.someSlider)
		
	}
	
}
