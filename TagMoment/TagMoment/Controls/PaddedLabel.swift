//
//  PaddedLabel.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 5/27/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit

class PaddedLabel: UILabel {
	let defaultWidthInset = CGFloat(8)
	let defaultHeightInset = CGFloat(0)
	
	var widthInset : CGFloat?
	var heightInset : CGFloat?
	
	required override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	func commonInit()
	{
		self.textAlignment = NSTextAlignment.Center
	}
	
	override func intrinsicContentSize() -> CGSize {
		self.widthInset = self.widthInset ?? defaultWidthInset
		self.heightInset = self.heightInset ?? defaultHeightInset
		let contentSize = super.intrinsicContentSize()
		return CGSize(width: contentSize.width + self.widthInset!*2, height: contentSize.height + self.heightInset!);
	}
	
}
