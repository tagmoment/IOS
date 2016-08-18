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

class SharingViewController: UIViewController, TMTextFieldDelegate, UICollectionViewDataSource, LeftAlignedCollectionViewDelegate, UIDocumentInteractionControllerDelegate	{
	
	var imageShared = false
	let ClosedContraint = CGFloat(-100)
	let CellIdent = "cellIdent"
	let MaxLettersInTag = 15
	
	
//	Left out side
//	
	
	var tagsDataSource : [NSString]!
	var extraDataEmojis : [NSString]!
	var autoKeyboardWasOn = false
	var keyboardWasShown = false
	weak var sharingDelegate: SharingControllerDelegate?
	var documentationInteractionController : UIDocumentInteractionController?
	@IBOutlet weak var textField: UITextField!
	@IBOutlet weak var tagsHeightConstraint: NSLayoutConstraint!
	@IBOutlet weak var tagsCollectionView: UICollectionView!
	
	@IBOutlet weak var tagsCenterConstraint: NSLayoutConstraint!
	@IBOutlet weak var facebook_share_button: UIButton!
	@IBOutlet weak var twitter_share_button: UIButton!
	@IBOutlet weak var more_share_button: UIButton!
	var chosenEmojiIndex : NSIndexPath?
	var chosenWordIndex : NSIndexPath?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		tagsDataSource = self.sortDataSource(TagTextProvider.TagsDataSourceWords, emojis: TagTextProvider.emojisContainer)
		self.textField.keyboardType = .ASCIICapable
		tagsCollectionView.registerNib(UINib(nibName: "TagsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CellIdent)
		tagsCollectionView.allowsMultipleSelection = true
		let leftAlignedLayout = tagsCollectionView.collectionViewLayout as! LeftAligned
		leftAlignedLayout.delegate = self
    }

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		registerForNotifications()
		prepareSocialButtonsAnimationState()
		
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		GoogleAnalyticsReporter.ReportPageView("Sharing View");
		animateButtonEntrance()
	}
	
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	
	private func registerForNotifications()
	{
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SharingViewController.handleKeyboardNotification(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(SharingViewController.textFieldDidChangeText(_:)), name: UITextFieldTextDidChangeNotification, object: nil)
		
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
			let dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(animationTime))
			dispatch_after(dispatchTime, dispatch_get_main_queue(), {
				self.animateButtonEntranceWithPrep()
			})
			
			

		}
	}
	
	// MARK: - Textfield handling
	func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		
		let noSpaceString = TagTextProvider.removeSpaces(string)
		
		if !(TagTextProvider.isReplacementStringAllowd(noSpaceString))
		{
			return false
		}
		
		let MaxLettersAllowed = TagTextProvider.currentEmoji != nil ? MaxLettersInTag + 2 : MaxLettersInTag
		
		
		let charCount = textField.text != nil ? textField.text!.characters.count : 0
		if (charCount + noSpaceString.characters.count >= MaxLettersAllowed && !noSpaceString.isEmpty && TagTextProvider.currentWord == nil)
		{
			return false
			
		}
		else if(noSpaceString == " ")
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
		
		if !noSpaceString.isEmpty
		{
			notifyDelegateOnChangedText(string)
		}
		
		
		if (self.chosenWordIndex != nil && !string.isEmpty)
		{
			self.tagsCollectionView.deselectItemAtIndexPath(self.chosenWordIndex!, animated: true)
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
		if (self.chosenEmojiIndex != nil &&  TagTextProvider.isCurrentCharSetSecondWord(TagTextProvider.currentEmoji))
		{
			self.tagsCollectionView.deselectItemAtIndexPath(self.chosenEmojiIndex!, animated: true)
			self.collectionView(self.tagsCollectionView, didDeselectItemAtIndexPath: self.chosenEmojiIndex!)
			self.chosenEmojiIndex = nil
			TagTextProvider.currentEmoji = nil
			return;
		}
		
		if (self.chosenWordIndex != nil && TagTextProvider.isCurrentCharSetSecondWord(TagTextProvider.currentWord))
		{
			self.tagsCollectionView.deselectItemAtIndexPath(self.chosenWordIndex!, animated: true)
			self.collectionView(self.tagsCollectionView, didDeselectItemAtIndexPath: self.chosenWordIndex!)
			self.chosenWordIndex = nil
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
				textField.text = textField.text!.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
				returnVal = textField.text!
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
		
		if let indices = self.tagsCollectionView.indexPathsForSelectedItems() where indices.count != 0
		{
			for indexPath in indices
			{
				self.tagsCollectionView.deselectItemAtIndexPath(indexPath, animated: true)
				self.collectionView(self.tagsCollectionView, didDeselectItemAtIndexPath: indexPath)
			}
		}
	}
	
	func prepareForSmallScreenLayout()
	{
		self.view.layoutIfNeeded()
	}
	
	// MARK: - Animations
	
	func prepareSocialButtonsAnimationState()
	{
		
		for view in [self.facebook_share_button, self.twitter_share_button, self.more_share_button]
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
		var shuffled = [self.facebook_share_button, self.twitter_share_button, self.more_share_button]
		for i in 0..<shuffled.count
		{
			let view = shuffled[i]
			let delay = Double(i)*0.1
			view.hidden = false
			UIView.animateWithDuration(0.5, delay: delay ,usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
				view.layer.transform = CATransform3DIdentity
				}, completion: nil)
			
		}
	}
	
	// MARK: - Collection view delegation
	func shouldBeFirstItemAtIndexPath(indexPath: NSIndexPath!) -> Bool {
		if (indexPath.row < tagsDataSource.count)
		{
			return true
		}
		
		return false;
	}
	
	
	func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
		return tagsDataSource.count + extraDataEmojis.count;
	}
	
	func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
		
		
		let cell = collectionView.dequeueReusableCellWithReuseIdentifier(CellIdent, forIndexPath: indexPath) as! TagsCollectionViewCell
		var found = false
		if let selectedIndices = collectionView.indexPathsForSelectedItems()
		{
			for index in selectedIndices
			{
				if (index.row == indexPath.row)
				{
					found = true
					break;
				}
				
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
		
		var value : NSString
		if (indexPath.item < self.tagsDataSource.count)
		{
			value = tagsDataSource[indexPath.item]
		}
		else
		{
			value = extraDataEmojis[indexPath.item - self.tagsDataSource.count]
		}
		cell.tagName.text = value as String
		return cell;
		
	}
	
	func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
		
		let isWord = indexPath.item % 2 == 0 ? true : false
		if (self.chosenWordIndex != nil && isWord)
		{
			self.tagsCollectionView.deselectItemAtIndexPath(self.chosenWordIndex!, animated: true)
			self.collectionView(self.tagsCollectionView, didDeselectItemAtIndexPath: self.chosenWordIndex!)
		}
			
		if (self.chosenEmojiIndex != nil && !isWord)
		{
			self.tagsCollectionView.deselectItemAtIndexPath(self.chosenEmojiIndex!, animated: true)
			self.collectionView(self.tagsCollectionView, didDeselectItemAtIndexPath: self.chosenEmojiIndex!)
		}
			
		self.chosenWordIndex = isWord ? indexPath : self.chosenWordIndex
		self.chosenEmojiIndex = !isWord ? indexPath : self.chosenEmojiIndex
		
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
			tagCell.backgroundColor = UIColor.blackColor()
			tagCell.tagName.textColor = UIColor.whiteColor()
		}
	}

	func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
		
		let cell = collectionView.cellForItemAtIndexPath(indexPath) as! TagsCollectionViewCell
		cell.backgroundColor = UIColor.whiteColor()
		cell.tagName.textColor = UIColor.blackColor()
		var value : NSString
		if (indexPath.item < self.tagsDataSource.count)
		{
			value = tagsDataSource[indexPath.item]
		}
		else
		{
			value = extraDataEmojis[indexPath.item - self.tagsDataSource.count]
		}

		
		
		notifyDelegateOnChangedText(value as String)
	}
	
	func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
	{
		if (indexPath.item % 2 != 0)
		{
			return CGSize(width: 56, height: 34)
		}
		
		var data : NSString
		if (indexPath.item < self.tagsDataSource.count)
		{
			data = tagsDataSource[indexPath.item]
		}
		else
		{
			data = extraDataEmojis[indexPath.item - self.tagsDataSource.count]
		}
		

		let font = UIFont(name: "Raleway", size: 17)
		let attributes : [String : AnyObject!] = [NSFontAttributeName : font]
		
		let size = data.boundingRectWithSize(CGSize(width: 9999, height: 26),
			options: NSStringDrawingOptions.UsesLineFragmentOrigin,
			attributes: attributes,
			context: nil)
	
		return CGSize(width: ceil(size.width) + 34, height: 34)
	}
	
	
	
	// MARK: - Buttons Handling
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
			return;
		
	}
	
	func documentInteractionController(controller: UIDocumentInteractionController, didEndSendingToApplication application: String?) {
		uploadImage()
	}
	
	func clearState()
	{
		TagTextProvider.clear()
		chosenEmojiIndex = nil
		chosenWordIndex = nil
	}
	
	
	
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
			index += 1;
			result.append(words[i])
			result.append(emojis[i])
		}
		
		var arrayWithExtras = words.count >= emojis.count ? words : emojis
		
		arrayWithExtras.removeRange(0..<index)
		self.extraDataEmojis = arrayWithExtras;
//		result.appendContentsOf(arrayWithExtras)
		
		return result;
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
			let text = self.textField.text != nil ? self.textField.text! : ""

			let mySLComposerSheet = SLComposeViewController(forServiceType: type)
			mySLComposerSheet.setInitialText(TagTextProvider.addAllHashtags(text) + " #tagmoment")
			mySLComposerSheet.addImage(self.sharingDelegate!.imageForCaching())
			mySLComposerSheet.completionHandler = {(result : SLComposeViewControllerResult) -> Void in
				if result == .Done
				{
					self.uploadImage()
				}
					
			}
			UIApplication.sharedApplication().delegate?.window??.rootViewController?.presentViewController(mySLComposerSheet, animated: true, completion: nil)
		}
	}
	
	func uploadImage()
	{
		if imageShared == true
		{
			return
		}
		
		imageShared = true
		let image = self.sharingDelegate?.imageForCaching()
		ImageUploadService.sharedInstance().uploadImage(image)
	}
	
}
