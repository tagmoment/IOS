//
//  SlidingView.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 1/18/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit

class SlidingView: UIView {

	
	var leftConstraints : [NSLayoutConstraint] = []
	
	func addViewWithConstraints(subview : UIView!){
		if (subview == nil)
		{
			return;
		}
		
		var xOffset = CGFloat(self.subviews.count)*self.frame.width
		leftConstraints.append(self.pinSubViewWithWidth(subview!, leftConstraintVal: xOffset))
		
	}
	
	func animateEnteringView()
	{
		
		
		self.layoutIfNeeded()
		
		UIView.animateWithDuration(2.0, delay: 0,usingSpringWithDamping: 0.7, initialSpringVelocity: -0.5, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
				for constraint in self.leftConstraints
				{
					var val = constraint.constant - self.frame.width
					constraint.constant = val
				}
				self.layoutIfNeeded()
			}) { (finished: Bool) -> Void in
			
				var subview = self.subviews[0] as UIView
				subview.removeFromSuperview()
				self.leftConstraints.removeAtIndex(0)
		}
	}

}
