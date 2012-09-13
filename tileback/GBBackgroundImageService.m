//
//  GBBackgroundImageService.m
//  tileback
//
//  Created by Daniel Norton on 8/6/12.
//  Copyright (c) 2012 Daniel Norton. All rights reserved.
//

#import "GBBackgroundImageService.h"

@implementation GBBackgroundImageService


static NSArray *_defaultColors;


#pragma mark -
#pragma mark NSObject
+ (void)initialize {

	_defaultColors = @[
		[UIColor colorWithWhite:0.0f alpha:0.75f],
		[UIColor colorWithWhite:0.0f alpha:0.0f]
	];
}


#pragma mark -
#pragma mark GBBackgroundImageService
#pragma mark Public Messages
+ (UIImage *)imageRepeatingImage:(UIImage *)image forFrame:(CGRect)frame withColors:(NSArray *)colors {
	
	// Get the color ref's. If none, return the input image.
	NSMutableArray *colorRefs = [NSMutableArray arrayWithCapacity:0];
	[colors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		
		if (![obj isKindOfClass:[UIColor class]]) return;
		
		UIColor *color = (UIColor *)obj;
		[colorRefs insertObject:(id)color.CGColor atIndex:idx];
	}];
	
	if (colorRefs.count == 0) return image;
	
	// set up sizes and rects
	float frameScale = [UIScreen mainScreen].scale;
	CGSize frameSize = frame.size;
	CGRect imageRect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
	
	// begin drawing
	UIGraphicsBeginImageContextWithOptions(frameSize, YES, frameScale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, frameSize.height);
    CGContextScaleCTM(context, 1.0, -1.0);
	
	// tile the image
	CGContextSetBlendMode(context, kCGBlendModeNormal);
	CGContextDrawTiledImage(context, imageRect, image.CGImage);
	
	// draw the gradient
	CGContextSetBlendMode(context, kCGBlendModeHardLight);
	CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
	CGGradientRef gradient = CGGradientCreateWithColors(space, (__bridge CFArrayRef)colorRefs, NULL);
	CGContextDrawLinearGradient(context, gradient, CGPointMake(0.0f, 0.0f), CGPointMake(0.0f, frameSize.height), 0);
	
	// cleanup and return
	UIImage *gradientImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return gradientImage;
}

+ (UIImage *)cacheImageWithKey:(NSString *)key repeatingImage:(UIImage *)image forFrame:(CGRect)frame withColors:(NSArray *)colors {
	
	if ([self hasCacheForKey:key forFrame:frame]) {
	
		return [self cachedImageForKey:key forFrame:frame];
	}
	
	UIImage *newImage = [self imageRepeatingImage:image forFrame:frame withColors:colors];
	[self enCacheImage:newImage forKey:key forFrame:frame];
	return newImage;
}

+ (UIImage *)cacheImageWithName:(NSString *)imageName forFrame:(CGRect)frame {
	
	return [self cacheImageWithKey:imageName repeatingImage:[UIImage imageNamed:imageName] forFrame:frame withColors:_defaultColors];
}

+ (NSArray *)defaultColors {
	
	return _defaultColors;
}

#pragma mark Private Messages
+ (BOOL)hasCacheForKey:(NSString *)key forFrame:(CGRect)frame {
	
	NSFileManager *mgr = [[NSFileManager alloc] init];
	NSString *path = [self pathForKey:key forFrame:frame];
	return [mgr fileExistsAtPath:path];
}

+ (void)enCacheImage:(UIImage *)image forKey:(NSString *)key forFrame:(CGRect)frame {
	
	NSFileManager *mgr = [[NSFileManager alloc] init];
	NSString *path = [self pathForKey:key forFrame:frame];
	NSURL *url = [NSURL fileURLWithPath:path];
	
	NSError *dirError = nil;
	if (![mgr createDirectoryAtURL:url withIntermediateDirectories:YES attributes:nil error:&dirError]) {
		
		NSLog(@"Could not create directory for: %@", path);
		return;
	}
	

	NSError *removeError = nil;
	if ([mgr fileExistsAtPath:path] && ![mgr removeItemAtPath:path error:&removeError]) {
			
		NSLog(@"Could not delete file at: %@", path);
	}

	NSData *data = UIImagePNGRepresentation(image);
	if ([mgr createFileAtPath:path contents:data attributes:nil]) {
		
		
		NSError *resError = nil;
		if (![url setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:&resError]) {
			
			NSLog(@"Could not set excluded key for: %@", path);
		}
	} else {
		
		NSLog(@"Could not create file at: %@", path);
	}
}

+ (UIImage *)cachedImageForKey:(NSString *)key forFrame:(CGRect)frame {
	
	NSFileManager *mgr = [[NSFileManager alloc] init];
	NSString *path = [self pathForKey:key forFrame:frame];
	
	NSData *raw = [mgr contentsAtPath:path];
	if (!raw) return nil;
	
	return [UIImage imageWithData:raw];
}

+ (NSString *)pathForKey:(NSString *)key forFrame:(CGRect)frame {

	float frameScale = [UIScreen mainScreen].scale;
	CGSize frameSize = CGSizeMake(frame.size.width * frameScale, frame.size.height * frameScale);
	
	NSString *fileName = [NSString stringWithFormat:@"%@_%.0f_%.0f.png", key, frameSize.width, frameSize.height];
	return [[self rootPath] stringByAppendingPathComponent:fileName];
}

+ (NSString *)rootPath {
	
	return [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
}

@end

