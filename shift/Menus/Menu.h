//
//  Menu.h
//  shift
//
//  Created by Greg McLain on 2/15/12.
//  Copyright (c) 2012. All rights reserved.
//

//The menu background music and sound effect files
#define BGM_MENU "shift_bg_menu.mp3"

#import "SimpleAudioEngine.h"

@interface Menu : CCLayer
{
}

+(id) scene;
+(id) sceneWithMenu:(Menu *)menu;

-(void) addBackButton;
-(void) goBack:(id)sender;

@end
