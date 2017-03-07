//
//  Array+Shuffle.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 3/9/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation
extension Collection where Index == Int {
	/// Return a copy of `self` with its elements shuffled
	func shuffle() -> [Iterator.Element] {
		var list = Array(self)
		list.shuffleInPlace()
		return list
	}
}

extension MutableCollection where Index == Int {
	/// Shuffle the elements of `self` in-place.
	mutating func shuffleInPlace() {
		// empty and single-element collections don't shuffle
		if self.count < 2 { return }
		
		for i in startIndex ..< endIndex - 1 {
			let j = Int(arc4random_uniform(UInt32(endIndex - i))) + i
			if i != j {
				swap(&self[i], &self[j])
			}
		}	}
}
