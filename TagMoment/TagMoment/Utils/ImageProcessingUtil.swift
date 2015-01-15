//
//  ImageProcessingUtil.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 1/2/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit

class ImageProcessingUtil: NSObject {
	class func maskImageWithImage(frontImage: UIImage,backImage: UIImage, mask: TMMask) -> UIImage?{
		
		
		
		return nil;
	}
	
	class func maskViewWithView(frontView: UIView,backImage: UIView, mask: TMMask) -> UIImage?{
				
		
		
		return nil;
	}
	
	class func blurImage(source: UIImage) -> UIImage{
		
//		var context = CIContext(options: nil)
//		let inputImage = CIImage(image: source)
//		
//		
//		var filter = CIFilter(name: "CIGaussianBlur")
//		filter.setValue(inputImage, forKey: kCIInputImageKey)
//		filter.setValue(15.0, forKey: "inputRadius")
		
		
		// setting up Gaussian Blur (we could use one of many filters offered by Core Image)
		//		CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
		//		[filter setValue:inputImage forKey:kCIInputImageKey];
		//		[filter setValue:[NSNumber numberWithFloat:15.0f] forKey:@"inputRadius"];
		//		CIImage *result = [filter valueForKey:kCIOutputImageKey];
		//
		//		// CIGaussianBlur has a tendency to shrink the image a little,
		//		// this ensures it matches up exactly to the bounds of our original image
		//		CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
		//
		//		UIImage *returnImage = [UIImage imageWithCGImage:cgImage];//create a UIImage for this function to "return" so that ARC can manage the memory of the blur... ARC can't manage CGImageRefs so we need to release it before this function "returns" and ends.
		//		CGImageRelease(cgImage);//release CGImageRef because ARC doesn't manage this on its own.
		
		//		return returnImage;
		return UIImage();
	}
}
