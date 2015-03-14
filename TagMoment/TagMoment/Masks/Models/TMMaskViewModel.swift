//
//  TMMaskViewModel.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 1/3/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit

class TMMaskViewModel: NSObject {
	var name: String?
	var hasOneCapture : Bool
	
	init(name: String){
		self.name = name
		self.hasOneCapture = false;
	}
	
	func getJumperImageName() -> String {
		return self.name! + "_jumper_"
	}
	
	
}
