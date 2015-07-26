//
//  CameraRollCollectionViewCell.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 6/13/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit

class CameraRollCollectionViewCell: UICollectionViewCell {
	@IBOutlet weak var imageview: UIImageView!
	
	@IBOutlet weak var albumName: UILabel!
	@IBOutlet weak var numberOfPhotos: UILabel!
	
	var blurredView : UIView!
	var shouldColorSelection = false
	override var selected: Bool {
		didSet {
			if (self.shouldColorSelection)
			{
				if self.selected {
					self.layer.borderColor = UIColor.whiteColor().CGColor
					self.layer.borderWidth = 4
				}
				else
				{
					self.layer.borderColor = UIColor.clearColor().CGColor
					self.layer.borderWidth = 0
				}
			}
			
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		self.blurredView.frame = CGRect(x: 0,y: self.frame.size.height - 40.0, width: self.frame.size.width, height: 40.0)
		self.albumName.frame = self.blurredView.bounds
	}
	
	
	
    override func awakeFromNib() {
        super.awakeFromNib()
		if let theClass: AnyClass = NSClassFromString("UIVisualEffectView") {
			if !UIAccessibilityIsReduceTransparencyEnabled() {
				let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
				let blurview = UIVisualEffectView(effect: blurEffect)
				self.blurredView = blurview
				
				self.blurredView.autoresizingMask = UIViewAutoresizing.None
				
				self.albumName.removeFromSuperview()
				blurview.contentView.addSubview(albumName)
				self.addSubview(blurredView)
				self.bringSubviewToFront(albumName)
			} else {
//				holder.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
			}
		} else {
//			holder.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
		}
    }
	
	

}
