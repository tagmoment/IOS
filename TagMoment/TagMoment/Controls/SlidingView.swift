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
	
	func addViewWithConstraints(subview : UIView!, toTheRight : Bool){
		if (subview == nil)
		{
			return;
		}
		
		var xOffset = CGFloat(self.subviews.count)*self.frame.width
		if (!toTheRight)
		{
			xOffset = -xOffset
		}
		leftConstraints.append(self.pinSubViewWithWidth(subview!, leftConstraintVal: xOffset))
		
	}
	
	func animateEnteringView()
	{
		
		
		self.layoutIfNeeded()
		
		UIView.animateWithDuration(1.0, delay: 0,usingSpringWithDamping: 0.6, initialSpringVelocity: 6, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
				for constraint in self.leftConstraints
				{
					let val = constraint.constant - self.frame.width
					constraint.constant = val
				}
				self.layoutIfNeeded()
			}) { (finished: Bool) -> Void in
			
				let subview = self.subviews[0] 
				subview.removeFromSuperview()
				self.leftConstraints.removeAtIndex(0)
		}
	}
	
	func animateExitingView()
	{
		self.layoutIfNeeded()
		
		UIView.animateWithDuration(1.0, delay: 0,usingSpringWithDamping: 0.6, initialSpringVelocity: 6, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
			for constraint in self.leftConstraints
			{
				let val = constraint.constant + self.frame.width
				constraint.constant = val
			}
			self.layoutIfNeeded()
			}) { (finished: Bool) -> Void in
				
				let subview = self.subviews[0] 
				subview.removeFromSuperview()
				self.leftConstraints.removeAtIndex(0)
		}
	}

}
