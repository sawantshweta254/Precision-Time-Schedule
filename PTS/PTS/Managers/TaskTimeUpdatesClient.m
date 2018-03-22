//
//  TaskTimeUpdatesManager.m
//  PTS
//
//  Created by Shweta Sawant on 12/03/18.
//  Copyright © 2018 Softdew. All rights reserved.
//

#import "TaskTimeUpdatesClient.h"
#import "SRWebSocket.h"
#import "WebsocketMessageFactory.h"

@interface TaskTimeUpdatesClient () <SRWebSocketDelegate>

@property(nonatomic, strong) SRWebSocket *webSocketClient;
@property(nonatomic, strong) NSMutableArray *iceServers;
@property(nonatomic, strong) NSURL *webSocketURL;
@property(nonatomic, strong) NSString *connectionMode;
@property(nonatomic, strong) NSMutableArray *iceCandidatesQueue;
@property(nonatomic) Boolean isSocketConnected;
@property NSDictionary* lastSampleSent;
@property NSDictionary* lastSampleRcvd;
@property(nonatomic, strong) NSURL *webSocketReconnectURL;
@end

@implementation TaskTimeUpdatesClient

- (void)connectToWebSocket
{
    if (self.webSocketClient == nil || self.webSocketClient.readyState == SR_CLOSED) {
        NSURL *clientURL = [NSURL URLWithString:[@"ws://172.104.182.245:10001" stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
        self.webSocketClient = [[SRWebSocket alloc] initWithURL:clientURL];
        self.webSocketClient.delegate = self;
        [self.webSocketClient open];
    }
    
}

-(void) webSocketDidOpen:(SRWebSocket *)webSocket{
    NSLog(@"Did Open");
}

-(void) webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error{
    
}

-(void) webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean{
    
}

-(void) webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message{
    
}

- (void) updateUserForFlight:(NSInteger)flightId{
    WebsocketMessageFactory *messageFactory = [[WebsocketMessageFactory alloc] init];
    [self.webSocketClient send:[messageFactory createLoggedInUserMessageForFlight:flightId]];
}

- (void) updateFlightTask:(PTSItem *)pts{
     WebsocketMessageFactory *messageFactory = [[WebsocketMessageFactory alloc] init];
    [self.webSocketClient send:[messageFactory createUpdateMessageForFlight:pts]];
}



@end
