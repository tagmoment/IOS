//
//  SharingViewController.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 2/22/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit
import Foundation
protocol SharingControllerDelegate : class{
	func taggingKeyboardWillChange(animationTime : Double, endFrame: CGRect)
	func updateUserInfoText(newText : String)
	func textEditingDidEnd()
	func imageForSharing() -> NSURL
	func retakeImageRequested()
	
}

class SharingViewController: UIViewController, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIDocumentInteractionControllerDelegate	{
	
	let CellIdent = "cellIdent"
	let MaxLettersInTag = 15
	let TagsDataSource : [NSString] = ["Love", "Christmas", "Happy", "Birthday", "Mama", "Me", "Whatttt", "Oh no", "try it!"]

	weak var sharingDelegate: SharingControllerDelegate?
	var documentationInteractionController : UIDocumentInteractionController?
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var shareButton: UIButton!
	@IBOutlet weak var saveImageButton: UIButton!
	@IBOutlet weak var buttonsHolder: UIView!
	@IBOutlet weak var tagsHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var tagsCollectionView: UICollectionView!
	
    override func viewDidLoad() {
        super.viewDidLoad()
		self.textField.keyboardType = .ASCIICapable
		var bgImage = shareButton.backgroundImageForState(UIControlState.Normal)
		bgImage = bgImage?.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 46, bottom: 0, right: 0))
		shareButton.setBackgroundImage(bgImage, forState: UIControlState.Normal)
		bgImage = saveImageButton.backgroundImageForState(UIControlState.Normal)
		bgImage = bgImage?.resizableImageWithCapInsets(UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 46))
		saveImageButton.setBackgroundImage(bgImage, forState: UIControlState.Normal)
		tagsCollectionView.registerNib(UINib(nibName: "TagsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CellIdent)
		
    }

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		registerForNotifications()
		prepareSocialButtonsAnimationState()
		
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		animateButtonEntrance()
	}
	
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	private func registerForNotifications()
	{
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboardNotification:", name: UIKeyboardWillChangeFrameNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "textFieldDidChangeText:", name: UITextFieldTextDidChangeNotification, object: nil)
		
	}
	func handleKeyboardNotification(notif: NSNotification)
	{
		let animationTime = notif.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as Double
		let keyboardEndFrame = notif.userInfo?[UIKeyboardFrameEndUserInfoKey] as NSValue
		
		
		if let delegate = self.sharingDelegate
		{
			delegate.taggingKeyboardWillChange(animationTime, endFrame: keyboardEndFrame.CGRectValue())
		}
		if (keyboardEndFrame.CGRectValue().origin.y == UIApplication.sharedApplication().keyWindow?.frame.height)
		{
			var dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(animationTime))
			dispatch_after(dispatchTime, dispatch_get_main_queue(), {
				self.animateButtonEntranceWithPrep()
			})
			
			

		}
	}
	
	// MARK: - Textfield handling
	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		
		
		if (textField.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) >= MaxLettersInTag && !string.isEmpty)
		{
			return false
			
		}else if(string == " ")
		{
			return false
		}
		
		let indices = self.tagsCollectionView.indexPathsForSelectedItems()
		if (indices.count != 0)
		{
			self.tagsCollectionView.deselectItemAtIndexPath(indices[0] as? NSIndexPath, animated: false)
			self.collectionView(self.tagsCollectionView, didDeselectItemAtIndexPath: indices[0] as NSIndexPath)
		}
		
		
		return true
	}
	
	func textFieldDidChangeText(notif: NSNotification)
	{
		if let delegate = self.sharingDelegate
		{
			delegate.updateUserInfoText(textField.text)
		}

	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool
	{
		self.textField.resignFirstResponder()
		return true
	}
	
	
	// MARK: - Animations
	
	func prepareSocialButtonsAnimationState()
	{
		for view in self.buttonsHolder.subviews
		{
			view.layer.transform = CATransform3DMakeScale(0.1, 0.1, 1)
		}
	}
	func animateButtonEntranceWithPrep()
	{
		prepareSocialButtonsAnimationState()
		animateButtonEntrance()
	}
	func animateButtonEntrance()
	{
		var shuffled = self.buttonsHolder.subviews.shuffled()
		for i : Int in 0..<shuffled.count
		{
			let view = shuffled[i] as UIView
			let delay = Double(i)*0.1
			UIView.animateWithDuration(1.0, delay: delay ,usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
				view.layer.transform = CATransform3DIdentity
			}, completion: nil)
			
		}
	}
	// MARK: - Collection view delegation
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
		return TagsDataSource.count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		var cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdent, forIndexPath: indexPath) as TagsCollectionViewCell
		
		
		cell.tagName.text = TagsDataSource[indexPath.item]
		return cell;
		
	}
	func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
		let cell = collectionView.cellForItemAtIndexPath(indexPath) as TagsCollectionViewCell
		cell.backgroundColor = UIColor.blackColor()
		cell.tagName.textColor = UIColor.whiteColor()
	}
	
	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		
		self.textField.text = TagsDataSource[indexPath.item]
		let cell = collectionView.cellForItemAtIndexPath(indexPath) as TagsCollectionViewCell
		cell.backgroundColor = UIColor.whiteColor()
		cell.tagName.textColor = UIColor.blackColor()
		
		if let delegate = self.sharingDelegate
		{
			delegate.updateUserInfoText(TagsDataSource[indexPath.item])
		}
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
	{
		var data = TagsDataSource[indexPath.item]
		let font = UIFont(name: "Giddyup Std", size: 25)
		let attributes : [NSObject : AnyObject!] = [NSFontAttributeName : font]
		
		let size = data.boundingRectWithSize(CGSize(width: 9999, height: 22),
			options: NSStringDrawingOptions.UsesLineFragmentOrigin,
			attributes: attributes,
			context: nil)
	
		
		return CGSize(width: ceil(size.width) + 30, height: 22)
	}
	
	
	
	// MARK: - Buttons Handling
	@IBAction func pinButtonPressed(sender: AnyObject) {
		if let delegate = self.sharingDelegate
		{
			delegate.retakeImageRequested()
		}
	}
	
	@IBAction func shareButtonPressed(sender: AnyObject) {
		
		if let delegate = self.sharingDelegate
		{
			NSNotificationCenter.defaultCenter().removeObserver(self)
			delegate.textEditingDidEnd()
			let url = delegate.imageForSharing()
			documentationInteractionController = UIDocumentInteractionController(URL: url)
			documentationInteractionController?.delegate = self
			documentationInteractionController?.presentOptionsMenuFromRect(self.view.superview!.superview!.bounds, inView: self.view.superview!.superview!, animated: true)
		
		}

	}
	func documentInteractionControllerDidDismissOptionsMenu(controller: UIDocumentInteractionController) {
		registerForNotifications()
	}
	

}
