//
//  FileHandlingService.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 9/21/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import Foundation
let CachedImagePathKey = "cachedImagePathKey"

class FileHandlingService
{
	
	class func SaveImageToDisk(_ image: UIImage, postfix : String = "jpeg", shouldSavePath : Bool = true)
	{
		let imageData = UIImageJPEGRepresentation(image, 0.8)
		
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true);
		let documentsDirectory = paths[0] 
		let imagePath = documentsDirectory + "/ShareMe." + postfix
		
		let filemanager = FileManager.default
		var error : NSError?
		if (filemanager.fileExists(atPath: imagePath))
		{
			do {
				try filemanager.removeItem(atPath: imagePath)
			} catch let error1 as NSError {
				error = error1
				print("Error removing file: \(error?.localizedDescription)")
			}
		}
		
		if let imageData = imageData
		{
			do {
				try imageData.write(to: URL(fileURLWithPath: imagePath), options: NSData.WritingOptions.noFileProtection)
				if (shouldSavePath)
				{
					UserDefaults.standard.set(imagePath, forKey: CachedImagePathKey)
					print("the cachedImagedPath is %@",imagePath, terminator: "")
				}
			} catch let error1 as NSError {
				error = error1
				print("Failed to cache image data to disk: imagePath", terminator: "")
			}
		}
		

	}
	
	class func SaveImageToSources(_ image: UIImage)
	{
		SaveImageToDisk(image)
		SaveImageToDisk(image, postfix: "igo", shouldSavePath: false)
		SaveImageToDisk(image, postfix: "wai", shouldSavePath: false)
	}
	
	class func InstagrameFilePath() -> String
	{
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true);
		let documentsDirectory = paths[0] 
		return documentsDirectory + "/ShareMe.igo"
	}
	
	class func WhatsappFilePath() -> String
	{
		let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true);
		let documentsDirectory = paths[0] 
		return documentsDirectory + "/ShareMe.wai"
	}

}
