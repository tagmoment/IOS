//
//  AlbumCoverCollectionViewLayout.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 7/27/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit

class AlbumCoverCollectionViewLayout: UICollectionViewFlowLayout {
	let borderWidth : CGFloat = 1.0
	
	override init()
	{
		super.init()
		commonInit()
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	fileprivate func commonInit()
	{
		let width = floor(UIScreen.main.bounds.width/2) - borderWidth
		self.itemSize = CGSize(width: width, height: width)
		self.minimumInteritemSpacing = 1.0
		self.minimumLineSpacing = borderWidth
	}
}
