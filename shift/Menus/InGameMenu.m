//
//  InGameMenu.m
//  shift
//
//  Created by Brad Misik on 3/25/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "InGameMenu.h"
#import "SinglePlayerMenu.h"

@implementation InGameMenu

-(id) init
{
    if ((self = [super init])) {
        //Pause the background music
        [[SimpleAudioEngine sharedEngine] pauseBackgroundMusic];        
        
        //Set up menu items
        CCMenuItemFont *levelSelect = [CCMenuItemFont itemFromString:@"Level Select" target:self selector: @selector(onLevelSelect:)];
        CCMenuItemFont *mainMenu = [CCMenuItemFont itemFromString:@"Exit to Main Menu" target:self selector: @selector(onMainMenu:)];
        CCMenuItemFont *reset = [CCMenuItemFont itemFromString:@"Reset Board" target:self selector: @selector(onReset:)];
        CCMenuItemFont *play = [CCMenuItemFont itemFromString:@"Return to Play" target:self selector: @selector(onPlay:)];
        
        //Add items to menu
        CCMenu *menu = [CCMenu menuWithItems:levelSelect,mainMenu, reset, play, nil];
        
        [menu alignItemsVertically];
        
        //Add menu to main menu layer
        [self addChild: menu];
    }
    
    return self;
}

-(void) onReset:(id)sender
{
    //Play menu selection sound
    [[SimpleAudioEngine sharedEngine] playEffect:@SFX_MENU];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ResetButtonPressed" object:self];
    [self onPlay:self];
}

-(void) onPlay:(id)sender
{
    //Play menu selection sound
    [[SimpleAudioEngine sharedEngine] playEffect:@SFX_MENU];
    
    //Resume the background music
    [[SimpleAudioEngine sharedEngine] resumeBackgroundMusic];
    
    [self.parent removeChild:self cleanup:YES];
}

-(void) onMainMenu:(id)sender
{
    //Play menu selection sound
    [[SimpleAudioEngine sharedEngine] playEffect:@SFX_MENU];
    
    [self goBack:self];
}

-(void) onLevelSelect:(id)sender
{
    //Play menu selection sound
    [[SimpleAudioEngine sharedEngine] playEffect:@SFX_MENU];
    
    [[CCDirector sharedDirector] runWithScene:[CCTransitionSlideInL transitionWithDuration:kSceneTransitionTime scene:[SinglePlayerMenu scene]]];
}

@end
