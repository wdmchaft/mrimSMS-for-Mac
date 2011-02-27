//
//  toolbarController.m
//  mrimSMS
//
//  Created by Алексеев Влад on 26.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "toolbarController.h"


@implementation toolbarController

@synthesize mainSwitch, historySwitch, loginSwitch;

-(void)setMainSwitchOn
{
	[mainSwitch setSelected:YES forSegment:0];
	[historySwitch setSelected:NO forSegment:0];
	[loginSwitch setSelected:NO forSegment:0];
}

-(void)setLoginSwitchOn
{
	[mainSwitch setSelected:NO forSegment:0];
	[historySwitch setSelected:NO forSegment:0];
	[loginSwitch setSelected:YES forSegment:0];
}

-(void)setHistorySwitchOn
{
	[mainSwitch setSelected:NO forSegment:0];
	[historySwitch setSelected:YES forSegment:0];
	[loginSwitch setSelected:NO forSegment:0];
}

-(void)setEmailAddress:(NSString *)email
{
	[emailAddressLabel setStringValue:email];
}

-(void)setStatusImage:(NSString *)imageFilename
{
	[connectionStatus setImage:[NSImage imageNamed:imageFilename]];
}

-(NSString *)currentTab
{
	if ([mainSwitch isSelectedForSegment:0])
		return @"main";
	if ([historySwitch isSelectedForSegment:0])
		return @"history";

	return @"login";	
}


@end
