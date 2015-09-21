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
	
	class func SaveImageToDisk(image: UIImage, postfix : String = "jpeg", shouldSavePath : Bool = true)
	{
		let imageData = UIImageJPEGRepresentation(image, 0.8)
		
		let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true);
		let documentsDirectory = paths[0] as! String
		let imagePath = documentsDirectory + "/ShareMe." + postfix
		
		let filemanager = NSFileManager.defaultManager()
		var error : NSError?
		if (filemanager.fileExistsAtPath(imagePath))
		{
			filemanager.removeItemAtPath(imagePath, error: &error)
		}
		if !imageData.writeToFile(imagePath, options: NSDataWritingOptions.DataWritingFileProtectionNone, error: &error)
		{
			print("Failed to cache image data to disk: imagePath")
		}
		else if (shouldSavePath)
		{
			NSUserDefaults.standardUserDefaults().setObject(imagePath, forKey: CachedImagePathKey)
			print("the cachedImagedPath is %@",imagePath)
		}

	}
	
	class func SaveImageToSources(image: UIImage)
	{
		SaveImageToDisk(image)
		SaveImageToDisk(image, postfix: "igo", shouldSavePath: false)
		SaveImageToDisk(image, postfix: "wai", shouldSavePath: false)
	}
	
	class func InstagrameFilePath() -> String
	{
		let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true);
		let documentsDirectory = paths[0] as! String
		return documentsDirectory + "/ShareMe.igo"
	}
	
	class func WhatsappFilePath() -> String
	{
		let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true);
		let documentsDirectory = paths[0] as! String
		return documentsDirectory + "/ShareMe.wai"
	}

}