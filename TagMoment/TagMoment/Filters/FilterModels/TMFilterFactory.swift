
import Foundation

struct TMFilterFactory{
	static var filterArray : [TMFilterBase] = [TMFilterBase]()

	static func getFilters() -> [TMFilterBase]{
		if (filterArray.count == 0)
		{
			filterArray.append(TMSunFilter())
			filterArray.append(TMSunsetFilter())
			filterArray.append(TMArtistFilter())
			filterArray.append(TMMusicFilter())
			filterArray.append(TMLoveFilter())
			filterArray.append(TMVintageFilter())
			filterArray.append(TMStarFilter())
			filterArray.append(TMCocktailFilter())
			filterArray.append(TMGamerFilter())
			filterArray.append(TMTravelFilter())
//			filterArray.append(TMCoffeeFilter())
//			filterArray.append(TMSurpriseFilter())
//			filterArray.append(TMCloudFilter())
//			
//			
//			filterArray.append(TMFireFilter())
		}
		
		return filterArray
	}
}
