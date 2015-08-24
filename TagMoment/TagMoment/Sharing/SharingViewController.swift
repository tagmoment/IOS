//
//  SharingViewController.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 2/22/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit
import Foundation
import Social
protocol SharingControllerDelegate : class{
	func taggingKeyboardWillChange(animationTime : Double, endFrame: CGRect)
	func updateUserInfoText(newText : String)
	func textEditingDidEnd()
	func imageForSharing() -> NSURL
	func imageForCaching() -> UIImage
	func retakeImageRequested()
	
	
}

class SharingViewController: UIViewController, TMTextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIDocumentInteractionControllerDelegate	{
	
	let ClosedContraint = CGFloat(-100)
	let CellIdent = "cellIdent"
	let MaxLettersInTag = 15
	
	
//	Left out side
//	
	
	var tagsDataSource : [NSString]!
	var autoKeyboardWasOn = false
	var keyboardWasShown = false
	weak var sharingDelegate: SharingControllerDelegate?
	var documentationInteractionController : UIDocumentInteractionController?
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var shareButton: UIButton!
	@IBOutlet weak var saveButtonBG: UIButton!
	@IBOutlet weak var saveImageButton: UIButton!
	@IBOutlet weak var buttonsHolder: UIView!
	@IBOutlet weak var shareButtonBG: UIButton!
	@IBOutlet weak var tagsHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var tagsCollectionView: UICollectionView!
	
	@IBOutlet weak var saveBGConstraint: NSLayoutConstraint!
	@IBOutlet weak var shareBGConstraint: NSLayoutConstraint!
	
	var chosenEmojiIndex : NSIndexPath?
	var chosenWordIndex : NSIndexPath?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		tagsDataSource = self.sortDataSource(TagTextProvider.TagsDataSourceWords, emojis: TagTextProvider.emojisContainer)
		self.textField.keyboardType = .ASCIICapable
		tagsCollectionView.registerNib(UINib(nibName: "TagsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CellIdent)
		tagsCollectionView.allowsMultipleSelection = true
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
		let animationTime = notif.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
		let keyboardEndFrame = notif.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue
		
		
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
		
		
		if let range = string.rangeOfCharacterFromSet(NSCharacterSet.whitespaceCharacterSet())
		{
			return false
		}
		
		let MaxLettersAllowed = TagTextProvider.currentEmoji != nil ? MaxLettersInTag + 2 : MaxLettersInTag
		
		if (count(textField.text) >= MaxLettersAllowed && !string.isEmpty && TagTextProvider.currentWord == nil)
		{
			return false
			
		}else if(string == " ")
		{
			if autoKeyboardWasOn == true
			{
				autoKeyboardWasOn = false
				notifyDelegateOnChangedText()
			}
			return false
		}
		
		if (string.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) > 1)
		{
			autoKeyboardWasOn = true
		}
		
		if !string.isEmpty
		{
			notifyDelegateOnChangedText(input: string)
		}
		
		
		if (self.chosenWordIndex != nil && !string.isEmpty)
		{
			self.tagsCollectionView.deselectItemAtIndexPath(self.chosenWordIndex, animated: true)
			self.collectionView(self.tagsCollectionView, didDeselectItemAtIndexPath: self.chosenWordIndex!)
			self.chosenWordIndex = nil
			
			
		}
		
		return string.isEmpty
	}
	
	func textFieldDidChangeText(notif: NSNotification)
	{
		notifyDelegateOnChangedText()
	}
	
	func deleteBackwardsDetected() {
		if (TagTextProvider.isCurrentCharSetSecondWord(TagTextProvider.currentEmoji))
		{
			self.tagsCollectionView.deselectItemAtIndexPath(self.chosenEmojiIndex, animated: true)
			self.collectionView(self.tagsCollectionView, didDeselectItemAtIndexPath: self.chosenEmojiIndex!)
			self.chosenEmojiIndex = nil
			TagTextProvider.currentEmoji = nil
			return;
		}
		
		if (TagTextProvider.isCurrentCharSetSecondWord(TagTextProvider.currentWord))
		{
			self.tagsCollectionView.deselectItemAtIndexPath(self.chosenWordIndex, animated: true)
			self.collectionView(self.tagsCollectionView, didDeselectItemAtIndexPath: self.chosenWordIndex!)
			self.chosenWordIndex = nil
			//					TagTextProvider.currentWord = nil
			return;
		}
		
	}
	
