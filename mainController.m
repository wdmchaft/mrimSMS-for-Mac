//
//  mainController.m
//  mrimSMS
//
//  Created by Алексеев Влад on 27.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "mainController.h"
#import "mrimSMSAppController.h"
#import "toolbarController.h"
#import "historyController.h"
#import "mrimSMS_AppDelegate.h"
#import "MRIMHistoryArrayController.h"
#import "mrimModelManagedClass.h"

#import <dispatch/dispatch.h>
#import "validatereceipt.h"

@implementation mainController

@synthesize sendMenuItemEnabled;

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	if (menuItem == sendMenuItem)
		return sendMenuItemEnabled;
}

-(void)setMessageLength
{
	int usernameLen = [[[appController valueForKey:@"usernameField"] stringValue] length] + 1;
	int messageLen = [[messageField stringValue] length];
	int resultLen = usernameLen + messageLen;
	int allowedLen = 0;
	
	NSCharacterSet *russianSet = [NSCharacterSet characterSetWithCharactersInString:@"йцукенгшщзхъфывапролджэёячсмитьбю"];
	NSRange russianCharsRange = [[messageField stringValue] rangeOfCharacterFromSet:russianSet 
																			options:NSCaseInsensitiveSearch];
	if (russianCharsRange.location != NSNotFound)
		allowedLen = 69;
	else
		allowedLen = 156;
	
	if (resultLen > allowedLen)
	{
		NSBeep();
		[messageField setStringValue:[[messageField stringValue] substringToIndex:(allowedLen - usernameLen)]];
		resultLen = allowedLen;
	}
	
	if ([[messageField stringValue] length] == 0)
		[sendButton setEnabled:NO];
	else
		[sendButton setEnabled:YES];
	
	[messageLengthField setIntValue:resultLen];
}

- (void)controlTextDidChange:(NSNotification *)n
{	
	if ([n object] == messageField)
	{
		[self setMessageLength];
	}
	
	if ([n object] == phoneNumberField)
	{
		int phoneNumberLen = [[phoneNumberField stringValue] length];
		if (phoneNumberLen > 13)
		{
			NSBeep();
			[phoneNumberField setStringValue:oldPhoneNumber];
		}
		oldPhoneNumber = [phoneNumberField stringValue];
	}
}

- (void)didSelectPerson:(NSNotification*)notif 
{
	NSMutableString *selectedPhoneNumber;
	@try {
		selectedPhoneNumber = [NSMutableString stringWithFormat:@"%@", [[peoplePicker selectedValues] objectAtIndex:0]];
	}
	
	@catch (NSException *e) {
		selectedPhoneNumber = [NSMutableString stringWithString:@""];
	}		
	
	[selectedPhoneNumber replaceOccurrencesOfString:@" " 
										 withString:@"" 
											options:NSCaseInsensitiveSearch 
											  range:NSMakeRange(0, [selectedPhoneNumber length])];
	if ([selectedPhoneNumber length] < 12)
	{
		[phoneNumberField setStringValue:@""];
		return;
	}
	[selectedPhoneNumber replaceOccurrencesOfString:@"-" 
										 withString:@"" 
											options:NSCaseInsensitiveSearch 
											  range:NSMakeRange(0, [selectedPhoneNumber length])];
	if ([selectedPhoneNumber length] < 12)
	{
		[phoneNumberField setStringValue:@""];
		return;
	}
	[selectedPhoneNumber replaceOccurrencesOfString:@"(" 
										 withString:@"" 
											options:NSCaseInsensitiveSearch 
											  range:NSMakeRange(0, 12)];
	if ([selectedPhoneNumber length] < 12)
	{
		[phoneNumberField setStringValue:@""];
		return;
	}
	[selectedPhoneNumber replaceOccurrencesOfString:@")" 
										 withString:@"" 
											options:NSCaseInsensitiveSearch 
											  range:NSMakeRange(0, 12)];
	if ([selectedPhoneNumber length] < 12)
	{
		[phoneNumberField setStringValue:@""];
		return;
	}
	NSRange braketsRange = [selectedPhoneNumber rangeOfString:@"("];
	if (braketsRange.location != NSNotFound)
	{
		selectedPhoneNumber = [NSMutableString stringWithString:[selectedPhoneNumber substringToIndex:braketsRange.location]];
	}
	if ([selectedPhoneNumber length] < 12)
	{
		[phoneNumberField setStringValue:@""];
		return;
	}
	
	
//	[selectedPhoneNumber replaceOccurrencesOfString:@"(" 
//										 withString:@"" 
//											options:NSCaseInsensitiveSearch 
//											  range:NSMakeRange(0, [selectedPhoneNumber length])];
//	[selectedPhoneNumber replaceOccurrencesOfString:@")" 
//										 withString:@"" 
//											options:NSCaseInsensitiveSearch 
//											  range:NSMakeRange(0, [selectedPhoneNumber length])];
	@try {
		NSInteger phoneNumberLength;
		phoneNumberLength = [selectedPhoneNumber length];
		if (phoneNumberLength > 13)
			phoneNumberLength = 13;
		[phoneNumberField setStringValue:[selectedPhoneNumber substringToIndex:phoneNumberLength]];
	}
	@catch (NSException *e) {
		[phoneNumberField setStringValue:@""];
	}
	//[self setPhone:[phoneNumberField stringValue]];
}

