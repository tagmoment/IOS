//
//  ChooseFiltersViewController.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 1/15/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit

let FilterNames = ["Artist", "Classic", "cloud", "Cocktail", "Coffee", "Fire", "Gamer", "Love", "Music", "Star", "Sun", "Sunset", "Surprise"]

let CellIdent = "CellIdentifier"

class ChooseFiltersViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource{

	@IBOutlet weak var filterButtonsCollecionView: UICollectionView!
	@IBOutlet weak var someSlider : UISlider!
	weak var workingImageView : UIImageView!
	
	var currentContext : CIContext!
	var currentFilter : CIFilter!
	var currentCIImage : CIImage!
	
	@IBOutlet weak var jumperButton: UIButton!
	var maskViewModel: TMMaskViewModel!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		filterButtonsCollecionView.registerNib(UINib(nibName: "FilterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CellIdent)
		self.jumperButton.setImage(UIImage(named: maskViewModel.getJumperImageName() + "1"), forState: UIControlState.Normal)
		self.jumperButton.setImage(UIImage(named: maskViewModel.getJumperImageName() + "2"), forState: UIControlState.Selected)
		currentFilter = CIFilter(name: "CISepiaTone")
		let image = workingImageView.image?.CIImage;
		currentFilter.setValue(CIImage(CGImage: workingImageView.image?.CGImage), forKey: kCIInputImageKey)
		currentFilter.setValue(0.5, forKey: kCIInputIntensityKey)
		currentContext = CIContext(options:nil)
		let outputImage = currentFilter.outputImage
		let cgimg = currentContext.createCGImage(outputImage, fromRect: outputImage.extent())
		
		let newImage = UIImage(CGImage: cgimg)
		self.workingImageView.image = newImage
	}
	
	
	@IBAction func sliderValueChanged(sender: AnyObject) {
		var slider : UISlider = sender as UISlider
		let sliderValue = slider.value
		
		currentFilter.setValue(sliderValue, forKey: kCIInputIntensityKey)
		let outputImage = currentFilter.outputImage
		
		let cgimg = currentContext.createCGImage(outputImage, fromRect: outputImage.extent())
		
		let newImage = UIImage(CGImage: cgimg)
		self.workingImageView.image = newImage
	}

	
	@IBAction func jumperButtonPressed(sender: AnyObject) {
		self.jumperButton.selected = !self.jumperButton.selected
	}
	/*
	// MARK: - Collection View Delegation
	*/
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return FilterNames.count
	}
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		
		var cell = filterButtonsCollecionView.dequeueReusableCellWithReuseIdentifier(CellIdent, forIndexPath: indexPath) as FilterCollectionViewCell
		
		var imageName = FilterNames[indexPath.item]
		var imageOn = imageName + "_on"
		var imageOff = imageName + "_off"
		
		cell.iconImageView.image = UIImage(named: imageOff)
		cell.iconImageView.highlightedImage = UIImage(named: imageOn)
		
		return cell
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
