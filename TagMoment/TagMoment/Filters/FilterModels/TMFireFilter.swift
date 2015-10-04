
import Foundation
import CoreImage

class TMFireFilter : TMFilterBase{
	override var filtersProtected : [CIFilter] {
		get
		{
			return [CIFilter(name: "CIExposureAdjust")!]
		}
	}
	
	override init()
	{
		super.init()
		self.iconName = "Fire"
	}
	
}
