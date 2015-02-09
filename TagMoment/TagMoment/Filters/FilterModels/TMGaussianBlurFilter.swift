
import Foundation
import CoreImage

class TMGaussianBlurFilter : TMFilterInterface{
	var iconName = "cloud"
	
	lazy var filter : CIFilter = {
		return CIFilter(name: "CIGaussianBlur")
	}()
	
	func applyFilterValue(value: Float) {
		self.filter.setValue(value*100, forKey: kCIInputRadiusKey)
	}
	
	func supportsChangingValues() -> Bool{
		return true;
	}
}


