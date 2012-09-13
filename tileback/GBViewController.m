//
//  GBViewController.m
//  tileback
//
//  Created by Daniel Norton on 8/6/12.
//  Copyright (c) 2012 Daniel Norton. All rights reserved.
//


#import "GBViewController.h"
#import "GBBackgroundImageService.h"


@implementation GBViewController


#pragma mark -
#pragma mark UIViewController
- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
		
		[[UIApplication sharedApplication] setStatusBarHidden:YES];
	}
}

- (void)viewWillLayoutSubviews {
	
	[super viewWillLayoutSubviews];
	[self setBackgroundImageForOrientation:self.interfaceOrientation];
}

- (NSUInteger)supportedInterfaceOrientations {
	
	return UIInterfaceOrientationMaskAll;
}


#pragma mark -
#pragma mark Private Messages
- (void)setBackgroundImageForOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
	// This might be a bug in iOS6 beta 3.
	CGRect frame = (UIInterfaceOrientationIsLandscape(interfaceOrientation))
		? CGRectMake(0.0f, 0.0f, self.view.frame.size.height, self.view.frame.size.width)
		: self.view.frame;
	
	self.background.image = [GBBackgroundImageService cacheImageWithName:@"Disks" forFrame:frame];
}

@end
