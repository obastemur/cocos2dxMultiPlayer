//
//  PokeInClient.h
//  PokeIn Objective-C Client
//
//  Created by Zondig
//  Copyright (c) 2013 Zondig. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PokeInClient : NSObject

- (id) init:(NSString*) url withTarget:(NSObject*) target;

- (id) init:(NSString*) url withTarget:(NSObject*) target andJoint:(NSString*) joint;

//set event listener
- (void) setDelegate:(id) delegate;

//uses PokeIn's eventTarget feature
- (void) setEventTarget:(NSString*) eventTarget;

//returns the clientId
- (NSString*) getClientId;

//connects client asynchronously to the server
- (BOOL) Connect;

//closes the connection to server
- (void) Close;

//returns YES/NO
- (BOOL) isConnected;

//Pings the server and checks the connection (does nothing if there is no connection issue)
- (void)pingServer;

//Configures the socket settings and makes the client using them
- (void) socketConfig:(NSString*) url Port:(NSUInteger) serverPort;

//sends a parameterless call
- (void) send:(NSString*) message;

//sends a call with parameters
- (void) send:(NSString*) message withParameters:(NSArray*) params;

@end

@protocol PokeInClientEvents<NSObject>

@optional
- (void) onClientConnected:(PokeInClient*) client;
- (void) onClientDisconnected:(PokeInClient*) client;
- (void) onErrorReceived:(PokeInClient*) client withMessage:(NSString*) message;
- (void) onEventLog:(PokeInClient*) client withMessage:(NSString*) log;

@end