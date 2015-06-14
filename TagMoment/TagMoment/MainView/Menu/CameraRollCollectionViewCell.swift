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

	override var selected: Bool {
		didSet {
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
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
	
	

}
