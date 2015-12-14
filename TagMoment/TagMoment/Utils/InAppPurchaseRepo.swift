//
//  InAppServerRepo.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 05/11/2015.
//  Copyright © 2015 TagMoment. All rights reserved.
//

import UIKit

let PurchasedItemsKey = "PurchasedItemsKey"

class InAppPurchaseRepo: NSObject {
	class func addProductId(productId : String)
	{
		var savedObject : [String]?
		if let productIds = getProductsIds()
		{
			savedObject = productIds
			
		}
		else
		{
			savedObject = [String]()
		}
		
		savedObject?.append(productId)
		NSUserDefaults.standardUserDefaults().setObject(savedObject, forKey: PurchasedItemsKey)
		NSUserDefaults.standardUserDefaults().synchronize()
	}
	
	class func getProductsIds() -> [String]?
	{
		if let productsIds = NSUserDefaults.standardUserDefaults().objectForKey(PurchasedItemsKey)
		{
			return productsIds as? [String]
		}
		
		return nil
		
	}
	
	class func isProductBought(productId : String) -> Bool
	{
		guard let productIds = getProductsIds() else {
			return false
		}
		
		return productIds.contains(productId)
	}
	
	class func clear()
	{
		NSUserDefaults.standardUserDefaults().removeObjectForKey(PurchasedItemsKey)
	}
}
