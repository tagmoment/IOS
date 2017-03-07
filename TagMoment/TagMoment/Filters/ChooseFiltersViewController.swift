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
	func workingImage(_ mainImage : Bool) -> UIImage
	func workingImageView(_ mainImage : Bool) -> UIImageView
}

class ChooseFiltersViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{

	@IBOutlet weak var filterButtonsCollecionView: UICollectionView!
	@IBOutlet weak var someSlider : UISlider!
	
	@IBOutlet weak var sliderCenterYConstraint : NSLayoutConstraint!
	
	weak var filtersChooseDelegate: ChooseFiltesControllerDelegate?
	
	var currentContext : CIContext!
	var currentFilterModel : TMFilterBase!
	var currentCIImage : CIImage!
	var lastFilterModel : TMFilterBase!
	var lastSelectedIndex : NSInteger = 0
	var lastSliderValue : Float = 0.0
	var persistedIndex = 0
	var persistedSliderValue : Float = 0.0
	var persistedJumperState = false
	
	var sliderValueBefore : Float = 0.0
	@IBOutlet var jumperButton: UIButton!
	var maskViewModel: TMMaskViewModel!
	
	init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, restoreState : Bool) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		if restoreState == true
		{
			self.restorePersistantState()
		}
		
	}

	required init?(coder aDecoder: NSCoder) {
	    super.init(coder: aDecoder)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		filterButtonsCollecionView.register(UINib(nibName: "FilterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CellIdent)
		self.jumperButton.setImage(UIImage(named: maskViewModel.getJumperImageName() + "1"), for: UIControlState())
		if (maskViewModel.hasOneCapture)
		{
			self.jumperButton.isEnabled = false
		}
		else
		{
			self.jumperButton.setImage(UIImage(named: maskViewModel.getJumperImageName() + "2"), for: UIControlState.selected)
		}
		self.applySliderVisuals()
		self.jumperButton.isSelected = self.persistedJumperState
		currentCIImage = CIImage(cgImage: self.workingImage().cgImage!)
		currentContext = CIContext(options:nil)
		
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		GoogleAnalyticsReporter.ReportPageView("Choose Filters View")
		self.filterButtonsCollecionView.selectItem(at: IndexPath(item: self.persistedIndex, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
		self.collectionView(self.filterButtonsCollecionView, didSelectItemAt: IndexPath(item: self.persistedIndex, section: 0))
		if (self.someSlider.value != self.persistedSliderValue)
		{
			self.someSlider.value = self.persistedSliderValue;
			sliderValueChanged(self.someSlider)
		}
		
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
	
	@IBAction func sliderValueChanged(_ sender: AnyObject) {
		let slider : UISlider = sender as! UISlider
		let sliderValue = slider.value
		
		slider.thumbTintColor = UIColor(white: CGFloat (sliderValue*0.7 + 0.3) , alpha: 1.0);
		currentFilterModel.applyFilterValue(sliderValue)
		let outputImage = currentFilterModel.outputImage()
		if (outputImage != nil)
		{
			let cgimg = currentContext.createCGImage(outputImage!, from: (outputImage?.extent)!)
			
			let newImage = UIImage(cgImage: cgimg!, scale: UIScreen.main.scale, orientation: self.workingImage().imageOrientation)
			
			self.workingImageView().image = newImage
		}
		
	}

	fileprivate func isWorkingOnOuterImage() -> Bool
	{
		return !jumperButton.isSelected
	}
	
	func changeJumperSelectionState(toState selected: Bool)
	{
		if (self.jumperButton.isSelected != selected)
		{
			self.jumperButtonPressed(self.jumperButton)
		}
		else
		{
			self.changeSliderValueTo(self.sliderValueBefore)
		}
	}
	
	func changeSliderValueTo(_ value : Float)
	{
		if (value == 0)
		{
			self.sliderValueBefore = self.someSlider.value
			
		}
		
		self.someSlider.value = value
		self.sliderValueChanged(self.someSlider)
	}
	
	@IBAction func jumperButtonPressed(_ sender: AnyObject) {
		self.jumperButton.isSelected = !self.jumperButton.isSelected
		currentCIImage = CIImage(cgImage: self.workingImage().cgImage!)
		currentContext = CIContext(options:nil)
		if (self.lastFilterModel == nil)
		{
			saveCurrentState()
			self.filterButtonsCollecionView.deselectItem(at: IndexPath(item: lastSelectedIndex, section: 0), animated: false)
			self.collectionView(self.filterButtonsCollecionView, didDeselectItemAt: IndexPath(item: lastSelectedIndex, section: 0))
			self.filterButtonsCollecionView.selectItem(at: IndexPath(item: 0, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
			self.collectionView(self.filterButtonsCollecionView, didSelectItemAt: IndexPath(item: 0, section: 0))
		}
		else
		{
			restoreFilterState()
		}
	}
	
	func prepareForSmallScreenLayout()
	{
		self.jumperButton.removeFromSuperview()
		self.sliderCenterYConstraint.constant = 35
	}
	
	/*
	// MARK: - Collection View Delegation
	*/
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return TMFilterFactory.getFilters().count
	}
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		let cell = filterButtonsCollecionView.dequeueReusableCell(withReuseIdentifier: CellIdent, for: indexPath) as! FilterCollectionViewCell
		
		let filterModel = TMFilterFactory.getFilters()[indexPath.item]
		
		let imageName = filterModel.iconName
		let imageOn = imageName + "_on"
		cell.iconImageView.image = UIImage(named: imageOn)
		cell.iconImageView.alpha = cell.isSelected ? 1.0 : 0.3
		cell.filterName.text = filterModel.displayName.lowercased()
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		let filterModel = TMFilterFactory.getFilters()[indexPath.item]
		
		let cell = collectionView.cellForItem(at: indexPath) as? FilterCollectionViewCell
		if (cell != nil)
		{
			cell!.iconImageView.alpha = 1.0
		}

		
		self.currentFilterModel = filterModel
		filterModel.inputImage(self.currentCIImage)
		if (filterModel.supportsChangingValues())
		{
			self.someSlider.isHidden = false
			
		}
		else
		{
			self.workingImageView().image = self.workingImage()
			self.someSlider.isHidden = true
			
		}
		self.someSlider.value = 1.0;
		sliderValueChanged(self.someSlider)
		scrollToMoreVisibleCellsIfNeeded()

	}
	
	
	
	func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		
		let cell = collectionView.cellForItem(at: indexPath)
		
		if (cell != nil)
		{
			let casted = cell as! FilterCollectionViewCell
			casted.iconImageView.alpha = 0.3
		}
		
	}
	
	fileprivate func scrollToMoreVisibleCellsIfNeeded()
	{
		let selected = self.filterButtonsCollecionView.indexPathsForSelectedItems
		var indexPath = selected![0]
		if (indexPath.item == 0)
		{
			self.filterButtonsCollecionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.left, animated: true)
			return;
		}
		else if (indexPath.item == TMFilterFactory.getFilters().count - 1)
		{
			self.filterButtonsCollecionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.right, animated: true)
			return;
		}
		
		let cell = self.filterButtonsCollecionView.cellForItem(at: indexPath)
		if (cell != nil)
		{
			var scrollPos : UICollectionViewScrollPosition
			if (cell!.center.x < (self.filterButtonsCollecionView.contentOffset.x + self.filterButtonsCollecionView.frame.width/2)) //Left side
			{
				indexPath = IndexPath(item: indexPath.item - 1, section: indexPath.section)
				scrollPos = .left
				
			}
			else
			{
				indexPath = IndexPath(item: indexPath.item + 1, section: indexPath.section)
				scrollPos = .right
			}
			
			let cell = self.filterButtonsCollecionView.cellForItem(at: indexPath)
			if (cell == nil)
			{
				self.filterButtonsCollecionView.scrollToItem(at: indexPath, at: scrollPos, animated: true)
				return;
			}
			
			if (cell!.frame.origin.x < self.filterButtonsCollecionView.contentOffset.x) ||
			(cell!.frame.maxX > self.filterButtonsCollecionView.contentOffset.x + self.filterButtonsCollecionView.frame.width)
			{
				self.filterButtonsCollecionView.scrollToItem(at: indexPath, at: scrollPos, animated: true)
			}
		}
	}
	
	fileprivate func applySliderVisuals()
	{
		let minImage = self.sliderImageWithColor(UIColor.white)
		self.someSlider.setMinimumTrackImage(minImage, for: UIControlState())
		let maxImage = self.sliderImageWithColor(UIColor.darkGray)
		self.someSlider.setMaximumTrackImage(maxImage, for: UIControlState())
		self.someSlider.setThumbImage(UIImage(named: "opacity_button_50"), for: UIControlState())
	}
	
	fileprivate func sliderImageWithColor(_ color: UIColor) -> UIImage
	{
		let rect = CGRect(x: 0,y: 0,width: 1,height: 1)
		UIGraphicsBeginImageContextWithOptions(rect.size, false, 0);
		color.setFill()
		UIRectFill(rect);
		let image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		return image!;
	}
	
	func persistState()
	{
		let currentIndex = self.filterButtonsCollecionView.indexPathsForSelectedItems![0].item
		FilterStateRepository.persistFilters((mask: self.maskViewModel, currentIndex: currentIndex, otherIndex: lastSelectedIndex, currentSliderValue: self.someSlider.value, otherSliderValue: self.lastSliderValue, jumperSelected: self.jumperButton.isSelected))
	}
	
	func restorePersistantState()
	{
		let payload = FilterStateRepository.restoreFilters()
		self.maskViewModel = payload.mask
		self.persistedIndex = payload.currentIndex
		self.lastSelectedIndex = payload.otherIndex
		self.persistedSliderValue = payload.currentSliderValue
		self.lastSliderValue = payload.otherSliderValue
		self.persistedJumperState = payload.jumperSelected
		self.lastFilterModel = TMFilterFactory.getFilters()[self.lastSelectedIndex]
	}
	
	func saveCurrentState()
	{
		lastFilterModel = currentFilterModel
		lastSliderValue = self.someSlider.value
		lastSelectedIndex = self.filterButtonsCollecionView.indexPathsForSelectedItems![0].item

	}
	
	func restoreFilterState()
	{
		let tempIndex = self.filterButtonsCollecionView.indexPathsForSelectedItems![0].item
		self.filterButtonsCollecionView.deselectItem(at: IndexPath(item: tempIndex, section: 0), animated: false)
		self.collectionView(self.filterButtonsCollecionView, didDeselectItemAt: IndexPath(item: tempIndex, section: 0))
		self.filterButtonsCollecionView.selectItem(at: IndexPath(item: lastSelectedIndex, section: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
		let filterModel = TMFilterFactory.getFilters()[lastSelectedIndex]
		
		let imageName = filterModel.iconName
		let imageOn = imageName + "_on"
		let cell = self.filterButtonsCollecionView.cellForItem(at: IndexPath(item: lastSelectedIndex, section: 0)) as? FilterCollectionViewCell
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
			self.someSlider.isHidden = false
			self.currentFilterModel.inputImage(self.currentCIImage)
			
		}
		else
		{
			self.workingImageView().image = self.workingImage()
			self.someSlider.isHidden = true
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
