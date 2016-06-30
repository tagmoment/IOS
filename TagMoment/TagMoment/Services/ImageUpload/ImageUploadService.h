//
//  ImageUploadService.h
//  TagMoment
//
//  Created by Tomer Hershkowitz on 26/06/2016.
//  Copyright © 2016 TagMoment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Cloudinary/Cloudinary.h"

@interface ImageUploadService : NSObject
+ (ImageUploadService*)sharedInstance;
- (void)uploadImageWithURI:(NSString*)path;
- (void)uploadImage:(UIImage*)image;
@end
