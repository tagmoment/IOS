
import Foundation
import CoreImage

class TMColorControlsFilter : TMFilterInterface{
	var iconName = "Coffee"
	
	lazy var filter : CIFilter = {
		return CIFilter(name: "CIColorControls")
	}()
	
	func applyFilterValue(value: Float) {
		self.filter.setValue(value, forKey: kCIInputSaturationKey)
//		self.filter.setValue(value, forKey: kCIInputBrightnessKey)
//		self.filter.setValue(value, forKey: kCIInputContrastKey)
	}
	
	func supportsChangingValues() -> Bool{
		return true;
	}
}
