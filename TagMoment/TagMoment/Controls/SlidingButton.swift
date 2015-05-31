//
//  SlidingButton.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 6/1/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit
enum SlidingButtonSide
{
	case Right
	case Left
}


class SlidingButton: UIView {
	var slidingImage : UIImageView!
	var background : UIImageView!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	func commonInit()
	{
		slidingImage = UIImageView()
		background = UIImageView()
	}
	
	override func intrinsicContentSize() -> CGSize {
		return background!.image!.size
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		background.frame = self.bounds
//		slidingImage.frame = CGRect(
	}
}
