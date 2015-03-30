
import Foundation

struct TMFilterFactory{
	static var filterArray : [TMFilterBase] = [TMFilterBase]()

	static func getFilters() -> [TMFilterBase]{
		if (filterArray.count == 0)
		{
			filterArray.append(TMSunFilter())
			filterArray.append(TMArtistFilter())
			filterArray.append(TMSunsetFilter())
			filterArray.append(TMCocktailFilter())
			filterArray.append(TMCoffeeFilter())
			filterArray.append(TMSurpriseFilter())
			filterArray.append(TMCloudFilter())
			filterArray.append(TMStarFilter())
			filterArray.append(TMVintageFilter())
			filterArray.append(TMTravelFilter())
			filterArray.append(TMFireFilter())
		}
		
		return filterArray
	}
}
