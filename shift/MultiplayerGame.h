//
//  MultiplayerGame.h
//  shift
//
//  Created by Alex Chesebro on 4/2/12.
//  Copyright (c) 2012 __Oh_Shift__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "GameScene.h"
#import "BoardLayer.h"

@interface MultiplayerGame : GameScene
{
  int rowCount, columnCount;
  BOOL myTurn;
  NSString* myID;
  GKTurnBasedMatch* myMatch;
}

+(MultiplayerGame*) gameWithDifficulty:(NSString*)difficulty match:(GKTurnBasedMatch*)match;
+(MultiplayerGame*) gameWithMatchData:(GKTurnBasedMatch*)match andIsMyTurn:(BOOL)mine;
-(id) initWithNumberOfRows:(int)rows columns:(int)columns match:(GKTurnBasedMatch*) match;
-(id) initWithMatchData:(GKTurnBasedMatch*) match andIsMyTurn:(BOOL)mine;

@property (strong, atomic) GKTurnBasedMatch* myMatch;
@property (assign) BOOL myTurn;

@end
