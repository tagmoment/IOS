//
//  InAppPurchaseDataProvider.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 04/11/2015.
//  Copyright © 2015 TagMoment. All rights reserved.
//

import UIKit
import StoreKit

protocol InAppPurchaseDelegate : class
{
	func maskPurchaseComplete(maskViewModel : TMMaskViewModel)
	func maskPurchaseFailed(maskViewModel : TMMaskViewModel)
}

class InAppPurchaseDataProvider: NSObject , SKProductsRequestDelegate, SKPaymentTransactionObserver {
	
	weak var delegate: InAppPurchaseDelegate?
	var transactionInProgress = false
	let productIds = ["tagmoment_mask_bubble", "tagmoment_mask_star", "tagmoment_mask_waves"]
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
			
			/* Delegation success */
		}
		else {
			print("There are no products.")
		}
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
		
		UIApplication.sharedApplication().beginIgnoringInteractionEvents()
		self.currentPurchasedViewModel = maskViewModel
		let payment = SKPayment(product: product[0])
		SKPaymentQueue.defaultQueue().addPayment(payment)
		self.transactionInProgress = true
		
	}
	
	
	func showFailedPurchaseMessage()
	{
		
	}
	
	func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]){
		
		for transaction in transactions
		{
			switch transaction.transactionState {
			case SKPaymentTransactionState.Purchased:
				print("Transaction completed successfully.")
				SKPaymentQueue.defaultQueue().finishTransaction(transaction)
				transactionInProgress = false
				if let delegate = self.delegate
				{
					delegate.maskPurchaseComplete(self.currentPurchasedViewModel!)
				}
				UIApplication.sharedApplication().endIgnoringInteractionEvents()
				
				
				
			case SKPaymentTransactionState.Failed:
				print("Transaction Failed");
				SKPaymentQueue.defaultQueue().finishTransaction(transaction)
				transactionInProgress = false
				if let delegate = self.delegate
				{
					delegate.maskPurchaseFailed(self.currentPurchasedViewModel!)
				}
				
				UIApplication.sharedApplication().endIgnoringInteractionEvents()
				
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
