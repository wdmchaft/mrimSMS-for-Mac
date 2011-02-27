//
//  MRIMHistoryArrayController.h
//  mrimSMS
//
//  Created by Алексеев Влад on 28.07.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface MRIMHistoryArrayController : NSArrayController {
	id _delegate;
}
- (id)delegate;
- (void)setDelegate:(id)new_delegate;

- (NSDictionary *)recentNumbers;

@end
