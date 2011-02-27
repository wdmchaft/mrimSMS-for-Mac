//
//  MRIMHistoryArrayController.m
//  mrimSMS
//
//  Created by Алексеев Влад on 28.07.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MRIMHistoryArrayController.h"
#import "mrimModelManagedClass.h"

@interface NSArrayController (MRIMHistoryArrayControllerDelegate)
-(void)MRIMHistoryArrayControllerDidRemove:(MRIMHistoryArrayController *)controller;
-(void)MRIMHistoryArrayControllerDidAdd:(MRIMHistoryArrayController *)controller;
@end

@implementation MRIMHistoryArrayController

- (id)delegate
{
    return _delegate;
}

- (void)setDelegate:(id)new_delegate
{
    _delegate = new_delegate;
}

- (void)remove:(id)sender
{
	[super remove:sender];
	if ([_delegate respondsToSelector:@selector(MRIMHistoryArrayControllerDidRemove:)])
		[_delegate MRIMHistoryArrayControllerDidRemove:self];
}

- (void)add:(id)sender
{
	[super add:sender];
	if ([_delegate respondsToSelector:@selector(MRIMHistoryArrayControllerDidAdd:)])
		[_delegate MRIMHistoryArrayControllerDidAdd:self];
}

- (NSDictionary *)recentNumbers {
	NSArray *allObjects = [self arrangedObjects];
	
	NSMutableDictionary *recentNumbers = [NSMutableDictionary dictionary];
	
	for (mrimModelManagedClass *managedObject in allObjects) {
		NSString *phoneNumber = [managedObject valueForKey:@"phoneNumber"];
		NSNumber *numberOfMessages = [recentNumbers objectForKey:phoneNumber];
		if (numberOfMessages == nil) {
			numberOfMessages = [NSNumber numberWithInt:1];
			[recentNumbers setObject:numberOfMessages forKey:phoneNumber];
		}
		else {
			NSInteger iNumber = [numberOfMessages intValue];
			iNumber++;
			numberOfMessages = [NSNumber numberWithInt:iNumber];
			[recentNumbers setObject:numberOfMessages forKey:phoneNumber];
		}
	}
	return recentNumbers;
}
@end
