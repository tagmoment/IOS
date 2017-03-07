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
	func pinSubViewToAllEdges(_ subview : UIView){
		subview.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(subview)
		
		var constraint = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0)
		self.addConstraint(constraint)
		
		constraint = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0)
		self.addConstraint(constraint)
		
		constraint = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 0.0)
		self.addConstraint(constraint)
		
		constraint = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: 0.0)
		self.addConstraint(constraint)
	}
	
	func pinSubViewToTop(_ subview : UIView, heightContraint : CGFloat){
		subview.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(subview)
		
		let constraint = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.top, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.top, multiplier: 1.0, constant: 0.0)
		self.addConstraint(constraint)
		
		pinToBothEdges(subview)
	}
	
	func pinSubViewToBottom(_ subview : UIView, heightContraint : CGFloat = 0) -> NSLayoutConstraint{
		subview.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(subview)
		
		let constraint = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: heightContraint)
		self.addConstraint(constraint)
		
		pinToBothEdges(subview)
		return constraint;
	}
	
	fileprivate func pinToBothEdges(_ subview: UIView)
	{
		var constraint = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: 0.0)
		self.addConstraint(constraint)
		
		constraint = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.right, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.right, multiplier: 1.0, constant: 0.0)
		self.addConstraint(constraint)
	}
	
	func pinSubViewWithWidth(_ subview : UIView) -> NSLayoutConstraint {
		return self.pinSubViewWithWidth(subview, leftConstraintVal: 0.0)
	}
	func pinSubViewWithWidth(_ subview : UIView, leftConstraintVal : CGFloat) -> NSLayoutConstraint {
		subview.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(subview)
		
//		var constraint = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.Top, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0.0)
//		self.addConstraint(constraint)
//		
		var constraint = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.bottom, multiplier: 1.0, constant: 0.0)
		self.addConstraint(constraint)
		constraint = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.height, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.height, multiplier: 1.0, constant: 0)
		self.addConstraint(constraint)
		constraint = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.width, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.width, multiplier: 1.0, constant: 0)
		self.addConstraint(constraint)

		constraint = NSLayoutConstraint(item: subview, attribute: NSLayoutAttribute.left, relatedBy: NSLayoutRelation.equal, toItem: self, attribute: NSLayoutAttribute.left, multiplier: 1.0, constant: leftConstraintVal)
		self.addConstraint(constraint)
		
		return constraint
	}
}
