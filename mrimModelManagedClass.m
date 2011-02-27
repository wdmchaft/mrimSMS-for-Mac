//
//  mrimModelManagedClass.m
//  mrimSMS
//
//  Created by Алексеев Влад on 26.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "mrimModelManagedClass.h"
#import "mrimSMSAppController.h"
#import "mrimSMS_AppDelegate.h"

@implementation mrimModelManagedClass

-(NSString *)person
{
	mrimSMSAppController *appController = [[[NSApplication sharedApplication] delegate] appController];
	NSString *phone;
	[self willAccessValueForKey:@"phoneNumber"];
	phone = [self primitiveValueForKey:@"phoneNumber"];
	[self didAccessValueForKey:@"phoneNumber"];
	
	return [appController fullNameForPhone:phone withAlternativeText:phone];
}

-(NSData *)historyItemImage
{
	BOOL isIncome;
	[self willAccessValueForKey:@"income"];
	isIncome = [[self primitiveValueForKey:@"income"] boolValue];
	[self didAccessValueForKey:@"income"];

	NSData *data;
	NSImage *img;
	
	if (isIncome) {
		img = [NSImage imageNamed:@"InMailbox.png"];
	} else {
		img = [NSImage imageNamed:@"SentMailbox.png"];
	}
	data = [img TIFFRepresentation];
	return data;
}

@end
