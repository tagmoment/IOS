//
//  AlbumContentsCollectionViewController.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 7/26/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit
import AssetsLibrary

let AlbumContentReuse = "Cell"

class AlbumContentsCollectionViewController: UICollectionViewController {
	var groups : [ALAssetsGroup]!
	var assetsUrls : [NSURL!]!
	weak var assetLibrary : ALAssetsLibrary!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.collectionView!.registerNib(UINib(nibName: "CameraRollCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: AlbumContentReuse)
		
		
		let backButtonImage = UIImage(named:"back_arrow_white");
		let backButton = UIButton(type: UIButtonType.Custom)
		backButton.setImage(backButtonImage, forState: UIControlState.Normal)
		
		backButton.frame = CGRect(x: 0, y: 0, width: backButtonImage!.size.width, height: backButtonImage!.size.height);
		backButton.addTarget(self, action: Selector("popViewController"), forControlEvents: UIControlEvents.TouchUpInside)
		
		let backBarButtonItem = UIBarButtonItem(customView:backButton);
		self.navigationItem.leftBarButtonItem = backBarButtonItem;
    }
	
	func popViewController()
	{
		self.navigationController?.popViewControllerAnimated(true)
	}

	
	/* Mark -: CollectionViewDelegation and Datasource */
	override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return assetsUrls != nil ? assetsUrls.count : 0
	}
	
	override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(AlbumContentReuse, forIndexPath: indexPath) as! CameraRollCollectionViewCell
		let url = assetsUrls[indexPath.item]
		assetLibrary.assetForURL(url, resultBlock: { (asset : ALAsset!) -> Void in
			let thumbnail = UIImage(CGImage:asset.thumbnail().takeUnretainedValue())
			cell.imageview.image = thumbnail
			}) { (error : NSError!) -> Void in
				print("There was an error", terminator: "")
		}
		cell.shouldColorSelection = true
		cell.numberOfPhotos.hidden = true
		if cell.blurredView != nil
		{
			cell.blurredView.hidden = true
		}
		else
		{
			cell.albumName.hidden = true
		}
		
		return cell;
		
	}
	
	override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		let url = assetsUrls[indexPath.item]
		assetLibrary.assetForURL(url, resultBlock: { (asset : ALAsset!) -> Void in
			let rep = asset.defaultRepresentation()
			let fullImage = UIImage(CGImage: rep.fullResolutionImage().takeUnretainedValue(), scale: CGFloat(rep.scale()), orientation: UIImageOrientation(rawValue: rep.orientation().rawValue)! )
			//			let fullImage = UIImage(CGImage:asset.defaultRepresentation().fullResolutionImage().takeUnretainedValue())
			NSNotificationCenter.defaultCenter().postNotificationName(ImageFromCameraChosenNotificationName, object: nil, userInfo: [ImageFromCameraNotificationKey : fullImage])
			}) { (error : NSError!) -> Void in
				print("There was an error", terminator: "")
		}
	}
	
}
