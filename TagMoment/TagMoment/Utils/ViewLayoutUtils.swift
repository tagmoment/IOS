//
//  ViewLayoutUtils.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 1/3/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation
import UIKit
extension UIView{
	func pinSubViewToAllEdges(subview : UIView){
		subview.setTranslatesAutoresizingMaskIntoConstraints(false)
		self.addSubview(subview)
		
		var constraint = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0)
		self.addConstraint(constraint)
		
		constraint = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0)
		self.addConstraint(constraint)
		
		constraint = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0.0)
		self.addConstraint(constraint)
		
		constraint = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0.0)
		self.addConstraint(constraint)
	}
	
	func pinSubViewToTop(subview : UIView, heightContraint : CGFloat){
		subview.setTranslatesAutoresizingMaskIntoConstraints(false)
		self.addSubview(subview)
		
		var constraint = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0)
		self.addConstraint(constraint)
		
		constraint = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0.0)
		self.addConstraint(constraint)
		
		constraint = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0.0)
		self.addConstraint(constraint)
	}
	
	func pinSubViewWithWidth(subview : UIView) -> NSLayoutConstraint {
		return self.pinSubViewWithWidth(subview, leftConstraintVal: 0.0)
	}
	func pinSubViewWithWidth(subview : UIView, leftConstraintVal : CGFloat) -> NSLayoutConstraint {
		subview.setTranslatesAutoresizingMaskIntoConstraints(false)
		self.addSubview(subview)
		
//		var constraint = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0)
//		self.addConstraint(constraint)
//		
		var constraint = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1.0, constant: 0.0)
		self.addConstraint(constraint)
		constraint = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: 0)
		self.addConstraint(constraint)
		constraint = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 1.0, constant: 0)
		self.addConstraint(constraint)

		constraint = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: leftConstraintVal)
		self.addConstraint(constraint)
		
		return constraint
	}
}