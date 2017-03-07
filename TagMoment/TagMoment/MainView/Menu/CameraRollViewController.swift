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
	var assetsUrls = [ALAssetsGroup : [URL]]()
	
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
		let panRecog = UIPanGestureRecognizer(target: self, action: #selector(CameraRollViewController.sliderDidPan(_:)))
		panRecog.delegate = self;
		self.sliderView.addGestureRecognizer(panRecog)
		let mainController = UIApplication.shared.delegate?.window!?.rootViewController! as! MainViewController
		minHeight = mainController.masksViewController.view.frame.height
		maxHeight = mainController.view.frame.height - mainController.infobarHolder.frame.height
		
		prepareNavigation()
		loadImages()
    }
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		GoogleAnalyticsReporter.ReportPageView("Camera Roll View")
		self.heightConstraint.constant = originalHeight
		UIView.animate(withDuration: 0.3		, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
			self.view.superview?.layoutIfNeeded()
			}, completion: nil)
	}

	
	fileprivate func prepareNavigation()
	{
		let albumsContainerController = AlbumCoverCollectionViewController(nibName: "AlbumCoverCollectionViewController", bundle: nil)
		navCont = UINavigationController(rootViewController: albumsContainerController)
		navCont.view.frame = CGRect(x: 0, y: -navCont.navigationBar.frame.size.height + self.sliderView.frame.height, width: self.sliderView.frame.width, height: self.view.frame.height + navCont.navigationBar.frame.size.height - self.sliderView.frame.height)
		self.view.addSubview(navCont.view!)
		navCont.navigationBar.barStyle = UIBarStyle.black
		albumsContainerController.assetLibrary = self.assetLibrary
		albumsContainerController.title = "Phone Albums"
		let albumCont = AlbumContentsCollectionViewController(nibName: "AlbumContentsCollectionViewController", bundle: nil)
		albumCont.assetLibrary = self.assetLibrary
		navCont.pushViewController(albumCont, animated: false)
		navCont.navigationBar.tintColor = UIColor.white
		self.view.bringSubview(toFront: self.sliderView)
		
	}
	
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		return self.navCont.viewControllers.count != 1
	}
	
	func sliderDidPan(_ sender: AnyObject!)
	{
		let panGest = sender as! UIPanGestureRecognizer
		
		switch (panGest.state)
		{
		case .began:
			if (heightConstraint.constant == self.maxHeight)
			{
				self.hideNavigationBar()
			}
			
			
		case .changed:
			
			heightConstraint.constant = min(maxHeight, max(minHeight,originalHeight - panGest.translation(in: self.view).y))
			
		case .ended:
			originalHeight = heightConstraint.constant
			self.endSlidingDrawerMovementWithVelocity(panGest.velocity(in: self.view))
		default:
			print(" \(panGest.state.rawValue)")
		}
	}
	
	fileprivate func endSlidingDrawerMovementWithVelocity(_ velocity : CGPoint)
	{
		
		print("velocty y is:  \(velocity.y)")
		let velocityY = abs(velocity.y) > VelocityThreshold ? velocity.y : velocity.y > 0 ? VelocityThreshold : -VelocityThreshold
		let targetHeight = velocity.y > 0 ? minHeight : maxHeight
		let distanceToCover = abs(heightConstraint.constant - targetHeight)
		let duration : TimeInterval = TimeInterval(abs(distanceToCover/velocityY))
		heightConstraint.constant = targetHeight
		UIView.animate(withDuration: duration, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
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
		UIView.animate(withDuration: 0.2, animations: { () -> Void in
			self.navCont.view.frame = CGRect(x: 0, y: self.sliderView.frame.height, width: self.sliderView.frame.width, height: self.view.frame.height - self.sliderView.frame.height)
		})
	}
	
	func hideNavigationBar()
	{
		UIView.animate(withDuration: 0.3, animations: { () -> Void in
			self.navCont.view.frame = CGRect(x: 0, y: -self.navCont.navigationBar.frame.size.height + self.sliderView.frame.height, width: self.sliderView.frame.width, height: self.view.frame.height + self.navCont.navigationBar.frame.size.height - self.sliderView.frame.height)
		})
	}
	
	fileprivate func loadImages()
	{
		var maxGroupCount = 0
		ALAssetsLibrary.disableSharedPhotoStreamsSupport()
		assetLibrary.enumerateGroupsWithTypes(ALAssetsGroupAlbum | ALAssetsGroupSavedPhotos, usingBlock: { (assetGroup, stop) -> Void in
			
			if let group = assetGroup
			{
				var assetsUrlsForGroup = [URL]()
				group.enumerateAssets(options: NSEnumerationOptions.reverse, using : { (assetResult, index, stop) -> Void in
					
					if let asset = assetResult
					{
						
						if (asset.value(forProperty: ALAssetPropertyType) as! String == ALAssetTypePhoto)
						{
							
							if let defaultRep = asset.defaultRepresentation()
							{
								assetsUrlsForGroup.append(defaultRep.url())
							}
							
						}
					}
					else
					{
						print("finished", terminator: "")
					}
					
				})
				let groupName = group.value(forProperty: ALAssetsGroupPropertyName) as! String
				print("\(groupName)")
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
			
			}) { (error) -> Void in
				print("we have an error", terminator: "")
		}
		print("here")
		

	}
	
	func addToView(_ superview : UIView)
	{
		NotificationCenter.default.post(name: Notification.Name(rawValue: CameraRollWillAppearNotificationName), object: nil)
		_ = superview.pinSubViewToBottom(self.view)
		let heightContraint = NSLayoutConstraint(item: self.view, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: nil, attribute: NSLayoutAttribute.notAnAttribute, multiplier: 1.0, constant: 22.0)
		self.view.addConstraint(heightContraint)
		self.heightConstraint = heightContraint
		
	}
	
	func closeView()
	{
		NotificationCenter.default.post(name: Notification.Name(rawValue: CameraRollWillDisappearNotificationName), object: nil)
		self.heightConstraint.constant = MinimumHeight
		UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveEaseOut, animations: { () -> Void in
			self.view.superview?.layoutIfNeeded()
			}, completion: { (finished : Bool) -> Void in
				
				self.view.removeFromSuperview()
				self.removeFromParentViewController()
				
		})
	}
}
