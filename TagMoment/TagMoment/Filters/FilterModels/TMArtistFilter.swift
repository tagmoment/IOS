

import Foundation
import CoreImage

/* Verified with params */
class TMArtistFilter : TMAlphaFilterBase{
	override var filtersProtected : [CIFilter]
	{
		get
		{
			var filters = super.filtersProtected
			filters.insert(CIFilter(name: "CIPhotoEffectTransfer")!, at: 0)
			return filters
		}
	}

	override init()
	{
		super.init()
		self.iconName = "Artist"
		self.displayName = "Concept"
	}
	
}
