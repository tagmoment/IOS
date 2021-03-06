

import UIKit



struct MaskFactory {
	static var MASKS = ["moment","xoxo", "up", "flat", "diagonal", "u&me", "diamond", "casual", "joy","bubble", "waves", "star"]
		
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
			masks.append(maskForName(name,rect: CGRect.zero)!)
		}
		return masks
	}
	
	static func maskForName(name: String,rect: CGRect) -> TMMask?{
		switch name{
			case "diagonal":
				return TMTraingleMask(rect: rect)
			case "u&me":
				return TMVerticalRectMask(rect: rect)
			case "flat":
				return TMHorizontalRectMask(rect: rect)
			case "moment":
				return TMCircleMask(rect: rect)
			case "waves":
				return TMWaveMask(rect: rect)
			case "xoxo":
				return TMHeartMask(rect: rect)
			case "casual":
				return TMMaskCasual(rect: rect)
			case "joy":
				return TMTopHalfCircleMask(rect: rect)
			case "up":
				return TMBottomHalfCircleMask(rect: rect)
			case "diamond":
				return TMDiamondMask(rect: rect)
			case "star":
				return TMStarMask(rect: rect)
			case "bubble":
				return TMBubbleMask(rect: rect)
			default:
				return nil			
		}
		
	}
	
}
