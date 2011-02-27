//
//  mrimSMSAppController.m
//  mrimSMS
//
//  Created by Алексеев Влад on 25.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "mrimSMSAppController.h"
#import "toolbarController.h"
#import "mrimProtocol.h"
#import "mainController.h"
#import "historyController.h"
#import "EMKeychainItem.h"
#import "EMKeychainProxy.h"

#import "CGSPrivate.h"

NSString * const BEE_mrimSMS_SaveInKeychain = @"mrim_AutoSaveToKeychain";
NSString * const BEE_mrimSMS_LastAccount = @"mrim_LatestUsedAccount";

@implementation mrimSMSAppController
@synthesize mainManager, historyManager, toolbarManager;

#pragma mark -
#pragma mark loading account data

+ (void)initialize 
{ 
    NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary]; 
	
	[defaultValues setObject:[NSKeyedArchiver archivedDataWithRootObject:@""] 
					  forKey:BEE_mrimSMS_LastAccount]; 
    [defaultValues setObject:[NSNumber numberWithBool:YES] 
					  forKey:BEE_mrimSMS_SaveInKeychain]; 
	
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues]; 
} 

-(BOOL)saveInKeychain
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; 
    return [defaults boolForKey:BEE_mrimSMS_SaveInKeychain]; 
}

-(NSString *)latestAccount
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; 
    NSData *accountAsData = [defaults objectForKey:BEE_mrimSMS_LastAccount]; 
    NSString *latestAccount = [NSKeyedUnarchiver unarchiveObjectWithData:accountAsData];
	NSLog(@"appController.latestAccount: loaded %@", latestAccount);
	return latestAccount;
}

-(void)writeDefaults
{
	NSLog(@"appController.writeDefaults: writing defaults");
	NSData *stringAsData = [NSKeyedArchiver archivedDataWithRootObject:[usernameField stringValue]]; 
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults]; 
	[defaults setObject:stringAsData forKey:BEE_mrimSMS_LastAccount];
	[defaults setBool:[keychainCheckBox state] forKey:BEE_mrimSMS_SaveInKeychain]; 
}

#pragma mark Autostart if account loaded

- (void)autostart
{
	[self _logout];
	[[[NSApplication sharedApplication] mainMenu] setAutoenablesItems:NO];
	[targetToolbarView addSubview:toolbarButtonsView];
	[historyManager setForwardButtonEnabled:NO];
	[login setFrame:[targetMainView frame]];
	[targetMainView addSubview:login];
	[self switchToLogin:nil];
	mrim = [[mrimProtocol alloc] init];
	[mrim setDelegate:self];
	
	[usernameField setStringValue:[self latestAccount]];
	if ([self trySetPasswordField]) {
		[self login:nil];
	}
}

#pragma mark -
#pragma mark Actions


#pragma mark preferences panel actions

