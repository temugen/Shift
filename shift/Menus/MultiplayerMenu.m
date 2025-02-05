//
//  MultiplayerMenu.m
//  shift
//
//  Created by Greg McLain on 2/16/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "MultiplayerMenu.h"
#import "MainMenu.h"
#import "GameCenterHub.h"
#import "LeaderboardMenu.h"
#import "ButtonList.h"

@implementation MultiplayerMenu

//Initialize the Multiplayer Menu layer
-(id) init
{
    if ((self=[super init])) {
      
      CGSize screenSize = [[CCDirector sharedDirector] winSize];
      ButtonList* buttons = [ButtonList buttonList];
      
      [buttons addButtonWithDescription:@"Matches" target:self selector: @selector(onMatchSelect:)];
      [buttons addButtonWithDescription:@"Leaderboards" target:self selector: @selector(onLeaderboardSelect:)];
      //[buttons addButtonWithDescription:@"Clear Matches" target:self selector: @selector(onClearSelect:)];
      buttons.position = ccp(screenSize.width / 2, screenSize.height / 2);
      [self addChild:buttons];
      [self addBackButton];
      
    }
    return self;
}

/* Callback functions for menu items */

- (void) onMatchSelect: (id) sender
{
  [[GameCenterHub sharedHub] showMatchmaker];
}

- (void) onLeaderboardSelect: (id) sender
{
    if (![GameCenterHub sharedHub].gameCenterAvailable || ![GameCenterHub sharedHub].userAuthenticated)
    {
        [[GameCenterHub sharedHub] displayGameCenterNotification:@"Must be logged into GameCenter to use this"];
        return;
    }
    
    [[GameCenterHub sharedHub] showLeaderboard:nil];
    return;
    
    [[CCDirector sharedDirector] replaceSceneAndCleanup:[CCTransitionSlideInR transitionWithDuration:kSceneTransitionTime scene:[LeaderboardMenu scene]]];
}


- (void) onClearSelect: (id) sender
{
  [[GameCenterHub sharedHub] clearMatches];
}

@end
