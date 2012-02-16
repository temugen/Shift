//
//  MainMenu.m
//  shift
//
//  Created by Greg McLain on 2/14/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "MainMenu.h"
#import "SinglePlayerMenu.h"

@implementation MainMenu

//Initialize the Main Menu layer
-(id) init
{
    if( (self=[super init] )) {

        //Set up menu items
        CCMenuItemFont *single = [CCMenuItemFont itemFromString:@"Single Player" target:self selector: @selector(onSinglePlayer:)];
        CCMenuItemFont *multi = [CCMenuItemFont itemFromString:@"Multiplayer" target:self selector: @selector(onMultiplayer:)];
        CCMenuItemFont *options = [CCMenuItemFont itemFromString:@"Options" target:self selector: @selector(onOptions:)];
        CCMenuItemFont *achievements= [CCMenuItemFont itemFromString:@"Achievements" target:self selector: @selector(onAchievements:)];

        //Add items to menu
        CCMenu *menu = [CCMenu menuWithItems: single, multi, options, achievements, nil];
        
        [menu alignItemsVertically];

        //Add menu to main menu layer
        [self addChild: menu];
        
    }
    return self;
}

//Create scene with main menu
+(id) scene
{
    MainMenu *layer = [MainMenu node];
    return [super scene:layer];
}

/* Callback functions for main menu items */

- (void) onSinglePlayer: (id) sender
{
    [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInR transitionWithDuration:TRANS_TIME scene:[SinglePlayerMenu scene]]];
}

- (void) onMultiplayer: (id) sender
{
}

- (void) onOptions: (id) sender
{
}

- (void) onAchievements: (id) sender
{
}


-(void) dealloc
{
	[super dealloc];
}

@end
