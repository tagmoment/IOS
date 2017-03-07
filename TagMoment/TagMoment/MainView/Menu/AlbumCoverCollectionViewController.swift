//
//  AlbumCoverCollectionViewController.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 7/27/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit
import AssetsLibrary

let AlbumCoverReuseIndent = "Cell"

class AlbumCoverCollectionViewController: UICollectionViewController {
	var groups : [ALAssetsGroup]!
	var assetsUrls : [ALAssetsGroup : [URL]]!
	
	weak var assetLibrary : ALAssetsLibrary!
	
	
    override func viewDidLoad() {
        super.viewDidLoad()

		self.collectionView!.register(UINib(nibName: "CameraRollCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: AlbumCoverReuseIndent)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		GoogleAnalyticsReporter.ReportPageView("Album Covers View")

	}
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return groups != nil ? groups.count : 0
	}
	/* Mark -: CollectionViewDelegation and Datasource */
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumCoverReuseIndent, for: indexPath) as! CameraRollCollectionViewCell
		
		let group = groups[indexPath.item]
		let urls = assetsUrls[group]
		
		let url = urls![0]
		assetLibrary.asset(for: url, resultBlock: { (asset) -> Void in
			if (asset != nil && asset!.thumbnail() != nil)
			{
				let thumbnail = UIImage(cgImage:asset!.thumbnail().takeUnretainedValue())
				if (cell.imageview != nil)
				{
					cell.imageview.image = thumbnail
				}
			}
			
			
			}) { (error) -> Void in
				print("There was an error", terminator: "")
		}
		
		cell.albumName.text = group.value(forProperty: ALAssetsGroupPropertyName) as? String
		cell.numberOfPhotos.text = "\(urls!.count)"
		return cell;
		
	}
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let albumCont = AlbumContentsCollectionViewController(nibName: "AlbumContentsCollectionViewController", bundle: nil)
		albumCont.assetLibrary = self.assetLibrary
		let group = groups[indexPath.item]
		albumCont.assetsUrls =  assetsUrls[group]
		albumCont.collectionView?.reloadData()
		albumCont.title = group.value(forProperty: ALAssetsGroupPropertyName) as? String
		self.navigationController!.pushViewController(albumCont, animated: true)
	}
	
}
