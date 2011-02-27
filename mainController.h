//
//  mainController.h
//  mrimSMS
//
//  Created by Алексеев Влад on 27.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AddressBook/AddressBook.h>
#import <AddressBook/ABPeoplePickerView.h>

@class mrimSMSAppController;
@class toolbarController;
@class historyController;
@class MRIMHistoryArrayController;

@interface mainController : NSObject {
	IBOutlet ABPeoplePickerView *peoplePicker;
	IBOutlet NSTableView *recentlyUsedPhonesTableView;
	
	IBOutlet NSSegmentedControl *sendButton;
	IBOutlet NSTextField *phoneNumberField;
	IBOutlet NSTextField *messageField;
	IBOutlet NSMenuItem *sendMenuItem;
	BOOL sendMenuItemEnabled;
	NSTimer *minutePauseTimer;
	double secondsToNextMessage;
	IBOutlet NSProgressIndicator *minutePauseIndicator;
	IBOutlet NSTextField *messageLengthField;
	
	IBOutlet mrimSMSAppController *appController;
	IBOutlet toolbarController *toolbar;
	IBOutlet historyController *historyManager;
	
	IBOutlet NSTableColumn *recentNumbersColumn;
	
	IBOutlet MRIMHistoryArrayController *historyArrayController;
	
	NSString *oldPhoneNumber;
	NSString *oldMessage;
}

@property BOOL sendMenuItemEnabled;

-(IBAction)sendMessage:(id)sender;
-(void)setMessageLength;
-(void)setMessageText:(NSString *)text;
-(void)setPhoneNumber:(NSString *)phoneNumber;

@end
