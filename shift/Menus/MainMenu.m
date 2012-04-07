//
//  MainMenu.m
//  shift
//
//  Created by Greg McLain on 2/14/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "MainMenu.h"
#import "TitleLayer.h"
#import "SinglePlayerMenu.h"
#import "MultiplayerMenu.h"
#import "DifficultyMenu.h"
#import "OptionsMenu.h"
#import "AchievementsMenu.h"
#import "GameCenterHub.h"
#import "GoalSprite.h"
#import "BlockSprite.h"
#import "ColorPalette.h"

#define TEXT_BLOCK_SIZE 35
#define TITLE_BORDER_SIZE 50

@implementation MainMenu

//Initialize the Main Menu layer
-(id) init
{
    if( (self=[super init] )) {
        //Play background music
        [[SimpleAudioEngine sharedEngine] stopBackgroundMusic];
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@BGM_MENU];
        
        //Set up menu items
        CCMenuItemFont *quickplay = [CCMenuItemFont itemFromString:@"Quickplay" target:self selector: @selector(onQuickplay:)];
        CCMenuItemFont *single = [CCMenuItemFont itemFromString:@"Single Player" target:self selector: @selector(onSinglePlayer:)];
        CCMenuItemFont *multi = [CCMenuItemFont itemFromString:@"Multiplayer" target:self selector: @selector(onMultiplayer:)];
        CCMenuItemFont *achievements= [CCMenuItemFont itemFromString:@"Achievements" target:self selector: @selector(onAchievements:)];
        CCMenuItemFont *options = [CCMenuItemFont itemFromString:@"Options" target:self selector: @selector(onOptions:)];
        
        //Add items to menu
        menu = [CCMenu menuWithItems: quickplay, single, multi, achievements, options, nil];
        
        //Shift menu down slightly to accomodate title
        menu.position = ccp(menu.position.x,menu.position.y-40);
        
        [menu alignItemsVertically];
        
        //Add menu to main menu layer
        [self addChild: menu];
        
    }
    return self;
}

//Create scene with main menu
+(id) scene
{
    MainMenu *mainMenu = [MainMenu node];
    TitleLayer *title = [TitleLayer node];
    title.position = ccp(mainMenu->menu.position.x,mainMenu->menu.position.y+140);
    
    CCScene* scene = [super sceneWithMenu:mainMenu];
    [scene addChild:title z:1];
    return scene;
}

/* Callback functions for main menu items */

- (void) onQuickplay: (id) sender
{
    //Play menu selection sound
    [[SimpleAudioEngine sharedEngine] playEffect:@SFX_MENU];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:kSceneTransitionTime scene:[DifficultyMenu sceneWithMode:QUICKPLAY]]];
}

- (void) onSinglePlayer: (id) sender
{
    //Play menu selection sound
    [[SimpleAudioEngine sharedEngine] playEffect:@SFX_MENU];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:kSceneTransitionTime scene:[SinglePlayerMenu scene]]];
}

- (void) onMultiplayer: (id) sender
{
    //Play menu selection sound
    [[SimpleAudioEngine sharedEngine] playEffect:@SFX_MENU];
    if ([GameCenterHub sharedInstance].gameCenterAvailable) 
    { 
        [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:kSceneTransitionTime scene:[MultiplayerMenu scene]]];
    }
    else
    {
      [[GameCenterHub sharedInstance] noGameCenterNotification:@"GameCenter is required to use any of the multiplayer features"];
    }
}

- (void) onOptions: (id) sender
{
    //Play menu selection sound
    [[SimpleAudioEngine sharedEngine] playEffect:@SFX_MENU];
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:kSceneTransitionTime scene:[OptionsMenu scene]]];
}

- (void) onAchievements: (id) sender
{
    //Play menu selection sound
    [[SimpleAudioEngine sharedEngine] playEffect:@SFX_MENU];

  if ([GameCenterHub sharedInstance].gameCenterAvailable)
  { 
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:kSceneTransitionTime scene:[AchievementsMenu scene]]];
  }
  else
  {
    [[GameCenterHub sharedInstance] noGameCenterNotification:@"Game Center is required to view your achievements"];
  }
}

@end

