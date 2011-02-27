//
//  mrimSMS_AppDelegate.h
//  mrimSMS
//
//  Created by ???????? ???? on 10.05.09.
//  Copyright __MyCompanyName__ 2009 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class mrimSMSAppController;

@interface mrimSMS_AppDelegate : NSObject 
{
    IBOutlet NSWindow *window;
    
    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	
	IBOutlet mrimSMSAppController *appController;
}
@property(readonly) NSWindow *window;
@property (readonly) mrimSMSAppController *appController;

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;
- (NSManagedObjectModel *)managedObjectModel;
- (NSManagedObjectContext *)managedObjectContext;

- (IBAction)saveAction:sender;

@end
