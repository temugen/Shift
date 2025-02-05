//
//  SinglePlayerGame.m
//  shift
//
//  Created by Brad Misik on 2/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "SinglePlayerGame.h"
#import "MainMenu.h"
#import "GameCenterHub.h"
#import "SinglePlayerGameMenu.h"
#import "LevelPack.h"
#import "NextGameMenu.h"

@implementation SinglePlayerGame

static SinglePlayerGame *lastGame = nil;

+(SinglePlayerGame *) gameWithLevel:(int)level
{
    return [[SinglePlayerGame alloc] initWithLevel:level];
}

+(SinglePlayerGame *) lastGame
{
    return lastGame;
}

-(id) initWithLevel:(int)level
{
    if ((self = [super init])) {
        currentLevel = level;
        
        tutorials = [[TutorialLayer alloc] init];
        [self addChild:tutorials];
        
        board = [BoardLayer boardWithDictionary:[[[LevelPack sharedPack] levelWithNumber:currentLevel] objectForKey:@"board"]
                                       cellSize:cellSize];
        board.position = boardCenter;
        [self addChild:board];
        
        //lastGame = self;
    }
    return self;
}

-(void) onGameEnd
{
  [super onGameEnd];
    
    [tutorials clearAllMessages];
    
    NextGameMenu *nextMenu = [[NextGameMenu alloc] initWithMessage:[NSString stringWithFormat:@"Level %d Complete!", currentLevel]
                                                              time:self.elapsedTime moves:board.moveCount];
    [self addChild:nextMenu z:10];
  
  GKAchievement* achievement = [[GameCenterHub sharedHub] addOrFindIdentifier:@"beat_game"];
  if (![achievement isCompleted]) 
  {
    [[GameCenterHub sharedHub] reportAchievementIdentifier:@"beat_game" percentComplete:100.0];
    [[GameCenterHub sharedHub] achievementCompleted:@"Oh Shift! Conqueror" message:@"Successfully completed a level of Oh Shift!"];
  }
}

-(void) onNextGame
{
    [self removeChild:board cleanup:YES];
    currentLevel++;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger highestLevel = [defaults integerForKey:@"highestLevel"];
    
    //If user beat a new level, save the progress
    if(currentLevel > highestLevel)
    {
        [defaults setInteger:currentLevel forKey:@"highestLevel"];
        [defaults synchronize];
    }

    //If user completed all levels, return to Main Menu (for now). Maybe display some congratulatory message? Fireworks?
    if(currentLevel > [[LevelPack sharedPack] numLevels])
    {
        [[CCDirector sharedDirector] replaceSceneAndCleanup:[CCTransitionSlideInL transitionWithDuration:kSceneTransitionTime scene:[MainMenu scene]]];
    }
    else
    {
        board = [BoardLayer boardWithDictionary:[[[LevelPack sharedPack] levelWithNumber:currentLevel] objectForKey:@"board"]
                                       cellSize:cellSize];
        board.position = boardCenter;
        [self addChild:board];
    }
    
    [super onNextGame];
}

-(void) onPause
{
    InGameMenu *menu = [[SinglePlayerGameMenu alloc] init];
    [self displayPauseMenu:menu];
    [super onPause];
}
                             
@end
