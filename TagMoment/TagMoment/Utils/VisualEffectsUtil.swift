//
//  VisualEffectsUtil.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 6/1/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation

class VisualEffectsUtil
{
	static func initBlurredOverLay(effectStyle: UIBlurEffectStyle, toView holder: UIView) -> UIView?
	{
		if let theClass: AnyClass = NSClassFromString("UIVisualEffectView") {
			if !UIAccessibilityIsReduceTransparencyEnabled() {
				let blurEffect = UIBlurEffect(style: effectStyle)
				let blurredView = UIVisualEffectView(effect: blurEffect)
				holder.pinSubViewToAllEdges(blurredView);
				return blurredView
			} else {
				holder.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
			}
		} else {
			holder.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
		}
		
		return nil;
	}
}