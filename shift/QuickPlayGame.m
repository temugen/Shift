//
//  QuickPlayGame.m
//  shift
//
//  Created by Brad Misik on 2/19/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "QuickPlayGame.h"
#import "GameCenterHub.h"
#import "QuickplayGameMenu.h"
#import "NextGameMenu.h"

@interface QuickPlayGame()

-(void) animatePopulation;
-(void) onCellPopulated:(BlockSprite *)block;

@end

@implementation QuickPlayGame

static QuickPlayGame *lastGame = nil;

+(QuickPlayGame *) gameWithNumberOfRows:(int)rows columns:(int)columns;
{
    return [[QuickPlayGame alloc] initWithNumberOfRows:rows columns:columns];
}

+(QuickPlayGame *) lastGame
{
    return lastGame;
}

-(id) initWithNumberOfRows:(int)rows columns:(int)columns
{
    if ((self = [super init])) {
        rowCount = rows;
        columnCount = columns;
        board = [BoardLayer randomBoardWithNumberOfColumns:columnCount
                                                      rows:rowCount
                                                  cellSize:cellSize];
        board.position = boardCenter;
        [self addChild:board];
        [self hideBlocks];
        
        //lastGame = self;
    }
    
    return self;
}

-(void) onEnter
{
    [super onEnter];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onNewPuzzleButtonPressed:)
                                                 name:@"NewPuzzle"
                                               object:nil];
}

-(void) hideBlocks
{
    for (int x = 0; x < columnCount; x++) 
    {
        for (int y = 0; y < rowCount; y++) 
        {
            BlockSprite *origBlock = [board blockAtX:x y:y];
            origBlock.visible = NO;
        }
    }
}

-(void) onEnterTransitionDidFinish
{
    [super onEnterTransitionDidFinish];
    [self animatePopulation];
}

-(void) onGameEnd
{
  [super onGameEnd];
    
    NextGameMenu *nextMenu = [[NextGameMenu alloc] initWithMessage:@"Board Completed!" time:self.elapsedTime moves:board.moveCount];
    [self addChild:nextMenu z:10];
  
  //Send score for leaderboard
  switch (rowCount)
  {
    case kDifficultyEasy:
//      [[GameCenterHub sharedInstance] submitScore:elapsedTime category:@"easy_time"];
      break;
    case kDifficultyMedium:
//      [[GameCenterHub sharedInstance] submitScore:elapsedTime category:@"medium_time"];
      break;
    case kDifficultyHard:
      [[GameCenterHub sharedHub] submitScore:elapsedTime category:@"hard_time"];
      break;
  }
}

-(void) onNextGame
{
    [self removeChild:board cleanup:YES];
    
    board = [BoardLayer randomBoardWithNumberOfColumns:columnCount
                                                  rows:rowCount
                                              cellSize:cellSize];
    board.position = boardCenter;
    [self addChild:board];
    [self animatePopulation];
    
    [super onNextGame];
}

-(void) onCellPopulated:(BlockSprite *)block
{
    BlockSprite *origBlock = [board blockAtX:block.column y:block.row];
    origBlock.visible = YES;
    [block removeFromParentAndCleanup:YES];
}

-(void) animatePopulation
{
    [self hideBlocks];
    
    CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    for (int x = 0; x < columnCount; x++) 
    {
        for (int y = 0; y < rowCount; y++) 
        {
            BlockSprite *origBlock = [board blockAtX:x y:y];
            
            if (origBlock != nil) 
            {
                id actionMove = [CCMoveTo actionWithDuration:1.5 position:[board convertToWorldSpace:origBlock.position]];
                
                BlockSprite *block = [origBlock copy];
                [self addChild:block];
                
                //Randomly place blocks outside of screen
                int randomX = arc4random() % (int)screenSize.width;
                int randomY = arc4random() % (int)screenSize.height;
                
                int side = arc4random() % 4;
                
                switch (side) {
                    case 0:
                        block.position = ccp(-cellSize.width, randomY);
                        break;
                    case 1:
                        block.position = ccp(screenSize.width + cellSize.width, randomY);
                        break;
                    case 2:
                        block.position = ccp(randomX, -cellSize.height);
                        break;
                    case 3:
                        block.position = ccp(randomX, screenSize.height + cellSize.height);
                        break;
                        
                    default:
                        break;
                }
                
                actionMove = [CCEaseExponentialIn actionWithAction:actionMove];
                id actionCall = [CCCallFuncO actionWithTarget:self selector:@selector(onCellPopulated:) object:block];
                id actionSequence = [CCSequence actions: actionMove, actionCall, nil];
                [block runAction: actionSequence];
            }
        }
    } 
}

-(void) onPause
{
    InGameMenu *menu = [[QuickplayGameMenu alloc] init];
    [self displayPauseMenu:menu];
    [super onPause];
}

-(void) onNewPuzzleButtonPressed:(NSNotification *)notification
{
    [self onNextGame];
}

@end
