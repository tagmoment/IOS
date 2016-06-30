//
//  VisualEffectsUtil.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 6/1/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation

enum TagMomentBlurEffect : Int{
	
	case ExtraLight
	case Light
	case Dark

}

class VisualEffectsUtil
{
	static func initBlurredOverLay(effectStyle: TagMomentBlurEffect, toView holder: UIView? = nil) -> UIView?
	{
		if !UIAccessibilityIsReduceTransparencyEnabled() {
			let blurEffect = UIBlurEffect(style: UIBlurEffectStyle(rawValue: effectStyle.rawValue)!)
			let blurredView = UIVisualEffectView(effect: blurEffect)
			if let view = holder
			{
				view.pinSubViewToAllEdges(blurredView);
			}
			
			return blurredView
			
		} else if let view = holder{
				
			view.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
		}
		return nil
	}
}