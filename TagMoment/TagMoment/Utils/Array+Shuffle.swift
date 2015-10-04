//
//  Array+Shuffle.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 3/9/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation
extension Array {
	func shuffled() -> [Element] {
		var list = self
		for i in 0..<(list.count - 1) {
			let j = Int(arc4random_uniform(UInt32(list.count - i))) + i
			swap(&list[i], &list[j])
		}
		return list
	}
}