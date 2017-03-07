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
	class func addProductId(_ productId : String)
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
		UserDefaults.standard.set(savedObject, forKey: PurchasedItemsKey)
		UserDefaults.standard.synchronize()
	}
	
	class func getProductsIds() -> [String]?
	{
		if let productsIds = UserDefaults.standard.object(forKey: PurchasedItemsKey)
		{
			return productsIds as? [String]
		}
		
		return nil
		
	}
	
	class func isProductBought(_ productId : String) -> Bool
	{
		guard let productIds = getProductsIds() else {
			return false
		}
		
		return productIds.contains(productId)
	}
	
	class func clear()
	{
		UserDefaults.standard.removeObject(forKey: PurchasedItemsKey)
	}
}
