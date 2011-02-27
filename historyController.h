//
//  historyController.h
//  mrimSMS
//
//  Created by Алексеев Влад on 25.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class mrimSMS_AppDelegate;
@class mrimSMSAppController;
@class toolbarController;
@class mainController;
@class MRIMHistoryArrayController;

@interface historyController : NSObject {
	IBOutlet mrimSMS_AppDelegate *appDelegate;
	IBOutlet toolbarController *toolbar;
	
	IBOutlet MRIMHistoryArrayController *historyArrayController;
	IBOutlet NSTextField *numberOfResults;
	
	IBOutlet NSSegmentedControl *deleteButton;
	IBOutlet NSSegmentedControl *forwardButton;
	
	NSTimer *notifyUnreadMessagesTimer;
	
	NSSortDescriptor *currentSortDescriptor;
}

-(void)MRIMHistoryArrayControllerDidRemove:(MRIMHistoryArrayController *)controller;
-(void)MRIMHistoryArrayControllerDidAdd:(MRIMHistoryArrayController *)controller;

-(void)playNotifySound;
-(void)setDockUnreadMessagesBadge;
-(void)setNumberOfMessages;
-(void)setForwardButtonEnabled:(BOOL)state;
-(void)addHistoryItemWithDate:(NSDate *)date person:(NSString *)person phone:(NSString *)ph message:(NSString *)msg income:(BOOL)income unread:(BOOL)unread;
-(IBAction)forwardSelectedMessage:(id)sender;
-(IBAction)filterHistory:(id)sender;

@end
