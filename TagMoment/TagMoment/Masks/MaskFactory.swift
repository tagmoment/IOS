

import UIKit



struct MaskFactory {
	static let MASKS = ["nameit", "uandme", "Flat", "moment", "waves", "xoxo", "casual"]
	
	static func getViewModels() -> [TMMaskViewModel]
	{
		var masksViewModels = [TMMaskViewModel]()
		for mask in getMasks()
		{
			masksViewModels.append(mask.createViewModel())
		}
		
		return masksViewModels
	}
	
	static func getMasks() -> [TMMask]{
		
		var masks = [TMMask]()
		for name in MASKS{
			masks.append(maskForName(name, rect: CGRect.zeroRect)!)
		}
		return masks
	}
	
	static func maskForName(name: String, rect: CGRect) -> TMMask?{
		switch name{
			case "nameit":
				return TMTraingleMask(rect: rect)
			case "uandme":
				return TMVerticalRectMask(rect: rect)
			case "Flat":
				return TMHorizontalRectMask(rect: rect)
			case "moment":
				return TMCircleMask(rect: rect)
			case "waves":
				return TMWaveMask(rect: rect)
			case "xoxo":
				return TMHeartMask(rect: rect)
			case "casual":
				return TMMaskCasual(rect: rect)
			default:
				return nil			
		}
		
	}
	
}
