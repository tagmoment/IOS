//
//  ImageProcessingUtil.swift
//  TagMoment
//
//  Created by Tomer Hershkowitz on 1/2/15.
//  Copyright (c) 2015 TagMoment. All rights reserved.
//

import UIKit
import AVFoundation

class ImageProcessingUtil: NSObject {
	
	class func imageFromVideoView(workingView: UIView, originalImage: UIImage, shouldMirrorImage: Bool) -> UIImage
	{
		let layer: AVCaptureVideoPreviewLayer = workingView.layer.sublayers[0] as AVCaptureVideoPreviewLayer
		
		let outputRect = layer.metadataOutputRectOfInterestForRect(workingView.bounds)
		var originalSize = originalImage.size
		var workingSize = workingView.frame.size
		workingSize.height *= 2
		workingSize.width *= 2
		if (UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation))
		{
			var temp = originalSize.width
			originalSize.width = originalSize.height
			originalSize.height = temp
			
			temp = workingSize.width
			workingSize.width = workingSize.height
			workingSize.height = temp
		}
		
		
		// metaRect is fractional, that's why we multiply here
		var cropRect = CGRect(x: outputRect.origin.x * originalSize.width, y: outputRect.origin.y * originalSize.height, width:outputRect.size.width * originalSize.width, height: outputRect.size.height * originalSize.height)
		
		cropRect = CGRectIntegral(cropRect);
		
		let cropCGImage = CGImageCreateWithImageInRect(originalImage.CGImage, cropRect);
		let imageOrientation = shouldMirrorImage ?  UIImageOrientation.LeftMirrored : originalImage.imageOrientation
		return UIImage(CGImage: ImageProcessingUtil.resizeCGImage(cropCGImage, toWidth: workingSize.width, toHeight: workingSize.height), scale: 1.0, orientation: imageOrientation)!
	}
	
	
	class func resizeCGImage(cgimage : CGImage, toWidth : CGFloat, toHeight: CGFloat) -> CGImage
	{
		let colorSpace = CGImageGetColorSpace(cgimage)
		let context = CGBitmapContextCreate(nil, UInt(toWidth), UInt(toHeight), CGImageGetBitsPerComponent(cgimage), CGImageGetBytesPerRow(cgimage), colorSpace, CGImageGetBitmapInfo(cgimage))
		CGContextDrawImage(context, CGRect(x: 0, y: 0, width: toWidth, height: toHeight), cgimage)
		return CGBitmapContextCreateImage(context)
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