-(void)awakeFromNib
{
	minutePauseTimer = nil;
	sendMenuItemEnabled = NO;
	
	NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
	
    [center addObserver:self
			   selector:@selector(didSelectPerson:)
				   name:ABPeoplePickerValueSelectionDidChangeNotification
				 object:peoplePicker];
    [peoplePicker setAllowsMultipleSelection:NO];
	
	[[recentNumbersColumn headerCell] setTitle:NSLocalizedStringFromTable(@"recentColumn", @"Main", nil)];
}

-(void)setEnabledForSendButton:(BOOL)state {
	sendMenuItemEnabled = state;
	[sendButton setEnabled:state];
}

-(void)minutePauseTimerWork:(NSTimer *)t {
	secondsToNextMessage--;
	[minutePauseIndicator setDoubleValue:(60 - secondsToNextMessage)];
	if (secondsToNextMessage <= 0) {
		[self setEnabledForSendButton:YES];
		[sendButton setImage:[NSImage imageNamed:@"send"] forSegment:0];
		[minutePauseIndicator setHidden:YES];
		[minutePauseTimer invalidate];
		minutePauseTimer = nil;
	}
}

-(IBAction)sendMessage:(id)sender {
	[appController sendMessage:[messageField stringValue] toNumber:[phoneNumberField stringValue]];

	NSString *senderName;
	senderName = [appController fullNameForPhone:[phoneNumberField stringValue] withAlternativeText:[phoneNumberField stringValue]];
	NSSound *sound = [NSSound soundNamed:@"smsSent"];
	// воспроизводим в фоне, чтобы было параллельно с анимацией
	[NSThread detachNewThreadSelector:@selector(play) toTarget:sound withObject:nil];
	
	[historyManager addHistoryItemWithDate:[NSDate date] 
									person:senderName
									 phone:[phoneNumberField stringValue] 
								   message:[messageField stringValue] 
									income:NO
									unread:NO];
	[messageField setStringValue:@""];
	//[appController turnWindow:[appController valueForKey:@"window"] withAnimation:CGSSwap direction:CGSUp];
	
	[self setEnabledForSendButton:NO];
	[sendButton setImage:nil forSegment:0];
	[minutePauseIndicator setHidden:NO];
	secondsToNextMessage = 60;
	[minutePauseTimer invalidate];
	minutePauseTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 
												   target:self selector:@selector(minutePauseTimerWork:) 
												 userInfo:nil 
												  repeats:YES];
}

-(void)setMessageText:(NSString *)text {
	[messageField setStringValue:text];
}

-(void)setPhoneNumber:(NSString *)phoneNumber {
	[phoneNumberField setStringValue:phoneNumber];
}

#pragma mark -
#pragma mark TableView methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
	return [[[historyArrayController recentNumbers] allKeys] count];
}

- (id)tableView:(NSTableView *)aTableView 
objectValueForTableColumn:(NSTableColumn *)aTableColumn 
			row:(NSInteger)rowIndex {
	NSString *phoneNumber = [[[historyArrayController recentNumbers] allKeys] objectAtIndex:rowIndex];
	return phoneNumber;
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex {
	NSString *phoneNumber = [[[historyArrayController recentNumbers] allKeys] objectAtIndex:rowIndex];
	[self setPhoneNumber:phoneNumber];
	return YES;
}

@end
