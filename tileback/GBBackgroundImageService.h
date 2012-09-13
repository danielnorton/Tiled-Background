//
//  GBBackgroundImageService.h
//  tileback
//
//  Created by Daniel Norton on 8/6/12.
//  Copyright (c) 2012 Daniel Norton. All rights reserved.
//


@interface GBBackgroundImageService : NSObject

// Creates and returns an image sized to 'frame', composed of a repeating 'image' overlayed with 'colors'
+ (UIImage *)imageRepeatingImage:(UIImage *)image forFrame:(CGRect)frame withColors:(NSArray *)colors;

// Pulls an image from the cache with name of 'key'. If none exists, uses remaining parameters to create the
// cache element and then return it
+ (UIImage *)cacheImageWithKey:(NSString *)key repeatingImage:(UIImage *)image forFrame:(CGRect)frame withColors:(NSArray *)colors;

// Uses defaults for +(UIImage*)cacheImageWithKey:repeatingImage:forFrame:withColors:.
// Particularly, imageName serves as the name of the repeated image and the key to the cache
+ (UIImage *)cacheImageWithName:(NSString *)imageName forFrame:(CGRect)frame;


// Default gradiant overlay colors
+ (NSArray *)defaultColors;

@end