-(IBAction)openPreferencesPanel:(id)sender
{
	[NSApp beginSheet:preferencesPanel modalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
}

-(IBAction)closePreferencesPanel:(id)sender
{
	[NSApp endSheet:preferencesPanel];
	[preferencesPanel orderOut:window];
}

#pragma mark Main UI

-(IBAction)login:(id)sender {
	[loginSpinner startAnimation:self];
	[mrim setUsername:[usernameField stringValue]];
	[mrim setPassword:[passwordField stringValue]];
	[mrim setOperation:BFMRIMOperationGettingServerAddress];
	[mrim connectToHost:@"mrim.mail.ru"];
}

#pragma mark Tab switching

-(IBAction)switchToMain:(id)sender
{
	[self _switchToMainAnimated:YES];
}

-(IBAction)switchToHistory:(id)sender
{
	[historyManager setDockUnreadMessagesBadge];
	[toolbarManager setHistorySwitchOn];
	[historyManager setNumberOfMessages];
	NSView *oldView = [[targetMainView subviews] objectAtIndex:0];
	if (oldView != history)
	{
		[history setFrame:[targetMainView frame]];
		[targetMainView replaceSubview:[[targetMainView subviews] objectAtIndex:0] with:history];
		if (oldView == login)
			[self turnWindow:window withAnimation:CGSFlip direction:CGSUp];
		else if (oldView == main)
			[self turnWindow:window withAnimation:CGSFlip direction:CGSRight];
		else if (oldView == history)
			[self turnWindow:window withAnimation:CGSFlip direction:CGSLeft];
	}
}

- (IBAction)switchToLogin:(id)sender
{
	[self _logout];
	[historyManager setDockUnreadMessagesBadge];
	[toolbarManager setLoginSwitchOn];
	NSView *oldView = [[targetMainView subviews] objectAtIndex:0];
	if (oldView != login) {
		[login setFrame:[targetMainView frame]];
		[targetMainView replaceSubview:[[targetMainView subviews] objectAtIndex:0] with:login];
		[self turnWindow:window withAnimation:CGSFlip direction:CGSDown];
		[mrim disconnect];
	}
}

#pragma mark Private Methods

-(void)_switchToMainAnimated:(BOOL)animated
{
	[historyManager setDockUnreadMessagesBadge];
	[toolbarManager setMainSwitchOn];
	NSView *oldView = [[targetMainView subviews] objectAtIndex:0];
	if (oldView != main)
	{
		[main setFrame:[targetMainView frame]];
		[targetMainView replaceSubview:[[targetMainView subviews] objectAtIndex:0] with:main];
		if (animated)
		{
			if (oldView == login)
				[self turnWindow:window withAnimation:CGSFlip direction:CGSUp];
			else if (oldView == main)
				[self turnWindow:window withAnimation:CGSFlip direction:CGSRight];
			else if (oldView == history)
				[self turnWindow:window withAnimation:CGSFlip direction:CGSLeft];
		}
	}
}

-(void)_logout
{
	[toolbarManager setStatusImage:@"redlight.tiff"];
	[[toolbarManager mainSwitch] setEnabled:NO];
	[historyManager setForwardButtonEnabled:NO];
	[mainManager setSendMenuItemEnabled:NO];
}

-(void)_loginAnimated:(BOOL)animated
{	
	[toolbarManager setStatusImage:@"greenlight.tiff"];
	[[toolbarManager mainSwitch] setEnabled:YES];
	[mainManager setSendMenuItemEnabled:YES];
	[mainManager setMessageLength];
	[historyManager setForwardButtonEnabled:YES];
	[toolbarManager setEmailAddress:[usernameField stringValue]];
	[mainManager setMessageText:@""];
	
	[self writeDefaults];
	if ([keychainCheckBox state] == NSOnState)
	{
		NSLog(@"appController._loginAnimated: saving credentials to keychain");
		// теперь можно сохранить данные в Keychain
		[[EMKeychainProxy sharedProxy] addGenericKeychainItemForService:@"mrimSMS" 
														   withUsername:[usernameField stringValue] 
															   password:[passwordField stringValue]];
	}
	[self _switchToMainAnimated:animated];
}

#pragma mark -

-(void)alertDidEnd:(NSAlert *)alert returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	if (returnCode == NSCancelButton)
		[self login:self];
}

-(NSString *)fullNameForPhone:(NSString *)ph withAlternativeText:(NSString *)text
{
	ABAddressBook *AB = [ABAddressBook sharedAddressBook];
	ABSearchElement *searchNameForPhone =
    [ABPerson searchElementForProperty:kABPhoneProperty
                                 label:nil
                                   key:nil
                                 value:ph
                            comparison:kABEqualCaseInsensitive];
	NSArray *peopleFound = [AB recordsMatchingSearchElement:searchNameForPhone];
	
	NSString *senderName = nil;
	if ([peopleFound count] == 1)
	{
		ABPerson *person = [peopleFound objectAtIndex:0];
		senderName = [self fullNameForFirstName:[person valueForProperty:kABFirstNameProperty] 
									andLastName:[person valueForProperty:kABLastNameProperty]];
	}
	
	if (senderName == nil)
		senderName = text;
	//NSLog(@"returning %@", senderName);
	return senderName;
}

-(NSString *)fullNameForFirstName:(NSString *)fn andLastName:(NSString *)ln
{
	NSString *senderName = nil;
	if ((ln) && (fn))
		senderName = [NSString stringWithFormat:@"%@ %@", ln, fn];
	if ((!ln) && (fn))
		senderName = [NSString stringWithFormat:@"%@", fn];
	if ((ln) && (!fn))
		senderName = [NSString stringWithFormat:@"%@", ln];
	return senderName;
}

