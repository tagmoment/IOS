#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CLCloudinary.h"
#import "CLEagerTransformation.h"
#import "CLLayer.h"
#import "Cloudinary.h"
#import "CLTransformation.h"
#import "CLUploader.h"
#import "NSDictionary+CLUtilities.h"
#import "NSString+CLURLEncoding.h"

FOUNDATION_EXPORT double CloudinaryVersionNumber;
FOUNDATION_EXPORT const unsigned char CloudinaryVersionString[];
