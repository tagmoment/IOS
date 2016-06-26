//
//  ImageUploadService.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 19/06/2016.
//  Copyright © 2016 TagMoment. All rights reserved.
//

import UIKit

class ImageUploadService: NSObject, CLUploaderDelegate{
	
	private static var instance : ImageUploadService?
	
	static func SharedInstance() -> ImageUploadService
	{
		if (instance == nil)
		{
			instance = ImageUploadService()
		}
		
		return instance!
	}
	
	func uploadImageWithURI(path: String)
	{
		var newPath = path;
		if (!newPath.hasPrefix("file://"))
		{
			newPath = NSURL(fileURLWithPath: "file://" + path).absoluteString
		}
		
		let cloudinary = CLCloudinary(url: ThirdPartyDefs.CloudinaryUri)
		let uploader = CLUploader(cloudinary, delegate: self)
		
		uploader.upload(path as NSString, options: [NSObject : AnyObject]())
	}
	
	func uploaderSuccess(result: [NSObject : AnyObject]!, context: AnyObject!) {
		print("Success!!")
	}
	
	func uploaderError(result: String!, code: Int, context: AnyObject!) {
		print("Error! + \(result)")
	}
}
