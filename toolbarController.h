//
//  toolbarController.h
//  mrimSMS
//
//  Created by Алексеев Влад on 26.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface toolbarController : NSObject {
	IBOutlet NSImageView *connectionStatus;
	IBOutlet NSSegmentedControl *mainSwitch;
	IBOutlet NSSegmentedControl *historySwitch;
	IBOutlet NSSegmentedControl *loginSwitch;
	IBOutlet NSTextField *emailAddressLabel;
}

@property(readonly) NSSegmentedControl *mainSwitch;
@property(readonly) NSSegmentedControl *historySwitch;
@property(readonly) NSSegmentedControl *loginSwitch;

-(void)setMainSwitchOn;
-(void)setLoginSwitchOn;
-(void)setHistorySwitchOn;
-(void)setStatusImage:(NSString *)imageFilename;
-(NSString *)currentTab;
-(void)setEmailAddress:(NSString *)email;

@end
