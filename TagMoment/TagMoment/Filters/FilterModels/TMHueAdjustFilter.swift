
import Foundation
import CoreImage

class TMHueAdjustFilter : TMFilterInterface{
	var iconName = "Cocktail"
	
	lazy var filter : CIFilter = {
		return CIFilter(name: "CIHueAdjust")
	}()
	
	func applyFilterValue(value: Float) {
		self.filter.setValue(value, forKey: kCIInputAngleKey)
	}
	
	func supportsChangingValues() -> Bool{
		return true;
	}
}
