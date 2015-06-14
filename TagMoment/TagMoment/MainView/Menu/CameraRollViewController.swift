//
//  CameraRollViewController.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 6/13/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit
import AssetsLibrary

class CameraRollViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
	
	
	
	let assetLibrary = ALAssetsLibrary()
	var groups : [ALAssetsGroup] = []
	var assetsUrls : [NSURL!] = []
	
	var heightConstraint : NSLayoutConstraint!
	var minHeight : CGFloat = 0
	var maxHeight : CGFloat = 0
	var originalHeight : CGFloat!
	
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var sliderView: UIView!

	let CellReuseIdent = "reuseIdent"
	
    override func viewDidLoad() {
        super.viewDidLoad()
		collectionView.registerNib(UINib(nibName: "CameraRollCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CellReuseIdent)
		loadImages()
		let panRecog = UIPanGestureRecognizer(target: self, action: Selector("sliderDidPan:"))
		self.sliderView.addGestureRecognizer(panRecog)
		let mainController = UIApplication.sharedApplication().delegate?.window!?.rootViewController! as! MainViewController
		minHeight = mainController.masksViewController.view.frame.height
		maxHeight = mainController.view.frame.height - mainController.infobarHolder.frame.height
    }
	
	func sliderDidPan(sender: AnyObject!)
	{
		let panGest = sender as! UIPanGestureRecognizer
		
		switch (panGest.state)
		{
		case .Changed:
			
			heightConstraint.constant = min(maxHeight, max(minHeight,originalHeight - panGest.translationInView(self.view).y))
			
		case .Ended:
			originalHeight = heightConstraint.constant
			self.endSlidingDrawerMovementWithVelocity(panGest.velocityInView(self.view))
		default:
			println(" \(panGest.state.rawValue)")
		}
	}
	
	private func endSlidingDrawerMovementWithVelocity(velocity : CGPoint)
	{
		
//		println(" \(velocity.y)")
		let targetHeight = velocity.y > 0 ? minHeight : maxHeight
		let distanceToCover = abs(heightConstraint.constant - targetHeight)
		let duration : NSTimeInterval = abs(distanceToCover/velocity.y).native
		heightConstraint.constant = targetHeight
		UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
			self.view.superview?.layoutIfNeeded()
			}, completion: { (finished: Bool) -> Void in
				self.originalHeight = self.heightConstraint.constant
		})
		
	}
	
	private func loadImages()
	{
		assetLibrary.enumerateGroupsWithTypes(ALAssetsGroupAll, usingBlock: { (assetGroup : ALAssetsGroup!, stop : UnsafeMutablePointer<ObjCBool>) -> Void in
			
			if let group = assetGroup
			{
				group.enumerateAssetsUsingBlock({ (assetResult : ALAsset!, index: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
					
					if let asset = assetResult
					{
						if (asset.valueForProperty(ALAssetPropertyType) as! String == ALAssetTypePhoto)
						{
							self.assetsUrls.append(asset.defaultRepresentation().url())
						}
					}
					else
					{
						print("finished")
						self.collectionView.reloadData()
					}
					
				})
				self.groups.append(group)
			}
			
			}) { (error : NSError!) -> Void in
				print("we have an error")
		}
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		let mainController = UIApplication.sharedApplication().delegate?.window!?.rootViewController! as! MainViewController
		originalHeight = mainController.masksViewController.view.frame.height
		self.heightConstraint.constant = originalHeight
		UIView.animateWithDuration(0.3		, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
			self.view.superview?.layoutIfNeeded()
		}, completion: nil)
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return assetsUrls.count
	}
	/* Mark -: CollectionViewDelegation and Datasource */
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellReuseIdent, forIndexPath: indexPath) as! CameraRollCollectionViewCell
		let url = assetsUrls[indexPath.item]
		assetLibrary.assetForURL(url, resultBlock: { (asset : ALAsset!) -> Void in
			let thumbnail = UIImage(CGImage:asset.thumbnail().takeUnretainedValue())
			cell.imageview.image = thumbnail
			}) { (error : NSError!) -> Void in
			print("There was an error")
		}
		return cell;
		
	}
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		let url = assetsUrls[indexPath.item]
		assetLibrary.assetForURL(url, resultBlock: { (asset : ALAsset!) -> Void in
			let rep = asset.defaultRepresentation()
			let fullImage = UIImage(CGImage: rep.fullResolutionImage().takeUnretainedValue(), scale: CGFloat(rep.scale()), orientation: UIImageOrientation(rawValue: rep.orientation().rawValue)! )
//			let fullImage = UIImage(CGImage:asset.defaultRepresentation().fullResolutionImage().takeUnretainedValue())
			NSNotificationCenter.defaultCenter().postNotificationName(ImageFromCameraChosenNotificationName, object: nil, userInfo: [ImageFromCameraNotificationKey : fullImage!])
			}) { (error : NSError!) -> Void in
				print("There was an error")
		}


	}
}
