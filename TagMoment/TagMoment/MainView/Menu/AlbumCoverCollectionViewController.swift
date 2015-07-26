//
//  AlbumCoverCollectionViewController.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 7/27/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit
import AssetsLibrary

let AlbomCoverReuseIndent = "Cell"

class AlbumCoverCollectionViewController: UICollectionViewController {
	var groups : [ALAssetsGroup]!
	var assetsUrls : [ALAssetsGroup : [NSURL]]!
	
	weak var assetLibrary : ALAssetsLibrary!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.collectionView!.registerNib(UINib(nibName: "CameraRollCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: AlbomCoverReuseIndent)
	}
	
	override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return groups != nil ? groups.count : 0
	}
	/* Mark -: CollectionViewDelegation and Datasource */
	override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(AlbomCoverReuseIndent, forIndexPath: indexPath) as! CameraRollCollectionViewCell
		
		let group = groups[indexPath.item]
		let urls = assetsUrls[group]
		
		let url = urls![0]
		assetLibrary.assetForURL(url, resultBlock: { (asset : ALAsset!) -> Void in
			let thumbnail = UIImage(CGImage:asset.thumbnail().takeUnretainedValue())
			cell.imageview.image = thumbnail
			}) { (error : NSError!) -> Void in
				print("There was an error")
		}
		
		cell.albumName.text = group.valueForProperty(ALAssetsGroupPropertyName) as? String
		cell.numberOfPhotos.text = "\(urls!.count)"
		return cell;
		
	}
	
	override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		var albumCont = AlbumContentsCollectionViewController(nibName: "AlbumContentsCollectionViewController", bundle: nil)
		albumCont.assetLibrary = self.assetLibrary
		let group = groups[indexPath.item]
		albumCont.assetsUrls =  assetsUrls[group]
		albumCont.collectionView?.reloadData()
		albumCont.title = group.valueForProperty(ALAssetsGroupPropertyName) as? String
		self.navigationController!.pushViewController(albumCont, animated: true)
	}
	
}
