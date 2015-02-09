

import Foundation
import CoreImage

class TMSepiaToneFilter : TMFilterInterface{
	var iconName = "Artist"
	
	lazy var filter : CIFilter = {
		return CIFilter(name: "CISepiaTone")
	}()
	
	func applyFilterValue(value: Float) {
		self.filter.setValue(value, forKey: kCIInputIntensityKey)
	}
	
	func supportsChangingValues() -> Bool{
		return true;
	}
}
