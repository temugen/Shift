//
//  Quickplay.m
//  shift
//
//  Created by Greg McLain on 2/16/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "DifficultyMenu.h"
#import "BoardLayer.h"
#import "MainMenu.h"
#import "MultiplayerMenu.h"

@implementation DifficultyMenu

typedef enum {
    EASY,
    MEDIUM,
    HARD
} difficulty;

DifficultyMenu* layer;

//Initialize the Quickplay layer
-(id) init
{
    if( (self=[super init] )) {
        
        //Set up menu items
        CCMenuItemFont *easy = [CCMenuItemFont itemFromString:@"Easy" target:self selector: @selector(onSelection:)];
        [easy setTag:EASY];
        CCMenuItemFont *medium = [CCMenuItemFont itemFromString:@"Medium" target:self selector: @selector(onSelection:)];
        [medium setTag:MEDIUM];
        CCMenuItemFont *hard= [CCMenuItemFont itemFromString:@"Hard" target:self selector: @selector(onSelection:)];
        [hard setTag:HARD];
        CCMenuItemFont *back = [CCMenuItemFont itemFromString:@"Back" target:self selector: @selector(goBack:)]; 

        //Add items to menu
        CCMenu *menu = [CCMenu menuWithItems: easy,medium,hard,back, nil];
        
        [menu alignItemsVertically];
        
        [self addChild: menu];        
    }
    return self;
}

//Create scene with quickplay menu
+(id) scene:(gamemode) gameSelection
{
    layer = [DifficultyMenu node];
    layer->mode = gameSelection;
    return [super scene:layer];
}

/* Callback functions for menu items */

- (void) onSelection: (id) sender
{
    difficulty diff = [sender tag];
    
    if(layer->mode == QUICKPLAY)
    {
        switch (diff) {
            case EASY:
                //TODO: Generate random easy puzzle
                NSLog(@"User selected Easy Quickplay");
                break;
            case MEDIUM:
                //TODO: Generate random medium puzzle
                NSLog(@"User selected Medium Quickplay");
                break;
            case HARD:
                //TODO: Generate random hard puzzle
                NSLog(@"User selected Hard Quickplay");
                break;
            default:
                break;
        }
    }
    else
    {
        NSLog(@"User selected Multiplayer");   
    }
}

- (void) goBack: (id) sender
{
    if(layer->mode==QUICKPLAY)
    {
        [[CCDirector sharedDirector] replaceScene:[CCTransitionSlideInL transitionWithDuration:TRANS_TIME scene:[MainMenu scene]]];
    }
    else
    {
        [[CCDirector sharedDirector] replaceScene:
                                        [CCTransitionSlideInL transitionWithDuration:TRANS_TIME scene:[MultiplayerMenu scene]]];
    }
}

-(void) dealloc
{
	[super dealloc];
}

@end
