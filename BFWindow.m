//
//  BFWindow.m
//  mrimSMS
//
//  Created by Алексеев Влад on 15.01.11.
//  Copyright 2011 beefon software. All rights reserved.
//

#import "BFWindow.h"

@implementation BFWindow

- (id)initWithContentRect:(NSRect)contentRect 
				styleMask:(NSUInteger)aStyle 
				  backing:(NSBackingStoreType)bufferingType 
					defer:(BOOL)flag {
	self = [super initWithContentRect:contentRect 
							styleMask:NSBorderlessWindowMask 
							  backing:bufferingType 
								defer:flag];
	[self setOpaque:NO];
	[self setBackgroundColor:[NSColor clearColor]];
	return self;
}

@end
