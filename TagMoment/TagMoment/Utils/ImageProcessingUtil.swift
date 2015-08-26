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
		let layer: AVCaptureVideoPreviewLayer = workingView.layer.sublayers[0] as! AVCaptureVideoPreviewLayer
		
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
		
		let orientation = originalImage.imageOrientation

		let cropCGImage = CGImageCreateWithImageInRect(originalImage.CGImage, cropRect);
		workingSize.width = min(workingSize.width,cropRect.width)
		workingSize.height = min(workingSize.height,cropRect.height)
		let imageOrientation = shouldMirrorImage ?  UIImageOrientation.LeftMirrored : orientation
//		return UIImage(CGImage: cropCGImage)!;
		return UIImage(CGImage: ImageProcessingUtil.resizeCGImage(cropCGImage, toWidth: workingSize.width, toHeight: workingSize.height), scale: 1.0, orientation: imageOrientation)!
	}
	
	
	class func imageByScalingAndCroppingForSize(originalImage: UIImage, viewSize : CGSize) -> UIImage
	{
		let targetSize = CGSize(width: viewSize.width*2, height: viewSize.height*2)
		let imageSize = originalImage.size
		var scaleFactor : CGFloat = 0
		var scaledHeight : CGFloat = targetSize.height
		var scaledWidth : CGFloat = targetSize.width
		var thumbnailPoint = CGPoint(x: 0.0,y: 0.0)
		
		if (!CGSizeEqualToSize(imageSize, targetSize))
		{
			let widthFactor = targetSize.width / imageSize.width;
			let heightFactor = targetSize.height / imageSize.height;
			
			scaleFactor = widthFactor > heightFactor ? widthFactor : heightFactor
			
			scaledWidth = imageSize.width * scaleFactor
			scaledHeight = imageSize.height * scaleFactor
			
			if (widthFactor > heightFactor)
			{
				thumbnailPoint.y = (targetSize.height - scaledHeight) * 0.5;
			}
			else if (widthFactor < heightFactor)
			{
				thumbnailPoint.x = (targetSize.width - scaledWidth) * 0.5;
			}
			
			
		}
		
		UIGraphicsBeginImageContext(targetSize); // this will crop
		
		var thumbnailRect = CGRectZero;
		thumbnailRect.origin = thumbnailPoint;
		thumbnailRect.size.width  = scaledWidth;
		thumbnailRect.size.height = scaledHeight;
		
		originalImage.drawInRect(thumbnailRect)
		
		
		let newImage = UIGraphicsGetImageFromCurrentImageContext();
		
		if (newImage == nil)
		{
			println("could not scale image")
		}
		
		//pop the context to get back to the default
		UIGraphicsEndImageContext()
		
		return newImage
	}
	
//	class func imageFromAlbum(workingView: UIView, originalImage: UIImage, shouldMirrorImage: Bool) -> UIImage
//	{
//		
//		var originalSize = originalImage.size
//		var workingSize = workingView.frame.size
//		workingSize.height *= 2
//		workingSize.width *= 2
//		if (UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation))
//		{
//			var temp = originalSize.width
//			originalSize.width = originalSize.height
//			originalSize.height = temp
//			
//			temp = workingSize.width
//			workingSize.width = workingSize.height
//			workingSize.height = temp
//		}
//		
//		
//		// metaRect is fractional, that's why we multiply here
////		var cropRect = CGRect(x: outputRect.origin.x * originalSize.width, y: outputRect.origin.y * originalSize.height, width:outputRect.size.width * originalSize.width, height: outputRect.size.height * originalSize.height)
////		
////		cropRect = CGRectIntegral(cropRect);
//		
//		let orientation = originalImage.imageOrientation
//		
////		let cropCGImage = CGImageCreateWithImageInRect(originalImage.CGImage, cropRect);
////		workingSize.width = min(workingSize.width,cropRect.width)
////		workingSize.height = min(workingSize.height,cropRect.height)
//		let imageOrientation = shouldMirrorImage ?  UIImageOrientation.LeftMirrored : orientation
//		//		return UIImage(CGImage: cropCGImage)!;
//		return UIImage(CGImage: ImageProcessingUtil.resizeCGImage(originalImage.CGImage, toWidth: workingSize.width, toHeight: workingSize.height), scale: 1.0, orientation: imageOrientation)!
//	}
	
	class func resizeCGImage(cgimage : CGImage, toWidth : CGFloat, toHeight: CGFloat) -> CGImage
	{
		let colorSpace = CGImageGetColorSpace(cgimage)
		let context = CGBitmapContextCreate(nil, Int(toWidth), Int(toHeight), CGImageGetBitsPerComponent(cgimage), CGImageGetBytesPerRow(cgimage), colorSpace, CGImageGetBitmapInfo(cgimage))
		CGContextDrawImage(context, CGRect(x: 0, y: 0, width: toWidth, height: toHeight), cgimage)
		return CGBitmapContextCreateImage(context)
	}
	
	
	class func minSizeFromSize(size : CGSize) -> CGSize
	{
		let minScaledDimension = min(size.width, size.height)/UIScreen.mainScreen().scale
		return CGSize(width: minScaledDimension, height: minScaledDimension)
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
