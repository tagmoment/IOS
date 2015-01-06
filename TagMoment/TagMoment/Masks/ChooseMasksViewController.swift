//
//  ChooseMasksViewController.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 1/2/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit


protocol ChooseMasksControllerDelegate : class{
	func maskChosen(name : String?)
}

class ChooseMasksViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
	
	let CellIdent = "CellIdent"

	@IBOutlet weak var masksCollectionView: UICollectionView!
	@IBOutlet weak var takeButton: UIButton!
	
	weak var masksChooseDelegate: ChooseMasksControllerDelegate?
	
	var masksViewModels : [TMMaskViewModel]?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		masksCollectionView.registerNib(UINib(nibName: "MaskCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CellIdent)
		self.masksViewModels = MaskFactory.getViewModels()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
		
	}
	
	
	// MARK: - UICollectionView delegation & datasource
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1;
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.masksViewModels!.count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		var cell : MaskCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdent, forIndexPath: indexPath) as MaskCollectionViewCell
		
		cell.label.text = self.masksViewModels?[indexPath.item].name
		return cell
	}
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		self.masksChooseDelegate?.maskChosen(self.masksViewModels?[indexPath.item].name!)
	}
	
	@IBAction func takeButtonPressed(sender: AnyObject) {
		UIView.animateWithDuration(1.0, animations: { () -> Void in
					self.takeButton.layer.transform = CATransform3DMakeRotation(CGFloat(M_PI), 0, 0, 1)
						//CGAffineTransformMakeRotation(CGFloat(-M_PI*2+0.1))
					}, completion: {(Bool) -> () in
						//self.takeButton.transform = CGAffineTransformIdentity
					}
		)
		
	}
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
