//
//  GondorAppController.h
//  Gondor
//
//  Created by Zondig on 5/2/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import "RootViewController.h"
#import "GondorScene.h"

@implementation RootViewController

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self connect];
}


- (void) connect
{
    //initialize the receiver object
    testObj = [[myTest alloc]init];
    
    //initialize the client object
    client = [[PokeInClient alloc] init:@"http://zondig.cloudapp.net/host.PokeIn" withTarget:testObj];
    
    //client = [[PokeInClient alloc] init:@"http://192.168.1.3/GondorServer/host.PokeIn" withTarget:testObj];
    
    [client socketConfig:@"zondig.cloudapp.net" Port:8085];
    //[client socketConfig:@"192.168.1.3" Port:8085];
    [myTest setORget:client];
    
    [client setDelegate:self];
    
    if(![client Connect]){
        NSLog(@"client couldn't connect");
    }
}


- (void) onClientConnected:(PokeInClient *)cl
{
    //client is connected
    NSLog(@"Connected to server %@", [cl getClientId]);
    GondorScene::connected = true;
}

- (void) onClientDisconnected:(PokeInClient *)cl
{
    //client is disconnected
    NSLog(@"Disconnected from server %@", [cl getClientId]);
    
    //connect back ?
    client = nil;
    [self connect];
}

- (void) onEventLog:(PokeInClient *)cl withMessage:(NSString *)log
{
    //event received (general event logs)
        NSLog(@"***************LOG POKEIN: %@:%@", [cl getClientId],log);
}

- (void) onErrorReceived:(PokeInClient *)cl withMessage:(NSString *)message
{
    //error received
   // NSLog(@"ERRLOG POKEIN: %@:%@", [cl getClientId],message);

}


// Override to allow orientations other than the default portrait orientation.
// This method is deprecated on ios6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape( interfaceOrientation );
}

// For ios6, use supportedInterfaceOrientations & shouldAutorotate instead
- (NSUInteger) supportedInterfaceOrientations{
#ifdef __IPHONE_6_0
    return UIInterfaceOrientationMaskLandscape;
#endif
}

- (BOOL) shouldAutorotate {
    return YES;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