-(void)mrimOfflineMessageFrom:(NSString *)from withText:(NSString *)text atDate:(NSDate *)datetime
{
	NSString *sender = [self fullNameForPhone:from withAlternativeText:from];

	[historyManager addHistoryItemWithDate:datetime 
									person:sender 
									 phone:from 
								   message:text 
									income:YES
									unread:YES];
	[historyManager playNotifySound];
}

-(void)turnWindow:(NSWindow *)wdw withAnimation:(int)anim direction:(CGSTransitionOption)toption{
	int widnum = [wdw windowNumber];
	if(!widnum) return;
	[wdw orderFront:0];
	int handle = -1;
	CGSTransitionSpec spec;
	spec.unknown1 = 0;
	spec.type = anim;
	spec.option = toption | (1<<7);
	spec.backColour = 0;
	spec.wid = widnum;
	CGSConnection cgs= _CGSDefaultConnection();
	CGSNewTransition(cgs, &spec, &handle);
	
	[wdw display];
	
	CGSInvokeTransition(cgs, handle, 0.5);
	
	usleep((useconds_t)(0.5*1000000));
	CGSReleaseTransition(cgs, handle);
}

- (void)sendMessage:(NSString *)messageText toNumber:(NSString *)phoneNumber
{
	if ([messageText isEqualToString:@""]) {
		NSLog(@"appController.sendMessage: attempt to send empty message");
		return;
	}
	if ([phoneNumber isEqualToString:@""]) {
		return;
	}
	
	[mrim sendSMSToNumber:phoneNumber withText:messageText];
}

-(BOOL)trySetPasswordField
{
	EMGenericKeychainItem *keychainItem = [[EMKeychainProxy sharedProxy] genericKeychainItemForService:@"mrimSMS" 
																						  withUsername:[usernameField stringValue]];
	NSString *password = [keychainItem password];
	if (password != nil)
	{
		[passwordField setStringValue:password];
		return YES;
	}
	else
	{
		[passwordField setStringValue:@""];
		return NO;
	}
}

- (void)controlTextDidChange:(NSNotification *)n
{
	if ([n object] == usernameField)
	{
		[self trySetPasswordField];
	}
}

#pragma mark -
#pragma mark mrim delegate

- (void)mrimObject:(mrimProtocol *)mrimObject didReceiveServerAddress:(NSString *)address {
	[mrim setOperation:BFMRIMOperationConnecting];
	NSString *hostAddress = [address substringToIndex:[address rangeOfString:@":"].location];
	NSLog(@"app.didReceiveServerAddress: %@", hostAddress);
	[mrim setMrimServerAddress:hostAddress];
	// и ждем отключения
}

- (void)mrimObject:(mrimProtocol *)mrimObject didConnectToHost:(NSString *)address {
	NSLog(@"app.didConnectToHost: %@", address);
	if ([mrim operation] == BFMRIMOperationGettingServerAddress) {
		[mrim serverAddress];
	}
	
	if ([mrim operation] == BFMRIMOperationConnecting) {
		[mrim welcomeServer];
	}
}

- (void)mrimObjectDidWelcomeServer:(mrimProtocol *)mrimObject {
	NSLog(@"app.mrimObjectDidWelcomeServer");
	[mrim setOperation:BFMRIMOperationLoggingIn];
	[mrim loginToServer];
}

- (void)mrimObject:(mrimProtocol *)mrimObject willDisconnectWithError:(NSError *)error {
	NSAlert *errorAlert = [NSAlert alertWithMessageText:NSLocalizedStringFromTable(@"connectionError", @"Main", nil)
										  defaultButton:@"OK" 
										alternateButton:nil 
											otherButton:nil 
							  informativeTextWithFormat:NSLocalizedStringFromTable(@"connectionErrorDescription", @"Main", nil), error];
	[errorAlert setIcon:[NSImage imageNamed:@"Network.png"]];
	[errorAlert beginSheetModalForWindow:window 
						   modalDelegate:self 
						  didEndSelector:nil 
							 contextInfo:nil];
	[[toolbarManager mainSwitch] setEnabled:NO];
	[self _logout];
	[loginSpinner stopAnimation:nil];
}