	func notifyDelegateOnChangedText(input : String = "")
	{
		if let delegate = self.sharingDelegate
		{
			var returnVal = input
			if (returnVal.isEmpty)
			{
				textField.text = textField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
				returnVal = textField.text
				TagTextProvider.handleDeletion()
				TagTextProvider.currentString = returnVal.isEmpty ? nil : returnVal
			}
			else
			{
				returnVal = TagTextProvider.addTextByRules(input)
				textField.text = returnVal
			}
			
			delegate.updateUserInfoText(TagTextProvider.addAllHashtags(returnVal))
		}
	}
	
	func textFieldShouldReturn(textField: UITextField) -> Bool
	{
		self.textField.resignFirstResponder()
		return true
	}
	
	func textFieldShouldClear(textField: UITextField) -> Bool
	{
		deselectItems()
		self.chosenWordIndex = nil
		TagTextProvider.currentWord = nil
		self.chosenEmojiIndex = nil
		TagTextProvider.currentEmoji = nil
		TagTextProvider.currentTyping = nil
			
		
		return true
	}
	
	func deselectItems()
	{
		let indices = self.tagsCollectionView.indexPathsForSelectedItems()
		if indices.count != 0
		{
			if let indicesArray = indices as? [NSIndexPath]
			{
				for indexPath in indicesArray
				{
					self.tagsCollectionView.deselectItemAtIndexPath(indexPath, animated: true)
					self.collectionView(self.tagsCollectionView, didDeselectItemAtIndexPath: indexPath)
				}
			}
			
			
		}
	}
	
	func prepareForSmallScreenLayout()
	{
		let newButtonsHolder = NSBundle.mainBundle().loadNibNamed("SmallScreenSharingButtonsView", owner: nil, options: nil)[0] as! UIView
		
		
		self.buttonsHolder.removeFromSuperview()
		newButtonsHolder.setTranslatesAutoresizingMaskIntoConstraints(false)
		self.view.addSubview(newButtonsHolder)
		self.buttonsHolder = newButtonsHolder
		var constraint = NSLayoutConstraint(item: newButtonsHolder, attribute: NSLayoutAttribute.Bottom, relatedBy: NSLayoutRelation.Equal, toItem: self.shareButton, attribute: NSLayoutAttribute.Top, multiplier: 1.0, constant: 0)
		self.view.addConstraint(constraint)
		constraint = NSLayoutConstraint(item: newButtonsHolder, attribute: NSLayoutAttribute.Left, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Left, multiplier: 1.0, constant: 0)
		self.view.addConstraint(constraint)
		constraint = NSLayoutConstraint(item: newButtonsHolder, attribute: NSLayoutAttribute.Right, relatedBy: NSLayoutRelation.Equal, toItem: self.view, attribute: NSLayoutAttribute.Right, multiplier: 1.0, constant: 0)
		self.view.addConstraint(constraint)
		constraint = NSLayoutConstraint(item: newButtonsHolder, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 72)
		self.view.addConstraint(constraint)
		
	}
	
	// MARK: - Animations
	
