
import Foundation
import CoreImage

class TMExposureAdjustFilter : TMFilterInterface{
	var iconName = "Fire"

	lazy var filter : CIFilter = {
		return CIFilter(name: "CIExposureAdjust")
	}()
	
	func applyFilterValue(value: Float) {
		self.filter.setValue(value, forKey: kCIInputEVKey)
	}
	
	func supportsChangingValues() -> Bool{
		return true;
	}
	
}
