
import Foundation

struct TMFilterFactory{
	static var filterArray : [TMFilterInterface] = [TMFilterInterface]()

	static func getFilters() -> [TMFilterInterface]{
		if (filterArray.count == 0)
		{
			filterArray.append(TMSepiaToneFilter())
			filterArray.append(TMGaussianBlurFilter())
			filterArray.append(TMHueAdjustFilter())
			filterArray.append(TMColorControlsFilter())
			filterArray.append(TMExposureAdjustFilter())
			filterArray.append(TMLinearToSRGBToneCurveFilter())
			filterArray.append(TMColorInvertFilter())
			filterArray.append(TMPhotoEffectMonoFilter())
			filterArray.append(TMComicEffectFilter())
			filterArray.append(TMBloomFilter())
//			filterArray.append(TMCrystallizeFilter())
//			filterArray.append(TMEdgesFilter())
			filterArray.append(TMPixellateFilter())
		}
		
		return filterArray
	}
}
