//
//  TMMaskViewModel.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 1/3/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit

class TMMaskViewModel: NSObject, NSCoding {
	var maskProductId = ""
	var locked = false
	var name: String?
	var hasOneCapture : Bool
	
	private let NameKey = "NameKey"
	private let OneCaptureKey = "OneCaptureKey"
	
	required init?(coder aDecoder: NSCoder) {
		if let name = aDecoder.decodeObjectForKey(NameKey) as? String
		{
			self.name = name
		}
		
		self.hasOneCapture = aDecoder.decodeBoolForKey(OneCaptureKey)
	}

	func encodeWithCoder(aCoder: NSCoder) {
		if let name = self.name
		{
			aCoder.encodeObject(name, forKey: NameKey)
			aCoder.encodeBool(hasOneCapture, forKey: OneCaptureKey)
		}
	}
	init(name: String){
		self.name = name
		self.hasOneCapture = false;
	}
	
	func getJumperImageName() -> String {
		return self.name! + "_jumper_"
	}
	
	
}
