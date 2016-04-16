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
	func captureButtonPressed()
	func switchCamButtonPressed()
}

class ChooseMasksViewController: UIViewController, iCarouselDataSource, iCarouselDelegate{
	
	static var lastMaskIndex = 0
	
	@IBOutlet weak var menuButton: UIButton!
	@IBOutlet weak var chooseFromCameraRollButton: UIButton!
	@IBOutlet weak var menuButtonBottomConstraint: NSLayoutConstraint!
	@IBOutlet weak var menuButtonLeftConstraint: NSLayoutConstraint!
	let CellIdent = "CellIdent"

	@IBOutlet var masksCarousel: iCarousel!
	@IBOutlet weak var takeButton: UIButton!
	
	@IBOutlet weak var switchCamButton: UIButton!
	
	@IBOutlet weak var captureButtonCenterYConstraint: NSLayoutConstraint!
	
	weak var masksChooseDelegate: ChooseMasksControllerDelegate?
	
	var masksViewModels : [TMMaskViewModel]?
	
	deinit
	{
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
    override func viewDidLoad() {
        super.viewDidLoad()
		masksCarousel.type = .Linear
		masksCarousel.pagingEnabled = true
		loadMasks()
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleRemoveProductsNotification), name: RemoveLockedProductsNotificationName, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleVolumeButtonPressedNotification), name: TMVolumeUpButtonPressedNotificationName, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(handleVolumeButtonPressedNotification), name: TMVolumeDownButtonPressedNotificationName, object: nil)
		let startIndex = ChooseMasksViewController.lastMaskIndex
		masksCarousel.scrollToItemAtIndex(startIndex, animated: false)
    }

	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		GoogleAnalyticsReporter.ReportPageView("Choose Masks View")

		if let view = masksCarousel.itemViewAtIndex(masksCarousel.currentItemIndex)
		{
			let subview = view as! MaskCollectionViewCell
			subview.highlighted = true
			carouselCurrentItemIndexDidChange(masksCarousel)
//			self.masksChooseDelegate?.maskChosen(self.masksViewModels?[masksCarousel.currentItemIndex].name!)
		}
	}
	
	func handleRemoveProductsNotification()
	{
		self.masksViewModels = self.masksViewModels?.filter({ (viewModel : TMMaskViewModel) -> Bool in
			if viewModel.locked
			{
				if let index = MaskFactory.MASKS.indexOf(viewModel.name!)
				{
					MaskFactory.MASKS.removeAtIndex(index)
				}
			}
			return !viewModel.locked
		})
		
		
		masksCarousel.reloadData()
	}
	
	func handleVolumeButtonPressedNotification()
	{
		self.takeButtonPressed(nil)
	}
	
	func loadMasks()
	{
		self.masksViewModels = MaskFactory.getViewModels()
		masksCarousel.reloadData()
	}
	
	@objc func scrollAnimation(sender : AnyObject!)
	{
		masksCarousel.scrollToItemAtIndex(0, duration: 2.5)
	}
	// MARK: - UICollectionView delegation & datasource
	func numberOfItemsInCarousel(carousel: iCarousel!) -> Int {
		if let count = self.masksViewModels?.count
		{
			return count;
		}
		return 0
	}
	
	func carousel(carousel: iCarousel!, viewForItemAtIndex index: Int,reusingView view: UIView!) -> UIView!
	{
		var cell : MaskCollectionViewCell;
		if (view == nil)
		{
			cell = NSBundle.mainBundle().loadNibNamed("MaskCollectionViewCell", owner: nil, options: nil)[0] as! MaskCollectionViewCell
		}
		else
		{
			cell = view as! MaskCollectionViewCell
		}
		
		let maskModel = self.masksViewModels![index]
		cell.maskImage.image = UIImage(named: maskModel.name!.lowercaseString)
		cell.lockIcon.hidden = !maskModel.locked
		cell.maskName.text = maskModel.name
	
		return cell;
	}
	
	func carouselItemWidth(carousel: iCarousel!) -> CGFloat {
		return CGFloat(70.0)
	}
	
	func carouselCurrentItemIndexDidChange(carousel: iCarousel!) {
		
		for view in carousel.visibleItemViews
		{
			let subview = view as! MaskCollectionViewCell
			subview.highlighted = false;
		}
		if let view = carousel.currentItemView
		{
			let subview = view as! MaskCollectionViewCell
			subview.highlighted = true
			let index = masksCarousel.indexOfItemView(view)
			ChooseMasksViewController.lastMaskIndex = index
			self.masksChooseDelegate?.maskChosen(self.masksViewModels?[index].name!)
		}
		
		
	}
	
	func carousel(carousel: iCarousel!, valueForOption option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
		
		if option == .Spacing
		{
			return 1.05
		}
		return value;
	}
	
	@IBAction func takeButtonPressed(sender: AnyObject?) {
	
		
		if (self.masksChooseDelegate != nil)
		{
			self.masksChooseDelegate?.captureButtonPressed()
		}
	}
	@IBAction func switchCamButtonPressed(sender: AnyObject) {
		if (self.masksChooseDelegate != nil)
		{
			self.masksChooseDelegate?.switchCamButtonPressed()
		}
	}
	
	func getSelectedViewModel() -> TMMaskViewModel
	{
		return self.masksViewModels![self.masksCarousel.currentItemIndex];
	}
	
	func maskAllowsSecondCapture() -> Bool
	{
		return !getSelectedViewModel().hasOneCapture
	}

	func prepareForSmallScreenLayout()
	{
		self.menuButtonLeftConstraint.constant = 5.0

		self.menuButtonBottomConstraint.constant = -self.menuButton.frame.height/2 + 10
		self.captureButtonCenterYConstraint.constant = 0
	}
	
	// MARK: - Menu handling
	@IBAction func cameraRollButtonPressed(sender: AnyObject) {

		let cameraRollCont = CameraRollViewController(nibName: "CameraRollViewController", bundle: nil)
		self.addCameraRollController(cameraRollCont)
			
	}
	
	@IBAction func menuButtonPressed(sender: AnyObject) {
		let menuCont = MenuViewController(nibName: "MenuViewController", bundle: nil)
		let mainController = UIApplication.sharedApplication().delegate?.window!?.rootViewController! as! MainViewController
		mainController.timerHandler?.cancelTimer()
		mainController.timerHandler = nil
		
		menuCont.containerHeight = MainViewController.isSmallestScreen() ? self.view.frame.height + 100 :  self.view.frame.height
		menuCont.addToView(mainController.view)
		menuCont.prepareForSmallScreen()
		mainController.addChildViewController(menuCont)
		
	}
	
	private func addCameraRollController(toController : CameraRollViewController)
	{
		let mainController = UIApplication.sharedApplication().delegate?.window!?.rootViewController! as! MainViewController
		mainController.timerHandler?.cancelTimer()
		mainController.timerHandler = nil
		toController.originalHeight = self.view.frame.height
		toController.addToView(mainController.view)
		mainController.addChildViewController(toController)
	}
	
	func getLockedViewForUnlocking(maskViewModel : TMMaskViewModel) -> MaskCollectionViewCell?
	{
		
		maskViewModel.locked = false
		let maskIndex = self.masksViewModels?.indexOf(maskViewModel)
		for view in masksCarousel.visibleItemViews
		{
			let index = masksCarousel.indexOfItemView(view as! UIView)
			if (index == maskIndex)
			{
				return view as? MaskCollectionViewCell
			}
		}
		
		return nil
		
	}
	
}
