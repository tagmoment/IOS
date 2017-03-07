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
	override var isSelected: Bool {
		didSet {
			if (self.shouldColorSelection)
			{
				if self.isSelected {
					self.layer.borderColor = UIColor.white.cgColor
					self.layer.borderWidth = 4
				}
				else
				{
					self.layer.borderColor = UIColor.clear.cgColor
					self.layer.borderWidth = 0
				}
			}
			
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		if self.blurredView != nil
		{
			self.blurredView.frame = CGRect(x: 0,y: self.frame.size.height - 40.0, width: self.frame.size.width, height: 40.0)
			self.albumName.frame = self.blurredView.bounds

		}
			}
	
	
	
    override func awakeFromNib() {
        super.awakeFromNib()
		if let blurView = VisualEffectsUtil.initBlurredOverLay(TagMomentBlurEffect.dark) as? UIVisualEffectView
		{
			self.blurredView = blurView
			self.blurredView.autoresizingMask = UIViewAutoresizing()
    			
			self.albumName.removeFromSuperview()
			blurView.contentView.addSubview(albumName)
			self.addSubview(blurredView)
			self.bringSubview(toFront: albumName)
    
		}
	}
}
