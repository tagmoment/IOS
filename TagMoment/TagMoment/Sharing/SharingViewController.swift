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
	func taggingKeyboardWillChange(_ animationTime : Double, endFrame: CGRect)
	func updateUserInfoText(_ newText : String)
	func textEditingDidEnd()
	func imageForSharing() -> URL
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
	var chosenEmojiIndex : IndexPath?
	var chosenWordIndex : IndexPath?
	
    override func viewDidLoad() {
        super.viewDidLoad()
		tagsDataSource = self.sortDataSource(TagTextProvider.TagsDataSourceWords, emojis: TagTextProvider.emojisContainer) as [NSString]!
		self.textField.keyboardType = .asciiCapable
		tagsCollectionView.register(UINib(nibName: "TagsCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: CellIdent)
		tagsCollectionView.allowsMultipleSelection = true
		let leftAlignedLayout = tagsCollectionView.collectionViewLayout as! LeftAligned
		leftAlignedLayout.delegate = self
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		registerForNotifications()
		prepareSocialButtonsAnimationState()
		
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		GoogleAnalyticsReporter.ReportPageView("Sharing View");
		animateButtonEntrance()
	}
	
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		NotificationCenter.default.removeObserver(self)
	}
	
	
	fileprivate func registerForNotifications()
	{
		NotificationCenter.default.addObserver(self, selector: #selector(SharingViewController.handleKeyboardNotification(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(SharingViewController.textFieldDidChangeText(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object: nil)
		
	}
	func handleKeyboardNotification(_ notif: Notification)
	{
		let animationTime = notif.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
		let keyboardEndFrame = notif.userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue
		
		
		if let delegate = self.sharingDelegate
		{
			delegate.taggingKeyboardWillChange(animationTime, endFrame: keyboardEndFrame.cgRectValue)
		}
		if (keyboardEndFrame.cgRectValue.origin.y == UIApplication.shared.keyWindow?.frame.height)
		{
			let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(animationTime)) / Double(NSEC_PER_SEC)
			DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
				self.animateButtonEntranceWithPrep()
			})
			
			

		}
	}
	
	// MARK: - Textfield handling
	func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
		
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
		
		if (string.lengthOfBytes(using: String.Encoding.utf8) > 1)
		{
			autoKeyboardWasOn = true
		}
		
		if !noSpaceString.isEmpty
		{
			notifyDelegateOnChangedText(string)
		}
		
		
		if (self.chosenWordIndex != nil && !string.isEmpty)
		{
			self.tagsCollectionView.deselectItem(at: self.chosenWordIndex!, animated: true)
			self.collectionView(self.tagsCollectionView, didDeselectItemAt: self.chosenWordIndex!)
			self.chosenWordIndex = nil
			
			
		}
		
		return string.isEmpty
	}
	
	func textFieldDidChangeText(_ notif: Notification)
	{
		notifyDelegateOnChangedText()
	}
	
	func deleteBackwardsDetected() {
		if (self.chosenEmojiIndex != nil &&  TagTextProvider.isCurrentCharSetSecondWord(TagTextProvider.currentEmoji))
		{
			self.tagsCollectionView.deselectItem(at: self.chosenEmojiIndex!, animated: true)
			self.collectionView(self.tagsCollectionView, didDeselectItemAt: self.chosenEmojiIndex!)
			self.chosenEmojiIndex = nil
			TagTextProvider.currentEmoji = nil
			return;
		}
		
		if (self.chosenWordIndex != nil && TagTextProvider.isCurrentCharSetSecondWord(TagTextProvider.currentWord))
		{
			self.tagsCollectionView.deselectItem(at: self.chosenWordIndex!, animated: true)
			self.collectionView(self.tagsCollectionView, didDeselectItemAt: self.chosenWordIndex!)
			self.chosenWordIndex = nil
			return;
		}
		
	}
	
	func notifyDelegateOnChangedText(_ input : String = "")
	{
		if let delegate = self.sharingDelegate
		{
			var returnVal = input
			if (returnVal.isEmpty)
			{
				textField.text = textField.text!.trimmingCharacters(in: CharacterSet.whitespaces)
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
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool
	{
		self.textField.resignFirstResponder()
		return true
	}
	
	func textFieldShouldClear(_ textField: UITextField) -> Bool
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
		
		if let indices = self.tagsCollectionView.indexPathsForSelectedItems, indices.count != 0
		{
			for indexPath in indices
			{
				self.tagsCollectionView.deselectItem(at: indexPath, animated: true)
				self.collectionView(self.tagsCollectionView, didDeselectItemAt: indexPath)
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
			view?.layer.transform = CATransform3DMakeScale(0.01, 0.01, 1)
			view?.isHidden = true
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
			view?.isHidden = false
			UIView.animate(withDuration: 0.5, delay: delay ,usingSpringWithDamping: 0.5, initialSpringVelocity: 5, options: UIViewAnimationOptions.curveLinear, animations: { () -> Void in
				view?.layer.transform = CATransform3DIdentity
				}, completion: nil)
			
		}
	}
	
	// MARK: - Collection view delegation
	func shouldBeFirstItem(at indexPath: IndexPath!) -> Bool {
		if (indexPath.row < tagsDataSource.count)
		{
			return true
		}
		
		return false;
	}
	
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
		return tagsDataSource.count + extraDataEmojis.count;
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdent, for: indexPath) as! TagsCollectionViewCell
		var found = false
		if let selectedIndices = collectionView.indexPathsForSelectedItems
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
			cell.backgroundColor = UIColor.white
			cell.tagName.textColor = UIColor.black
		}
		else
		{
			cell.backgroundColor = UIColor.black
			cell.tagName.textColor = UIColor.white
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
	
	func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
		
		if (!self.textField.isFirstResponder)
		{
			self.textField.becomeFirstResponder()
		}
		
		let isWord = indexPath.item % 2 == 0 ? true : false
		if (self.chosenWordIndex != nil && isWord)
		{
			self.tagsCollectionView.deselectItem(at: self.chosenWordIndex!, animated: true)
			self.collectionView(self.tagsCollectionView, didDeselectItemAt: self.chosenWordIndex!)
		}
		
			
		if (self.chosenEmojiIndex != nil && !isWord)
		{
			self.tagsCollectionView.deselectItem(at: self.chosenEmojiIndex!, animated: true)
			self.collectionView(self.tagsCollectionView, didDeselectItemAt: self.chosenEmojiIndex!)
		}
			
		self.chosenWordIndex = isWord ? indexPath : self.chosenWordIndex
		self.chosenEmojiIndex = !isWord ? indexPath : self.chosenEmojiIndex
		
		return true
	}
	
	func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
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
	
	func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
		let cell = collectionView.cellForItem(at: indexPath)
		if let tagCell = cell as? TagsCollectionViewCell
		{
			tagCell.backgroundColor = UIColor.black
			tagCell.tagName.textColor = UIColor.white
		}
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		
		let cell = collectionView.cellForItem(at: indexPath) as! TagsCollectionViewCell
		cell.backgroundColor = UIColor.white
		cell.tagName.textColor = UIColor.black
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
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
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
		let attributes : [String : Any] = [NSFontAttributeName : font]
		
		let size = data.boundingRect(with: CGSize(width: 9999, height: 26),
			options: NSStringDrawingOptions.usesLineFragmentOrigin,
			attributes: attributes,
			context: nil)
	
		return CGSize(width: ceil(size.width) + 34, height: 34)
	}
	
	
	
	// MARK: - Buttons Handling
	@IBAction func shareButtonPressed(_ sender: AnyObject) {
		
		
			if let delegate = self.sharingDelegate
			{
				NotificationCenter.default.removeObserver(self)
				delegate.textEditingDidEnd()
				let url = delegate.imageForSharing()
				documentationInteractionController = UIDocumentInteractionController(url: url)
				documentationInteractionController?.delegate = self
				documentationInteractionController?.presentOptionsMenu(from: self.view.superview!.superview!.bounds, in: self.view.superview!.superview!, animated: true)
				
			}
			return;
		
	}
	
	func documentInteractionController(_ controller: UIDocumentInteractionController, didEndSendingToApplication application: String?) {
		uploadImage()
	}
	
	func clearState()
	{
		TagTextProvider.clear()
		chosenEmojiIndex = nil
		chosenWordIndex = nil
	}
	
	
	
	func documentInteractionControllerDidDismissOptionsMenu(_ controller: UIDocumentInteractionController) {
		registerForNotifications()
//		toggleShareButtonBgAnimation()
	}
	
	fileprivate func sortDataSource(_ words :[String], emojis : [String]) ->[String]
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
		
		arrayWithExtras.removeSubrange(0..<index)
		self.extraDataEmojis = arrayWithExtras as [NSString]!;
//		result.appendContentsOf(arrayWithExtras)
		
		return result;
	}
	
	@IBAction func facebookShareRequested(_ sender: AnyObject) {
		self.shareTo(SLServiceTypeFacebook);
	}
	
	@IBAction func twitterShareRequested(_ sender: AnyObject) {
		self.shareTo(SLServiceTypeTwitter);
	}
	
	
	fileprivate func shareTo(_ type: String!)
	{
		if (SLComposeViewController.isAvailable(forServiceType: type))
		{
			let text = self.textField.text != nil ? self.textField.text! : ""

			let mySLComposerSheet = SLComposeViewController(forServiceType: type)
			mySLComposerSheet?.setInitialText(TagTextProvider.addAllHashtags(text) + " #tagmoment")
			mySLComposerSheet?.add(self.sharingDelegate!.imageForCaching())
			mySLComposerSheet?.completionHandler = {(result : SLComposeViewControllerResult) -> Void in
				if result == .done
				{
					self.uploadImage()
				}
					
			}
			UIApplication.shared.delegate?.window??.rootViewController?.present(mySLComposerSheet!, animated: true, completion: nil)
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
