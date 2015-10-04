
import Foundation
import CoreImage


class TMCoffeeFilter : TMFilterBase{
	override var filtersProtected : [CIFilter] {
		get
		{
			return [CIFilter(name: "CIWhitePointAdjust")!, CIFilter(name: "CIVibrance")!]
		}
	}
	
	override init()
	{
		super.init()
		self.iconName = "Coffee"
	}
	
//	override func applyFilterValue(value: Float) {
//		let color = CIColor(red: CGFloat(value), green:  CGFloat(value), blue:  CGFloat(value), alpha: 1.0)
//		self.filters[0].setValue(color, forKey: kCIInputColorKey)
//		self.filters[0].setValue(value, forKey: kCIInputScaleKey)
////		self.filter.setValue(value, forKey: kCIInputBrightnessKey)
////		self.filter.setValue(value, forKey: kCIInputContrastKey)
//	}
}