	func prepareSocialButtonsAnimationState()
	{
		for view in self.buttonsHolder.subviews as! [UIView]
		{
			view.layer.transform = CATransform3DMakeScale(0.01, 0.01, 1)
			view.hidden = true
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
			let view = shuffled[i] as! UIView
			let delay = Double(i)*0.1
			view.hidden = false
			UIView.animateWithDuration(0.5, delay: delay ,usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
				view.layer.transform = CATransform3DIdentity
				}, completion: { (finished: Bool) -> Void in
					if !self.keyboardWasShown
					{
						self.keyboardWasShown = true
						self.textField.becomeFirstResponder()
					}
			})
			
		}
	}
	// MARK: - Collection view delegation
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
		return tagsDataSource.count
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		
		
		var cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdent, forIndexPath: indexPath) as! TagsCollectionViewCell
		let selectedIndices = collectionView.indexPathsForSelectedItems()
		var found = false
		for index in selectedIndices as! [NSIndexPath]
		{
			if (index.row == indexPath.row)
			{
				found = true
				break;
			}
			
		}
		
		if (found)
		{
			cell.backgroundColor = UIColor.whiteColor()
			cell.tagName.textColor = UIColor.blackColor()
		}
		else
		{
			cell.backgroundColor = UIColor.blackColor()
			cell.tagName.textColor = UIColor.whiteColor()
		}
		
		
		cell.tagName.text = tagsDataSource[indexPath.item] as String
		return cell;
		
	}
	
	func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
		let cell = collectionView.cellForItemAtIndexPath(indexPath)
		if let tagCell = cell as? TagsCollectionViewCell
		{
			let string = tagsDataSource[indexPath.item]
			let isWord = indexPath.item % 2 == 0 ? true : false
			if (self.chosenWordIndex != nil && isWord)
			{
				self.tagsCollectionView.deselectItemAtIndexPath(self.chosenWordIndex, animated: true)
				self.collectionView(self.tagsCollectionView, didDeselectItemAtIndexPath: self.chosenWordIndex!)
			}
			
			if (self.chosenEmojiIndex != nil && !isWord)
			{
				self.tagsCollectionView.deselectItemAtIndexPath(self.chosenEmojiIndex, animated: true)
				self.collectionView(self.tagsCollectionView, didDeselectItemAtIndexPath: self.chosenEmojiIndex!)
			}
			
			self.chosenWordIndex = isWord ? indexPath : self.chosenWordIndex
			self.chosenEmojiIndex = !isWord ? indexPath : self.chosenEmojiIndex
		}
		
		return true
	}
	
	func collectionView(collectionView: UICollectionView, shouldDeselectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
		var result = true
		if let emojiIndexPath = self.chosenEmojiIndex
		{
			result = result && !(emojiIndexPath.item == indexPath.item)
		}
		
		if let wordIndexPath = self.chosenWordIndex
		{
			result = result && !(wordIndexPath.item == indexPath.item)
		}
		
		return result;
	}
	
	func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
		let cell = collectionView.cellForItemAtIndexPath(indexPath)
		if let tagCell = cell as? TagsCollectionViewCell
		{
			var result = NSAttributedString()
			NSFontAttributeName
			tagCell.backgroundColor = UIColor.blackColor()
			tagCell.tagName.textColor = UIColor.whiteColor()
		}
	}

	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		
		let cell = collectionView.cellForItemAtIndexPath(indexPath) as! TagsCollectionViewCell
		cell.backgroundColor = UIColor.whiteColor()
		cell.tagName.textColor = UIColor.blackColor()
		
		if let delegate = self.sharingDelegate
		{
			notifyDelegateOnChangedText(input: tagsDataSource[indexPath.item] as String)
		}
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
	{
		var data = tagsDataSource[indexPath.item]
		let font = UIFont(name: "Raleway", size: 17)
		let attributes : [NSObject : AnyObject!] = [NSFontAttributeName : font]
		
		let size = data.boundingRectWithSize(CGSize(width: 9999, height: 26),
			options: NSStringDrawingOptions.UsesLineFragmentOrigin,
			attributes: attributes,
			context: nil)
	
		
		return CGSize(width: ceil(size.width) + 34, height: 34)
	}
	
	
	
	// MARK: - Buttons Handling
	@IBAction func shareButtonPressed(sender: AnyObject) {
		
		if isShareButtonOpen()
		{
			if let delegate = self.sharingDelegate
			{
				NSNotificationCenter.defaultCenter().removeObserver(self)
				delegate.textEditingDidEnd()
				let url = delegate.imageForSharing()
				documentationInteractionController = UIDocumentInteractionController(URL: url)
				documentationInteractionController?.delegate = self
				documentationInteractionController?.presentOptionsMenuFromRect(self.view.superview!.superview!.bounds, inView: self.view.superview!.superview!, animated: true)
				
			}
			return;
		}
		
//		toggleShareButtonBgAnimation()
		
	}
	
	
	@IBAction func pinButtonPressed(sender: AnyObject) {
		
		if isSaveButtonOpen()
		{
			if let delegate = self.sharingDelegate
			{
				delegate.retakeImageRequested()
				
			}
			return;
		}
		
//		toggleSaveButtonBgAnimation()
		
		
		
	}
	
