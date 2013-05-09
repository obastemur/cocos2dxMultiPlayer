//
//  myTest.h
//  Gondor
//
//  Created by Zondig on 5/4/13.
//
//

#import <Foundation/Foundation.h>
#import "PokeInClient.h"

@interface myTest : NSObject

- (void) playerShot:(NSString *)x andY:(NSString*) y andWidth:(NSNumber*) w andHeight:(NSNumber*) h;
- (void) playerLeft;
- (void) creatureArray:(NSArray*) arr;

+ (PokeInClient*) setORget:(PokeInClient*) client;
+ (void) joinGame:(NSNumber*)w andHeight:(NSNumber*)h;
+ (void) kickShot:(NSString*)xs andY:(NSString*)ys;
+ (void) leaveLobby;

@end
