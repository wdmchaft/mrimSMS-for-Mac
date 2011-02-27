//
//  mrimSMSAppController.h
//  mrimSMS
//
//  Created by Алексеев Влад on 25.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#import "CGSPrivate.h"
#import <AddressBook/AddressBook.h>
#import <AddressBook/ABPeoplePickerView.h>
#import "EMKeychainItem.h"
#import "EMKeychainProxy.h"
#import "mrimProtocol.h"

@class toolbarController;
@class mrimProtocol;
@class mainController;
@class historyController;

@interface mrimSMSAppController : NSObject <BFMRIMDelegateProtocol> {
	IBOutlet NSWindow *window;
	IBOutlet NSPanel *preferencesPanel;
	IBOutlet NSView *main;
	IBOutlet NSView *history;
	IBOutlet NSView *login;
	
	IBOutlet NSTextField *usernameField;
	IBOutlet NSSecureTextField *passwordField;
	IBOutlet NSButton *keychainCheckBox;
	
	IBOutlet NSView *targetToolbarView;
	IBOutlet NSView *targetMainView;
	IBOutlet NSView *toolbarButtonsView;
	
	IBOutlet toolbarController *toolbarManager;
	IBOutlet historyController *historyManager;
	IBOutlet mainController *mainManager;
	mrimProtocol *mrim;
	
	IBOutlet NSProgressIndicator *loginSpinner;
}

@property(readonly) mainController *mainManager;
@property(readonly) historyController *historyManager;
@property(readonly) toolbarController *toolbarManager;

- (IBAction)openPreferencesPanel:(id)sender;
- (IBAction)closePreferencesPanel:(id)sender;

- (IBAction)login:(id)sender;

- (IBAction)switchToMain:(id)sender;
- (IBAction)switchToHistory:(id)sender;
- (IBAction)switchToLogin:(id)sender;

- (void)_logout;
- (void)_loginAnimated:(BOOL)animated;
- (void)_switchToMainAnimated:(BOOL)animated;

- (NSString *)fullNameForPhone:(NSString *)ph withAlternativeText:(NSString *)text;
- (NSString *)fullNameForFirstName:(NSString *)fn andLastName:(NSString *)ln;
//- (void)turnWindow:(NSWindow *)wdw withAnimation:(int)anim direction:(CGSTransitionOption)toption;

- (void)sendMessage:(NSString *)messageText toNumber:(NSString *)phoneNumber;
- (BOOL)trySetPasswordField;
- (void)_logout;
- (void)autostart;

@end
