
import Foundation
import CoreImage

class TMCocktailFilter : TMFilterBase{
	override var filtersProtected : [CIFilter] {
		get
		{
			return [CIFilter(name: "CIHueAdjust")]
		}
	}
	
	override init()
	{
		super.init()
		self.iconName = "Cocktail"
	}
	
}
