//
//  ChooseFiltersViewController.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 1/15/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit


let CellIdent = "CellIdentifier"

class ChooseFiltersViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{

	@IBOutlet weak var filterButtonsCollecionView: UICollectionView!
	@IBOutlet weak var someSlider : UISlider!
	weak var workingImageView : UIImageView!
	
	var currentContext : CIContext!
	var currentFilterModel : TMFilterInterface!
	var currentCIImage : CIImage!
	
	@IBOutlet weak var jumperButton: UIButton!
	var maskViewModel: TMMaskViewModel!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		filterButtonsCollecionView.registerNib(UINib(nibName: "FilterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CellIdent)
		self.jumperButton.setImage(UIImage(named: maskViewModel.getJumperImageName() + "1"), forState: UIControlState.Normal)
		self.jumperButton.setImage(UIImage(named: maskViewModel.getJumperImageName() + "2"), forState: UIControlState.Selected)
		
		
		currentCIImage = CIImage(CGImage: workingImageView.image?.CGImage)
		currentContext = CIContext(options:nil)
		self.filterButtonsCollecionView.selectItemAtIndexPath(NSIndexPath(forItem: 0, inSection: 0), animated: false, scrollPosition: UICollectionViewScrollPosition.CenteredHorizontally)
		self.collectionView(self.filterButtonsCollecionView, didSelectItemAtIndexPath: NSIndexPath(forItem: 0, inSection: 0))
		
		
	}
	
	
	@IBAction func sliderValueChanged(sender: AnyObject) {
		var slider : UISlider = sender as UISlider
		let sliderValue = slider.value
		
		slider.thumbTintColor = UIColor(white: CGFloat(sliderValue) , alpha: 1.0);
		
		currentFilterModel.applyFilterValue(sliderValue)
		let outputImage = currentFilterModel.filter.outputImage
		
		let cgimg = currentContext.createCGImage(outputImage, fromRect: outputImage.extent())
		
		let newImage = UIImage(CGImage: cgimg, scale: UIScreen.mainScreen().scale, orientation: self.workingImageView.image!.imageOrientation)
		self.workingImageView.image = newImage
	}

	
	@IBAction func jumperButtonPressed(sender: AnyObject) {
		self.jumperButton.selected = !self.jumperButton.selected
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
		
		cell.iconImageView.image = UIImage(named: imageOff)
		cell.iconImageView.highlightedImage = UIImage(named: imageOn)
		
		return cell
	}
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		
		var filterModel = TMFilterFactory.getFilters()[indexPath.item]
		
		self.currentFilterModel = filterModel
		self.currentFilterModel.filter.setValue(self.currentCIImage, forKey: kCIInputImageKey)
		self.someSlider.value = 0.5;
		sliderValueChanged(self.someSlider)
	}
	
	
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
