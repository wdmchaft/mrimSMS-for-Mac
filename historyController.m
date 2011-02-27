//
//  historyController.m
//  mrimSMS
//
//  Created by Алексеев Влад on 25.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "historyController.h"
#import "toolbarController.h"
#import "mrimSMSAppController.h"
#import "mrimSMS_AppDelegate.h"
#import "mainController.h"

@implementation historyController

- (void)dealloc
{
	[historyArrayController removeObserver:self forKeyPath:@"selectedObjects"];
	[super dealloc];
}

- (void)awakeFromNib
{
	currentSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
	NSArray *sortDescriptors = [NSArray arrayWithObject:currentSortDescriptor];
	[historyArrayController setSortDescriptors:sortDescriptors];
	[historyArrayController rearrangeObjects];
	[historyArrayController setFilterPredicate:nil];
	[historyArrayController setDelegate:self];
	[historyArrayController addObserver:self 
							 forKeyPath:@"selectedObjects" 
								options:NSKeyValueObservingOptionNew 
								context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
	if ([[toolbar currentTab] isEqualToString:@"history"])
	{
		if ([[historyArrayController selectedObjects] count] == 0)
			return;
		NSManagedObject *selectedMessage = [[historyArrayController selectedObjects] objectAtIndex:0];
		[selectedMessage setValue:[NSNumber numberWithBool:NO] forKey:@"isUnread"];	
		[self setDockUnreadMessagesBadge];
	}
}

-(void)MRIMHistoryArrayControllerDidRemove:(MRIMHistoryArrayController *)controller
{
	[self setDockUnreadMessagesBadge];
	[self setNumberOfMessages];
}

-(void)MRIMHistoryArrayControllerDidAdd:(MRIMHistoryArrayController *)controller
{
	[self setDockUnreadMessagesBadge];
	[self setNumberOfMessages];
}

-(void)setDockUnreadMessagesBadge
{
	NSManagedObjectContext * context  = [[NSApp delegate] managedObjectContext];
	NSManagedObjectModel   * model    = [[NSApp delegate] managedObjectModel];
	NSDictionary           * entities = [model entitiesByName];
	NSEntityDescription    * entity   = [entities valueForKey:@"SMSHistory"];
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:@"isUnread == 1"];
	
	NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
	[fetch setEntity: entity];
	[fetch setPredicate: predicate];
	
	NSArray *results = [context executeFetchRequest:fetch error:nil];
	[fetch release];
	NSDockTile *tile = [[NSApplication sharedApplication] dockTile];
	if ([results count] > 0)
	{
		//[tile setShowsApplicationBadge:YES];
		[tile setBadgeLabel:[NSString stringWithFormat:@"%d", [results count]]];
	}
	else
		[tile setBadgeLabel:nil];
		//[tile setShowsApplicationBadge:NO];
}

-(void)setNumberOfMessages
{
	NSString *localizedFormat = NSLocalizedStringFromTable(@"numberOfMessages", @"Main", nil);
	NSString *string = [NSString stringWithFormat:localizedFormat, [[historyArrayController arrangedObjects] count]];
	[numberOfResults setStringValue:string];
}

-(IBAction)filterHistory:(id)sender
{
	NSString *searchText = [sender stringValue];
	NSString *predicateString = @"(person contains[cd] %@) OR (phoneNumber contains[cd] %@) OR (message contains[cd] %@)";
	NSArray *searchTerms = [searchText componentsSeparatedByString:@" "];
	
	if ([searchText length] == 0)
	{
		[historyArrayController setFilterPredicate:nil];
		[self setNumberOfMessages];
		return;
	}
	
	if ([searchTerms count] == 1) {
		NSPredicate *p = [NSPredicate predicateWithFormat:predicateString, searchText, searchText, searchText];
		[historyArrayController setFilterPredicate:p];
	} 
	else {
		NSMutableArray *subPredicates = [[NSMutableArray alloc] init];
		for (NSString *term in searchTerms) {
			NSPredicate *p = [NSPredicate predicateWithFormat:predicateString, term, term, term];
			[subPredicates addObject:p];
		}
		NSPredicate *cp = [NSCompoundPredicate andPredicateWithSubpredicates:subPredicates];
		[historyArrayController setFilterPredicate:cp];
	}
	[self setNumberOfMessages];
}

-(void)addHistoryItemWithDate:(NSDate *)date 
					   person:(NSString *)person 
						phone:(NSString *)ph message:(NSString *)msg 
					   income:(BOOL)income unread:(BOOL)unread
{
	NSEntityDescription *entity = [[[appDelegate managedObjectModel] entitiesByName] objectForKey:@"SMSHistory"];
	NSManagedObject *newObject = [[NSManagedObject alloc] initWithEntity:entity 
										  insertIntoManagedObjectContext:[appDelegate managedObjectContext]];
	
	[newObject setValue:date forKey:@"date"];
	//[newObject setValue:person forKey:@"person"];
	[newObject setValue:ph forKey:@"phoneNumber"];
	[newObject setValue:msg forKey:@"message"];
	[newObject setValue:[NSNumber numberWithBool:income] forKey:@"income"];
	[newObject setValue:[NSNumber numberWithBool:unread] forKey:@"isUnread"];
	
	[historyArrayController addObject:newObject];
	[historyArrayController rearrangeObjects];
	[self setNumberOfMessages];
	[self setDockUnreadMessagesBadge];
}

-(void)playNotifySound
{
	[notifyUnreadMessagesTimer invalidate];
	notifyUnreadMessagesTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 
																 target:self 
															   selector:@selector(notifyUnreadMessages:) 
															   userInfo:nil 
																repeats:NO];
}

-(void)notifyUnreadMessages:(NSTimer *)t {
	NSSound *newMessageNotify = [NSSound soundNamed:@"newMessage"];
	[NSThread detachNewThreadSelector:@selector(play) toTarget:newMessageNotify withObject:nil];
	notifyUnreadMessagesTimer = nil;
}

-(IBAction)forwardSelectedMessage:(id)sender
{
	mrimSMSAppController *appController = [[[NSApplication sharedApplication] delegate] appController];
	mainController *mainManager = [appController mainManager];
	NSManagedObject *selectedMessage = [[historyArrayController selectedObjects] objectAtIndex:0];
	[mainManager setMessageText:[selectedMessage valueForKey:@"message"]];
	[mainManager setPhoneNumber:[selectedMessage valueForKey:@"phoneNumber"]];
	[appController switchToMain:self];
	[[appController mainManager] setMessageLength];
}

-(void)setForwardButtonEnabled:(BOOL)state
{
	[forwardButton setEnabled:state];
}

@end
