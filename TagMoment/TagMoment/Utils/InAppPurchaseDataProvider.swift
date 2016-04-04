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
	func maskPurchaseComplete(maskViewModel : TMMaskViewModel)
	func masksLockedViewModels() -> [TMMaskViewModel]!
	func maskPurchaseFailed(maskViewModel : TMMaskViewModel)
}

class InAppPurchaseDataProvider: NSObject , SKProductsRequestDelegate, SKPaymentTransactionObserver {
	
	weak var delegate: InAppPurchaseDelegate?
	var transactionInProgress = false
	let productIds = ["tagmoment_mask_bubble_1", "tagmoment_mask_star_1", "tagmoment_mask_waves_1"]
	var productsArray: Array<SKProduct!> = []
	var currentPurchasedViewModel : TMMaskViewModel?
	
	func fetchProducts()
	{
		SKPaymentQueue.defaultQueue().addTransactionObserver(self)
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
	
	func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse)
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
	
	func request(request: SKRequest, didFailWithError error: NSError)
	{
		print(error)
		postRemoveLockedProducts()
	}
	
	func postRemoveLockedProducts()
	{
		NSNotificationCenter.defaultCenter().postNotificationName(RemoveLockedProductsNotificationName, object: nil)
	}
	
	func showMessageForMask(maskViewModel : TMMaskViewModel, presentingViewController : UIViewController)
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
		
		
		let product = productsArray.filter { (product : SKProduct!) -> Bool in
			return maskViewModel.maskProductId == product.productIdentifier
		}
		
		guard product.count != 0 else
		{
			print("There was no match between product from store and masks.")
			return;
		}
		
		UIApplication.sharedApplication().beginIgnoringInteractionEvents()
		self.currentPurchasedViewModel = maskViewModel
		let payment = SKPayment(product: product[0])
		SKPaymentQueue.defaultQueue().addPayment(payment)
		self.transactionInProgress = true
		
	}
	
	
	
	func restorePayments()
	{
		SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
	}
	
	func showFailedPurchaseMessage()
	{
		
	}
	
	func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue)
	{
		print("Restore queue finished")
	}
	
	func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]){
		
		for transaction in transactions
		{
			switch transaction.transactionState {
			case SKPaymentTransactionState.Purchased:
				fallthrough
			case SKPaymentTransactionState.Restored:
				print("Transaction completed successfully.")
				SKPaymentQueue.defaultQueue().finishTransaction(transaction)
				transactionInProgress = false
				if let delegate = self.delegate
				{
					let viewModels = delegate.masksLockedViewModels()
					let mask = viewModels.filter { (mask : TMMaskViewModel!) -> Bool in
						return mask.maskProductId == transaction.payment.productIdentifier
					}
					if (mask.count != 0)
					{
						delegate.maskPurchaseComplete(mask[0])
					}
					
				}
				if UIApplication.sharedApplication().isIgnoringInteractionEvents()
				{
					UIApplication.sharedApplication().endIgnoringInteractionEvents()
				}
				
				
				
			case SKPaymentTransactionState.Failed:
				print("Transaction Failed");
				SKPaymentQueue.defaultQueue().finishTransaction(transaction)
				transactionInProgress = false
				if let delegate = self.delegate
				{
					delegate.maskPurchaseFailed(self.currentPurchasedViewModel!)
				}
				
				if UIApplication.sharedApplication().isIgnoringInteractionEvents()
				{
					UIApplication.sharedApplication().endIgnoringInteractionEvents()
				}
				
			default:
				print(transaction.transactionState.rawValue)
			}
		}
	}
	
	private func priceAsString(price : NSDecimalNumber, priceLocale : NSLocale) -> String
	{
		let formatter = NSNumberFormatter()
		formatter.formatterBehavior = NSNumberFormatterBehavior.Behavior10_4
		formatter.numberStyle = .CurrencyStyle
		formatter.locale = priceLocale
		
		return formatter.stringFromNumber(price)!
	}
}
