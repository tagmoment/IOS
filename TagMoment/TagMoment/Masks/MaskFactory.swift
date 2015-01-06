

import UIKit



struct MaskFactory {
	static let MASKS = ["Name it", "u&me", "Flat", "moment", "waves", "xoxo"]
	
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
			case "Name it":
				return TMTraingleMask(rect: rect)
			case "u&me":
				return TMVerticalRectMask(rect: rect)
			case "Flat":
				return TMHorizontalRectMask(rect: rect)
			case "moment":
				return TMCircleMask(rect: rect)
			case "waves":
				return TMWaveMask(rect: rect)
			case "xoxo":
				return TMHeartMask(rect: rect)
			
			default:
				return nil			
		}
		
	}
	
}
