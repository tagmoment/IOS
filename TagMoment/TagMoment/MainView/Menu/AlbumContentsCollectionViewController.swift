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
	var assetsUrls : [URL?]!
	weak var assetLibrary : ALAssetsLibrary!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		GoogleAnalyticsReporter.ReportPageView("Album Contents View")

		self.collectionView!.register(UINib(nibName: "CameraRollCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: AlbumContentReuse)
		
		
		let backButtonImage = UIImage(named:"back_arrow_white");
		let backButton = UIButton(type: UIButtonType.custom)
		backButton.setImage(backButtonImage, for: UIControlState())
		
		backButton.frame = CGRect(x: 0, y: 0, width: backButtonImage!.size.width, height: backButtonImage!.size.height);
		backButton.addTarget(self, action: #selector(AlbumContentsCollectionViewController.popViewController), for: UIControlEvents.touchUpInside)
		
		let backBarButtonItem = UIBarButtonItem(customView:backButton);
		self.navigationItem.leftBarButtonItem = backBarButtonItem;
    }
	
	func popViewController()
	{
		_ = self.navigationController?.popViewController(animated: true)
	}

	
	/* Mark -: CollectionViewDelegation and Datasource */
	override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return assetsUrls != nil ? assetsUrls.count : 0
	}
	
	override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumContentReuse, for: indexPath) as! CameraRollCollectionViewCell
		let url = assetsUrls[indexPath.item]
		assetLibrary.asset(for: url, resultBlock: { (asset) -> Void in
			let thumbnail = UIImage(cgImage:asset!.thumbnail().takeUnretainedValue())
			cell.imageview.image = thumbnail
			}) { (error) -> Void in
				print("There was an error", terminator: "")
		}
		cell.shouldColorSelection = true
		cell.numberOfPhotos.isHidden = true
		if cell.blurredView != nil
		{
			cell.blurredView.isHidden = true
		}
		else
		{
			cell.albumName.isHidden = true
		}
		
		return cell;
		
	}
	
	override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let url = assetsUrls[indexPath.item]
		assetLibrary.asset(for: url, resultBlock: { (asset) -> Void in
			let rep = asset!.defaultRepresentation()!
			let fullImage = UIImage(cgImage: rep.fullResolutionImage().takeUnretainedValue(), scale: CGFloat(rep.scale()), orientation: UIImageOrientation(rawValue: rep.orientation().rawValue)! )
			//			let fullImage = UIImage(CGImage:asset.defaultRepresentation().fullResolutionImage().takeUnretainedValue())
			NotificationCenter.default.post(name: Notification.Name(rawValue: ImageFromCameraChosenNotificationName), object: nil, userInfo: [ImageFromCameraNotificationKey : fullImage])
			}) { (error) -> Void in
				print("There was an error", terminator: "")
		}
	}
	
}
