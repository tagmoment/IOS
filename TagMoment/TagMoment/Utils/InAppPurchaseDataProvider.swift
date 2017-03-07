//
//  InAppPurchaseDataProvider.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 04/11/2015.
//  Copyright © 2015 TagMoment. All rights reserved.
//

import UIKit
import StoreKit

let RemoveLockedProductsNotificationName = "RemoveLockedProductsNotificationName"

protocol InAppPurchaseDelegate : class
{
	func maskPurchaseComplete(_ maskViewModel : TMMaskViewModel)
	func masksLockedViewModels() -> [TMMaskViewModel]!
	func maskPurchaseFailed(_ maskViewModel : TMMaskViewModel)
}

class InAppPurchaseDataProvider: NSObject , SKProductsRequestDelegate, SKPaymentTransactionObserver {
	
	weak var delegate: InAppPurchaseDelegate?
	var transactionInProgress = false
	let productIds = ["tagmoment_mask_bubble_1", "tagmoment_mask_star_1", "tagmoment_mask_waves_1"]
	var productsArray: Array<SKProduct?> = []
	var currentPurchasedViewModel : TMMaskViewModel?
	
	func fetchProducts()
	{
		SKPaymentQueue.default().add(self)
		if SKPaymentQueue.canMakePayments() {
			let productIdentifiers = NSSet(array: productIds)
			let productRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
			
			productRequest.delegate = self
			productRequest.start()
		}
		else {
			print("Cannot perform In App Purchases.")
			/* Delegation error */
		}
	}
	
	func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse)
	{
		if response.invalidProductIdentifiers.count != 0 {
			print(response.invalidProductIdentifiers.description)
		}
		
		if response.products.count != 0 {
			for product in response.products {
				productsArray.append(product)
			}
		}
			
		
		else {
			print("There are no products.")
		}
	}
	
	func request(_ request: SKRequest, didFailWithError error: Error)
	{
		print(error)
		postRemoveLockedProducts()
	}
	
	func postRemoveLockedProducts()
	{
		NotificationCenter.default.post(name: Notification.Name(rawValue: RemoveLockedProductsNotificationName), object: nil)
	}
	
	func showMessageForMask(_ maskViewModel : TMMaskViewModel, presentingViewController : UIViewController)
	{
		guard transactionInProgress == false else
		{
			print("There's a transaction in progress")
			return;
		}
		guard maskViewModel.maskProductId.characters.count != 0 else
		{
			print("There was no product identifier here")
			return;
		}
		
		
		let product = productsArray.filter { (product) -> Bool in
			return maskViewModel.maskProductId == product!.productIdentifier
		}
		
		guard product.count != 0 else
		{
			print("There was no match between product from store and masks.")
			return;
		}
		
		UIApplication.shared.beginIgnoringInteractionEvents()
		self.currentPurchasedViewModel = maskViewModel
		let payment = SKPayment(product: product[0]!)
		SKPaymentQueue.default().add(payment)
		self.transactionInProgress = true
		
	}
	
	
	
	func restorePayments()
	{
		SKPaymentQueue.default().restoreCompletedTransactions()
	}
	
	func showFailedPurchaseMessage()
	{
		
	}
	
	func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue)
	{
		print("Restore queue finished")
	}
	
	func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]){
		
		for transaction in transactions
		{
			switch transaction.transactionState {
			case SKPaymentTransactionState.purchased:
				fallthrough
			case SKPaymentTransactionState.restored:
				print("Transaction completed successfully.")
				SKPaymentQueue.default().finishTransaction(transaction)
				transactionInProgress = false
				if let delegate = self.delegate
				{
					let viewModels = delegate.masksLockedViewModels()
					let mask = viewModels?.filter { (mask : TMMaskViewModel!) -> Bool in
						return mask.maskProductId == transaction.payment.productIdentifier
					}
					if (mask?.count != 0)
					{
						delegate.maskPurchaseComplete((mask?[0])!)
					}
					
				}
				if UIApplication.shared.isIgnoringInteractionEvents
				{
					UIApplication.shared.endIgnoringInteractionEvents()
				}
				
				
				
			case SKPaymentTransactionState.failed:
				print("Transaction Failed");
				SKPaymentQueue.default().finishTransaction(transaction)
				transactionInProgress = false
				if let delegate = self.delegate
				{
					delegate.maskPurchaseFailed(self.currentPurchasedViewModel!)
				}
				
				if UIApplication.shared.isIgnoringInteractionEvents
				{
					UIApplication.shared.endIgnoringInteractionEvents()
				}
				
			default:
				print(transaction.transactionState.rawValue)
			}
		}
	}
	
	fileprivate func priceAsString(_ price : NSDecimalNumber, priceLocale : Locale) -> String
	{
		let formatter = NumberFormatter()
		formatter.formatterBehavior = NumberFormatter.Behavior.behavior10_4
		formatter.numberStyle = .currency
		formatter.locale = priceLocale
		
		return formatter.string(from: price)!
	}
}
