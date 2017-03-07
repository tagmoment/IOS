//
//  CircleRectView.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 6/2/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit

class CircleRectView: UIView {

	var dashedLineColor : UIColor!
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		self.commonInit()
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.commonInit()
	}
	
	func commonInit()
	{
		let borderLayer = CAShapeLayer()
		if (dashedLineColor != nil)
		{
			borderLayer.strokeColor = dashedLineColor.cgColor
		}
		else
		{
			borderLayer.strokeColor = UIColor(red: 255.0/255.0, green: 215.0/255.0, blue: 0/255.0, alpha: 1).cgColor
		}
		
		borderLayer.lineWidth = 3
		borderLayer.fillColor = nil
		borderLayer.lineDashPattern = [20, 4];
		self.layer.addSublayer(borderLayer)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		let borderLayer = self.layer.sublayers![0] as! CAShapeLayer
		if (dashedLineColor != nil)
		{
			borderLayer.strokeColor = dashedLineColor.cgColor
		}
		borderLayer.path = UIBezierPath(ovalIn: self.bounds).cgPath
		borderLayer.frame = self.bounds;
	}
	
	func animateDisappearance()
	{
		let animation = CABasicAnimation(keyPath: "transform.rotation.z")
		animation.toValue = M_PI * 2.0 * 4
		animation.duration = 5.0;
		animation.isCumulative = true;
		animation.repeatCount = HUGE
		self.layer.add(animation, forKey: "rotationAnimation")
		
		UIView.animate(withDuration: 2.0, animations: { () -> Void in
			self.layer.transform = CATransform3DMakeScale(0.3 ,0.3 , 1.0)
			self.alpha = 0.0
				
			}, completion:
			{ (finished: Bool) -> Void in
			self.removeFromSuperview()
		})
		

	}
	
}
