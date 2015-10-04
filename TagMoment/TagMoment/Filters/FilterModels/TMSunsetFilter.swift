
import Foundation
import CoreImage

/* Verified with params */
class TMSunsetFilter : TMFilterBase{
	override var filtersProtected : [CIFilter] {
		get
		{
			return [CIFilter(name: "CIVibrance")!]
		}
	}
	
	override init()
	{
		super.init()
		self.iconName = "Sunset"
		self.displayName = "Chilled"
	}
	
}


