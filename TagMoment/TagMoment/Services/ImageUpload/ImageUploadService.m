//
//  ImageUploadService.m
//  TagMoment
//
//  Created by Tomer Hershkowitz on 26/06/2016.
//  Copyright © 2016 TagMoment. All rights reserved.
//

#import "ImageUploadService.h"
#import "TagMoment-Swift.h"

static NSString* const CloudinaryURI = @"cloudinary://869196135557778:3nmbtPmTjfaJsV4RY_XlO3N3NEs@lbuhoie2a";

@interface ImageUploadService() <CLUploaderDelegate>

@end

static ImageUploadService* sharedInstance = nil;
@implementation ImageUploadService

+ (ImageUploadService*)sharedInstance
{
	if (!sharedInstance)
	{
		sharedInstance = [ImageUploadService new];
	}
	
	return sharedInstance;
}

- (void)uploadImage:(UIImage*)image
{
	[self performSelectorInBackground:@selector(defferedUpload:) withObject:image];
	
}

- (void)uploadImageWithURI:(NSString*)path
{
	if (![path hasPrefix:@"file://"])
	{
		path = [NSString stringWithFormat:@"file://%@", path];
	}
	
	NSData* data = [NSData dataWithContentsOfFile:path];
	[self upload:data];
}

- (void)defferedUpload:(UIImage*)image
{
	NSData* data = UIImageJPEGRepresentation(image, 0.7);
	[self upload:data];
}

- (void)upload:(NSData*)data
{
	CLCloudinary* cloudinary = [[CLCloudinary alloc] initWithUrl:CloudinaryURI];
	CLUploader* uploader = [[CLUploader alloc] init:cloudinary delegate:self];
	
	[uploader upload:data options:@{}];
}
- (void)uploaderSuccess:(NSDictionary *)result context:(id)context
{
	NSLog(@"Success");
}

- (void)uploaderError:(NSString *)result code:(NSInteger)code context:(id)context
{
	NSLog(@"Error! + %@", result);
}
@end