- (void)mrimObjectDidDisconnect:(mrimProtocol *)mrimObject {
	NSLog(@"app.mrimObjectDidDisconnect");
	if ([mrim operation] == BFMRIMOperationConnecting) {
		NSLog(@"   connecting for login");
		[mrim connectToHost:[mrim mrimServerAddress]];
	}
	else {
		[self switchToLogin:nil];
	}

}

- (void)mrimObjectDidLogin:(mrimProtocol *)mrimObject {
	NSLog(@"mrimObjectDidLogin");
	[mrim setOperation:BFMRIMOperationIdle];
	[self _loginAnimated:YES];
	[loginSpinner stopAnimation:self];
}

- (void)mrimObjectDidFailLogin:(mrimProtocol *)mrimObject {
	NSLog(@"mrimObjectDidFailLogin");
	[mrim setOperation:BFMRIMOperationIdle];
	[mrim disconnect];
	
	NSAlert *errorAlert = [NSAlert alertWithMessageText:NSLocalizedStringFromTable(@"connectionFail", @"Main", nil) 
										  defaultButton:@"OK" 
										alternateButton:nil 
											otherButton:nil 
							  informativeTextWithFormat:NSLocalizedStringFromTable(@"connectionFailDescription", @"Main", nil)];
	[errorAlert setIcon:[NSImage imageNamed:@"keys.png"]];
	[errorAlert beginSheetModalForWindow:window modalDelegate:nil didEndSelector:nil contextInfo:nil];
	[[toolbarManager mainSwitch] setEnabled:NO];
	[self _logout];
	[loginSpinner stopAnimation:self];
}

- (void)mrimObject:(mrimProtocol *)mrimObject didReceiveMessage:(NSDictionary *)messageInfo {
	BOOL sms = [[messageInfo objectForKey:BFKeyMessageSMS] boolValue];
	
	if (!sms) {
		return;
	}
	
	BOOL notify = [[messageInfo objectForKey:BFKeyMessageNotify] boolValue];
	NSDate *date = [messageInfo objectForKey:BFKeyMessageDate];
	NSString *type = [messageInfo objectForKey:BFKeyMessageStatus];
	NSString *phoneNumber = [messageInfo objectForKey:BFKeyMessageSender];
	NSString *messageText = [messageInfo objectForKey:BFKeyMessageText];
	
	BOOL unread = NO;
	if (type == BFKeyMessageOffline) {
		unread = YES;
	}
	
	if (!notify) {
		[historyManager addHistoryItemWithDate:date 
										person:nil 
										 phone:phoneNumber
									   message:messageText 
										income:YES 
										unread:unread];
	}
	[historyManager playNotifySound];

	if (type == BFKeyMessageOnline) {
		NSAlert *newMessageAlert = [NSAlert alertWithMessageText:[self fullNameForPhone:phoneNumber 
																	withAlternativeText:phoneNumber]
												   defaultButton:@"OK" 
												 alternateButton:nil 
													 otherButton:nil 
									   informativeTextWithFormat:messageText];
		[newMessageAlert beginSheetModalForWindow:window 
									modalDelegate:self didEndSelector:nil contextInfo:nil];		
	}
}

- (void)mrimObjectDidReceiveLogoutPacket:(mrimProtocol *)mrimObject {
	[self _logout];
	[self switchToLogin:self];
	NSAlert *logoutAlert = [NSAlert alertWithMessageText:NSLocalizedStringFromTable(@"disconnected", @"Main", nil)
										   defaultButton:@"OK" 
										 alternateButton:NSLocalizedStringFromTable(@"reconnect", @"Main", nil)
											 otherButton:nil 
							   informativeTextWithFormat:NSLocalizedStringFromTable(@"disconnectedDescription", @"Main", nil)];
	[logoutAlert setAlertStyle:NSCriticalAlertStyle];
	[logoutAlert beginSheetModalForWindow:window 
							modalDelegate:self 
						   didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:) 
							  contextInfo:nil];
}

@end
