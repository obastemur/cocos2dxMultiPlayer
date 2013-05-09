//
//  myTest.m
//  Gondor
//
//  Created by Zondig on 5/4/13.
//
//

#import "myTest.h"
#import "GondorScene.h"
#import "cocos2d.h"

using namespace cocos2d;

@implementation myTest

- (void) playerShot:(NSString *)xs andY:(NSString*) ys andWidth:(NSNumber *)w andHeight:(NSNumber *)h
{
    if(GondorScene::activeGondor == NULL){
        return;
    }
    
    NSArray *xarr = [xs componentsSeparatedByString:@";"];
    NSArray *yarr = [ys componentsSeparatedByString:@";"];

    for(int i=0;i<xarr.count;i++){
        NSString *strX = (NSString*)[xarr objectAtIndex:i];
        if(strX.length==0)
            continue;
        NSString *strY = (NSString*)[yarr objectAtIndex:i];
        
        GondorScene::gotFire([strX intValue],[strY intValue], [w intValue], [h intValue]);
    }
}

+ (void) kickShot:(NSString*)xs andY:(NSString*)ys
{
    PokeInClient* _client = [myTest setORget:nil];
    
    if([_client isConnected] == NO)
    {
        NSLog(@"Not connected!");
        return;
    }
 
    NSArray *arr = [[NSArray alloc] initWithObjects:xs,ys, nil ];

    [_client send:@"Server.gotShot" withParameters:arr];
}

- (void) creatureArray:(NSArray*) arr
{
    if(GondorScene::activeGondor == NULL){
        return;
    }
    
    int count = [arr count];
    int numbers[count];
    
    int n=0;
    for(NSNumber *num in arr){
        numbers[n++] = [num intValue];
    }
    
    GondorScene::activeGondor->fillPaths(numbers, count);
}

- (void) playerLeft
{
    if(GondorScene::activeGondor == NULL){
        return;
    }
    
    GondorScene::activeGondor->playerLeft();
}

+ (PokeInClient*) setORget:(PokeInClient*) client
{
    static PokeInClient* _client;
    
    if(client!=nil)
        _client = client;
    
    return _client;
}
+ (void) leaveLobby
{
    PokeInClient* _client = [myTest setORget:nil];
    
    if([_client isConnected] == NO)
    {
        NSLog(@"Not connected!");
        return;
    }
    
    
    [_client send:@"Server.leaveRoom();"];
}

+ (void) joinGame:(NSNumber*)width andHeight:(NSNumber *)height
{
    PokeInClient* _client = [myTest setORget:nil];
    
    if([_client isConnected] == NO)
    {
        NSLog(@"Not connected!");
        return;
    }
    
    
    NSArray *arr = [[NSArray alloc] initWithObjects:width,height, nil ];

    [_client send:@"Server.joinGame" withParameters:arr];
}

@end
