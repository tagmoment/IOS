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
	
    override func viewDidLoad() {
        super.viewDidLoad()
		filterButtonsCollecionView.registerNib(UINib(nibName: "FilterCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CellIdent)
		
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
	
	/*
	// MARK: - Collection View Delegatioin
	*/
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return FilterNames.count
	}
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		
		var cell = filterButtonsCollecionView.dequeueReusableCellWithReuseIdentifier(CellIdent, forIndexPath: indexPath) as FilterCollectionViewCell
		
		var imageName = FilterNames[indexPath.item]
		var imageOn = imageName + "_On"
		var imageOff = imageName + "_Off"
		
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
