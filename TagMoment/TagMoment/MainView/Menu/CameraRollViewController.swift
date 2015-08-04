//
//  CameraRollViewController.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 6/13/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit
import AssetsLibrary

class CameraRollViewController: UIViewController, UIGestureRecognizerDelegate{
	
	let MinimumHeight : CGFloat = 22
	let VelocityThreshold : CGFloat = 700
	let assetLibrary = ALAssetsLibrary()
	
	var groups : [ALAssetsGroup] = []
	var assetsUrls = [ALAssetsGroup : [NSURL]]()
	
	var heightConstraint : NSLayoutConstraint!
	var minHeight : CGFloat = 0
	var maxHeight : CGFloat = 0
	var originalHeight : CGFloat!
	
	var navCont : UINavigationController!
	@IBOutlet weak var sliderView: UIView!

	let CellReuseIdent = "reuseIdent"
	
    override func viewDidLoad() {
		
        super.viewDidLoad()
		self.view.clipsToBounds = true
		let panRecog = UIPanGestureRecognizer(target: self, action: Selector("sliderDidPan:"))
		panRecog.delegate = self;
		self.sliderView.addGestureRecognizer(panRecog)
		let mainController = UIApplication.sharedApplication().delegate?.window!?.rootViewController! as! MainViewController
		minHeight = mainController.masksViewController.view.frame.height
		maxHeight = mainController.view.frame.height - mainController.infobarHolder.frame.height
		
		prepareNavigation()
		loadImages()
    }
	
	private func prepareNavigation()
	{
		let albumsContainerController = AlbumCoverCollectionViewController(nibName: "AlbumCoverCollectionViewController", bundle: nil)
		navCont = UINavigationController(rootViewController: albumsContainerController)
		navCont.view.frame = CGRect(x: 0, y: -navCont.navigationBar.frame.size.height + CGRectGetHeight(self.sliderView.frame), width: CGRectGetWidth(self.sliderView.frame), height: CGRectGetHeight(self.view.frame) + navCont.navigationBar.frame.size.height - CGRectGetHeight(self.sliderView.frame))
		self.view.addSubview(navCont.view!)
		navCont.navigationBar.barStyle = UIBarStyle.Black
		albumsContainerController.assetLibrary = self.assetLibrary
		albumsContainerController.title = "Phone Albums"
		var albumCont = AlbumContentsCollectionViewController(nibName: "AlbumContentsCollectionViewController", bundle: nil)
		albumCont.assetLibrary = self.assetLibrary
		navCont.pushViewController(albumCont, animated: false)
		navCont.navigationBar.tintColor = UIColor.whiteColor()
		self.view.bringSubviewToFront(self.sliderView)
		
	}
	
	func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
		return self.navCont.viewControllers.count != 1
	}
	
	func sliderDidPan(sender: AnyObject!)
	{
		let panGest = sender as! UIPanGestureRecognizer
		
		switch (panGest.state)
		{
		case .Began:
			if (heightConstraint.constant == self.maxHeight)
			{
				self.hideNavigationBar()
			}
			
			
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
		
		println("velocty y is:  \(velocity.y)")
		let velocityY = abs(velocity.y) > VelocityThreshold ? velocity.y : velocity.y > 0 ? VelocityThreshold : -VelocityThreshold
		let targetHeight = velocity.y > 0 ? minHeight : maxHeight
		let distanceToCover = abs(heightConstraint.constant - targetHeight)
		let duration : NSTimeInterval = NSTimeInterval(abs(distanceToCover/velocityY))
		heightConstraint.constant = targetHeight
		UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
			self.view.superview?.layoutIfNeeded()
			}, completion: { (finished: Bool) -> Void in
				self.originalHeight = self.heightConstraint.constant
				if (targetHeight == self.maxHeight)
				{
					self.showNavigationBar()
				}
		})
		
	}
	
	func showNavigationBar()
	{
		UIView.animateWithDuration(0.2, animations: { () -> Void in
			self.navCont.view.frame = CGRect(x: 0, y: CGRectGetHeight(self.sliderView.frame), width: CGRectGetWidth(self.sliderView.frame), height: CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.sliderView.frame))
		})
	}
	
	func hideNavigationBar()
	{
		UIView.animateWithDuration(0.3, animations: { () -> Void in
			self.navCont.view.frame = CGRect(x: 0, y: -self.navCont.navigationBar.frame.size.height + CGRectGetHeight(self.sliderView.frame), width: CGRectGetWidth(self.sliderView.frame), height: CGRectGetHeight(self.view.frame) + self.navCont.navigationBar.frame.size.height - CGRectGetHeight(self.sliderView.frame))
		})
	}
	
	private func loadImages()
	{
		var maxGroupCount = 0
		ALAssetsLibrary.disableSharedPhotoStreamsSupport()
		assetLibrary.enumerateGroupsWithTypes(ALAssetsGroupAlbum | ALAssetsGroupSavedPhotos, usingBlock: { (assetGroup : ALAssetsGroup!, stop : UnsafeMutablePointer<ObjCBool>) -> Void in
			
			if let group = assetGroup
			{
				var assetsUrlsForGroup = [NSURL]()
				group.enumerateAssetsWithOptions(NSEnumerationOptions.Reverse, usingBlock : { (assetResult : ALAsset!, index: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
					
					if let asset = assetResult
					{
						
						if (asset.valueForProperty(ALAssetPropertyType) as! String == ALAssetTypePhoto)
						{
							
							if let defaultRep = asset.defaultRepresentation()
							{
								assetsUrlsForGroup.append(defaultRep.url())
							}
							
						}
					}
					else
					{
						print("finished")
					}
					
				})
				let groupName = group.valueForProperty(ALAssetsGroupPropertyName) as! String
				println("\(groupName)")
				if (assetsUrlsForGroup.count != 0)
				{
					self.assetsUrls[group] = assetsUrlsForGroup
					self.groups.append(group)
					
					if assetsUrlsForGroup.count > maxGroupCount
					{
						maxGroupCount = assetsUrlsForGroup.count
						let albumCont = self.navCont.topViewController as! AlbumContentsCollectionViewController
						albumCont.assetsUrls = assetsUrlsForGroup
						albumCont.collectionView?.reloadData()
						albumCont.title = groupName
					}
					
					let albumCoversCont = self.navCont.viewControllers[0] as! AlbumCoverCollectionViewController
					albumCoversCont.groups = self.groups
					albumCoversCont.assetsUrls = self.assetsUrls
					albumCoversCont.collectionView?.reloadData()

				}
			}
			
			}) { (error : NSError!) -> Void in
				print("we have an error")
		}
		println("here")
		

	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		self.heightConstraint.constant = originalHeight
		UIView.animateWithDuration(0.3		, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
			self.view.superview?.layoutIfNeeded()
		}, completion: nil)
	}
	
	func addToView(superview : UIView)
	{
		NSNotificationCenter.defaultCenter().postNotificationName(CameraRollWillAppearNotificationName, object: nil)
		superview.pinSubViewToBottom(self.view, heightContraint: 0.0)
		let heightContraint = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 22.0)
		self.view.addConstraint(heightContraint)
		self.heightConstraint = heightContraint
		
	}
	
	func closeView()
	{
		NSNotificationCenter.defaultCenter().postNotificationName(CameraRollWillDisappearNotificationName, object: nil)
		self.heightConstraint.constant = MinimumHeight
		UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
			self.view.superview?.layoutIfNeeded()
			}, completion: { (finished : Bool) -> Void in
				
				self.view.removeFromSuperview()
				self.removeFromParentViewController()
				
		})
	}
}
