//
//  CollectionViewCell.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 1/3/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit

class MaskCollectionViewCell: UICollectionViewCell {


	@IBOutlet weak var labelHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var maskImage: UIImageView!
	
	@IBOutlet weak var maskName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
	
	override var highlighted: Bool {
		willSet(newValue) {
			if newValue
			{
				self.alpha = 1.0
			}
			else
			{
				self.alpha = 0.4
			}
		}
	}

}