//	private func toggleSaveButtonBgAnimation()
//	{
//		let title = isSaveButtonOpen() ? "" : "Keep It"
//		self.saveBGConstraint.constant = isSaveButtonOpen() ? ClosedContraint : 0
//		self.saveButtonBG.setTitle(title, forState: .Normal)
//		UIView.animateWithDuration(0.2, animations: { () -> Void in
//			self.saveButtonBG.superview?.layoutIfNeeded()
//			
//		})
//	}
	
//	private func toggleShareButtonBgAnimation()
//	{
//		let title = isShareButtonOpen() ? "" : "Share It"
//		self.shareBGConstraint.constant = isShareButtonOpen() ? ClosedContraint : 0
//		
//		self.shareButtonBG.setTitle(title, forState: .Normal)
//		UIView.animateWithDuration(0.2, animations: { () -> Void in
//			self.shareButtonBG.superview?.layoutIfNeeded()
//			
//		})
//	}

	
	
	func documentInteractionControllerDidDismissOptionsMenu(controller: UIDocumentInteractionController) {
		registerForNotifications()
//		toggleShareButtonBgAnimation()
	}
	
	private func sortDataSource(words :[String], emojis : [String]) ->[String]
	{
		let lowestCount = words.count >= emojis.count ?  emojis.count : words.count
		
		
		var result = [String]()
		var index = 0
		for i in 0..<lowestCount
		{
			index++;
			result.append(words[i])
			result.append(emojis[i])
		}
		
		var arrayWithExtras = words.count >= emojis.count ? words : emojis
		arrayWithExtras.removeRange(Range<Int>(start: 0, end: index))
		result.extend(arrayWithExtras)
		
		return result;
	}
	
	private func isSaveButtonOpen() -> Bool
	{
		return self.saveBGConstraint.constant == 0
	}
	
	private func isShareButtonOpen() -> Bool
	{
		return self.shareBGConstraint.constant == 0
	}
	
	@IBAction func whatsappShareRequested(sender: AnyObject) {
		return
		if let delegate = self.sharingDelegate
		{
			delegate.textEditingDidEnd()
			let fileManager = NSFileManager.defaultManager()
			var error : NSError?
			let url = delegate.imageForSharing()

			let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true);
			let documentsDirectory = paths[0] as! String
			let whatsappImagePath = documentsDirectory + "/ShareMe.wai"
			if (fileManager.fileExistsAtPath(whatsappImagePath))
			{
				fileManager.removeItemAtPath(whatsappImagePath, error: &error)
			}
			fileManager.copyItemAtPath(url.absoluteString!, toPath: whatsappImagePath, error: &error)
			NSNotificationCenter.defaultCenter().removeObserver(self)
			documentationInteractionController = UIDocumentInteractionController(URL: NSURL(fileURLWithPath: whatsappImagePath)!)
			documentationInteractionController?.UTI = "net.whatsapp.image"
			documentationInteractionController?.delegate = self
			documentationInteractionController?.presentOpenInMenuFromRect(self.view.superview!.superview!.bounds, inView: self.view.superview!.superview!, animated: true)
			
		}
	}
	
	@IBAction func facebookShareRequested(sender: AnyObject) {
		self.shareTo(SLServiceTypeFacebook);
	}
	
	@IBAction func twitterShareRequested(sender: AnyObject) {
		self.shareTo(SLServiceTypeTwitter);
	}
	
	
	private func shareTo(type: String!)
	{
		if (SLComposeViewController.isAvailableForServiceType(type))
		{
			let mySLComposerSheet = SLComposeViewController(forServiceType: type)
			mySLComposerSheet.setInitialText(TagTextProvider.addAllHashtags(self.textField.text))
			mySLComposerSheet.addImage(self.sharingDelegate!.imageForCaching())
			mySLComposerSheet.completionHandler = nil
			UIApplication.sharedApplication().delegate?.window??.rootViewController?.presentViewController(mySLComposerSheet, animated: true, completion: nil)
		}
	}

}
