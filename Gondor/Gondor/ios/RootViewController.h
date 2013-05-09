//
//  GondorAppController.h
//  Gondor
//
//  Created by Zondig on 5/2/13.
//  Copyright __MyCompanyName__ 2013. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PokeInClient.h"
#import "myTest.h"

@interface RootViewController : UIViewController {
    PokeInClient *client;
    
    myTest *testObj;
}
- (void) connect;
@end
