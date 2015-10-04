
import Foundation
import CoreImage

class TMCocktailFilter : TMAlphaFilterBase{
	override var filtersProtected : [CIFilter] {
		get
		{
			var filters = super.filtersProtected
			filters.insert(CIFilter(name: "CIPhotoEffectProcess")!, atIndex: 0)
			return filters
		}
	}
	
	override init()
	{
		super.init()
		self.iconName = "Cocktail"
		self.displayName = "Cocktail"
	}
	

}
