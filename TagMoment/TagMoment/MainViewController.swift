//
//  ViewController.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 1/2/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, ChooseMasksControllerDelegate{
	var masksViewController : ChooseMasksViewController!
	var secondImageView : UIImageView!
	
	@IBOutlet weak var canvas: UIImageView!
	@IBOutlet weak var controlContainer: UIView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		masksViewController = ChooseMasksViewController(nibName: "ChooseMasksViewController", bundle: nil)
		controlContainer.pinSubViewToAllEdges(masksViewController.view)
		masksViewController.masksChooseDelegate = self
		canvas.image = UIImage(named: "image1.jpeg")
		secondImageView = UIImageView(image: UIImage(named: "image2.jpeg"))
		canvas.layer.masksToBounds = true
		canvas.pinSubViewToAllEdges(secondImageView)
		
    }
	
	override func viewDidLayoutSubviews() {
		if (secondImageView.layer.mask == nil){
			var maskLayer = CAShapeLayer()
			var bezierMask = TMTraingleMask(rect: canvas.bounds)
			maskLayer.path = bezierMask.clippingPath.CGPath
			secondImageView.layer.mask = maskLayer
			
			
		}

	}
	
	func maskChosen(name: String?) {
		if (name != nil){
			var mask = MaskFactory.maskForName(name!, rect: canvas.bounds)
			var maskLayer = CAShapeLayer()
			maskLayer.path = mask?.clippingPath.CGPath
			secondImageView.layer.mask = maskLayer
		}
	}
	
	
	
}
