

import Foundation
import CoreImage

/* Verified with params */
class TMArtistFilter : TMFilterBase{
	override var filtersProtected : [CIFilter]
	{
		get
		{
			return [CIFilter(name: "CISepiaTone")]
		}
	}

	override init()
	{
		super.init()
		self.iconName = "Artist"
		
	}
	
}
