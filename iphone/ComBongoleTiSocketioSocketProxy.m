/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2013 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "ComBongoleTiSocketioSocketProxy.h"
#import "TiUtils.h"

@implementation ComBongoleTiSocketioSocketProxy

-(void)dealloc
{
    [super dealloc];
}

-(void)_destroy
{
    RELEASE_TO_NIL(socketIO);
    
    [super _destroy];
}

-(SocketIO *)socketIO
{
    if( socketIO == nil ){
        socketIO = [[[SocketIO alloc] initWithDelegate:self] retain];
    }
    
    return socketIO;
}

-(void)disconnect:(id)args
{
    ENSURE_UI_THREAD_1_ARG(args);
    
    SocketIO *s = [self socketIO];
    [s disconnect];
}

-(void)connect:(id)args
{
    ENSURE_UI_THREAD_1_ARG(args);
    
    NSString *host;
    int port;
    NSDictionary *opt;
    BOOL hasPort;
    
    ENSURE_ARG_OR_NIL_AT_INDEX(host, args, 0, NSString);
    ENSURE_INT_OR_NIL_AT_INDEX(port, args, 1, hasPort);
    ENSURE_ARG_OR_NIL_AT_INDEX(opt, args, 2, NSDictionary);
    
    SocketIO *s = [self socketIO];
    
    if( [s isConnected] ){
        return;
    }
    
    if( opt == nil ){
        [s connectToHost:host onPort:port];
    }
    else{
        [s connectToHost:host onPort:port withParams:opt];
    }
}

-(void)sendMessage:(id)args
{
    ENSURE_UI_THREAD_1_ARG(args);
    
    NSString *data;
    
    ENSURE_ARG_OR_NIL_AT_INDEX(data, args, 0, NSString);
    
    SocketIO *s = [self socketIO];
    [s sendMessage:data];
}

-(void)sendEvent:(id)args
{
    NSString *event;
    NSString *data;
    
    ENSURE_ARG_OR_NIL_AT_INDEX(event, args, 0, NSString);
    ENSURE_ARG_OR_NIL_AT_INDEX(data, args, 1, NSString);
    
    SocketIO *s = [self socketIO];
    [s sendEvent:event withData:data];
}


- (void) socketIODidConnect:(SocketIO *)socket
{
    if ([self _hasListeners:@"connect"]) {
        [self fireEvent:@"connect" withObject:nil];
    }
}

- (void) socketIODidDisconnect:(SocketIO *)socket disconnectedWithError:(NSError *)error
{
     if ([self _hasListeners:@"disconnect"]) {
        [self fireEvent:@"disconnect" withObject:nil];
     }
}

- (void) socketIO:(SocketIO *)socket didReceiveMessage:(SocketIOPacket *)packet
{
    if ([self _hasListeners:@"receiveMessage"]) {
        NSString *data = @"";
        
        if( [packet data] != nil ){
            data = [packet data];
        }
        
        NSDictionary *e = @{
                            @"data": data
                            };
        
        [self fireEvent:@"receiveMessage" withObject:e];
     }
}

- (void) socketIO:(SocketIO *)socket didReceiveEvent:(SocketIOPacket *)packet
{
      if ([self _hasListeners:@"receiveEvent"]) {
          NSString *name = @"";
          NSArray *args = @[];
          
          if( [packet name] != nil ){
              name = [packet name];
          }
          
          if( [packet args] != nil ){
              args = [packet args];
          }
          
          NSDictionary *e = @{
                              @"name": name,
                              @"args": args
                              };
          
          [self fireEvent:@"receiveEvent" withObject:e];
      }
}

- (void) socketIO:(SocketIO *)socket didSendMessage:(SocketIOPacket *)packet
{
    if ([self _hasListeners:@"sendMessage"]) {
        [self fireEvent:@"sendMessage" withObject:nil];
    }
}

- (void) socketIO:(SocketIO *)socket onError:(NSError *)error;
{
    if ([self _hasListeners:@"error"]) {
        NSDictionary *e = @{
                        @"errorCode": NUMINT([error code]),
                        @"error": [error description]
                        };
        [self fireEvent:@"error" withObject:e];
    }
}

@end
