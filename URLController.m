//
//  URLController.m
//  mrimSMS
//
//  Created by Алексеев Влад on 26.06.09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "URLController.h"


@implementation URLController
-(IBAction)openRegistrationURL:(id)sender
{
	NSURL *url = [NSURL URLWithString:@"http://mail.ru/cgi-bin/signup"];
	[[NSWorkspace sharedWorkspace] openURL:url];
}

-(IBAction)openDonateURL:(id)sender
{
	NSURL *url = [NSURL URLWithString:@"http://beefon.byethost22.com/index.php?app=donate"];
	[[NSWorkspace sharedWorkspace] openURL:url];
}

-(IBAction)openAppStore:(id)sender
{
	NSURL *url = [NSURL URLWithString:@"itms://itunes.apple.com/app/mrimsms/id329197889?mt=8"];
	[[NSWorkspace sharedWorkspace] openURL:url];
}
@end
