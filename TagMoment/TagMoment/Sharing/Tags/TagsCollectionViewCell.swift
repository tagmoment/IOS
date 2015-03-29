//
//  TagsCollectionViewCell.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 3/21/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit

class TagsCollectionViewCell: UICollectionViewCell {

	@IBOutlet weak var tagName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.cornerRadius = self.frame.height/2
    }
	
	

}
