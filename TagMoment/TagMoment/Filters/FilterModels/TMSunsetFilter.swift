
import Foundation
import CoreImage

/* Verified with params */
class TMSunsetFilter : TMFilterBase{
	override var filtersProtected : [CIFilter] {
		get
		{
			return [CIFilter(name: "CIGaussianBlur")]
		}
	}
	
	override init()
	{
		super.init()
		self.iconName = "Sunset"
	}
	
}


