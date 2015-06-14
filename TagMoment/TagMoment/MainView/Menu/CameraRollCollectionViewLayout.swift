//
//  CameraRollCollectionViewLayout.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 6/13/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit

class CameraRollCollectionViewLayout: UICollectionViewFlowLayout {
	
	let borderWidth : CGFloat = 2.0
	
	override init()
	{
		super.init()
		commonInit()
	}
	
	required init(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	private func commonInit()
	{
		let width = UIScreen.mainScreen().bounds.width/3 - CGFloat(2*borderWidth)
		self.itemSize = CGSize(width: width, height: width)
		self.minimumInteritemSpacing = borderWidth
		self.minimumLineSpacing = borderWidth
	}
	
	
}
