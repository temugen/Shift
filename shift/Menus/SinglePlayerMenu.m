//
//  SinglePlayerMenu.m
//  shift
//
//  Created by Greg McLain on 2/15/12.
//  Copyright (c) 2012. All rights reserved.
//

#import "SinglePlayerMenu.h"
#import "SinglePlayerGame.h"
#import "CCScrollLayer.h"
#import "MainMenu.h"

#define SPRITES_PER_PAGE 4
#define PADDING 40

NSInteger highestLevel;

@implementation SinglePlayerMenu

//Initialize the Single Player layer
-(id) init
{
    if( (self=[super init] )) {
        
        //Retrieve highest completed level by user (set to 0 if user defaults are not saved)
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        highestLevel = [defaults integerForKey:@"highestLevel"];
        if (highestLevel == 0) 
        {
            highestLevel = 1;
        }   
        
        NSMutableArray * pages = [NSMutableArray arrayWithCapacity:NUM_LEVELS];
        CGSize screenSize = [CCDirector sharedDirector].winSize;
        int spriteWidth = screenSize.width/8;
        
        CCLayer *page = [[CCLayer alloc] init];
        CCSprite * prev = nil;
        
        CCSprite* backgroundSprite = [SinglePlayerMenu createRectForWidth:spriteWidth+20 height:spriteWidth*2];
        
        for (int i=1;i<=NUM_LEVELS;i++)
        {
            //Only display textures for unlocked levels
            if(i<=highestLevel)
            {
                //Create level texture
                CCSprite *levelSprite = [SinglePlayerGame previewForLevel:i];
                [levelSprite setTag:i];
                levelSprite.scaleX = spriteWidth/levelSprite.contentSize.width;
                levelSprite.scaleY = -levelSprite.scaleX;
                
                //If there is already a level on the page, position this one next to it.
                if(prev)
                {
                    levelSprite.position = ccp(prev.position.x+spriteWidth+PADDING,screenSize.height/2);
                }
                else 
                {
                    float offsetFactor = SPRITES_PER_PAGE/2.0 - 0.5;
                    float paddingOffset = PADDING*(SPRITES_PER_PAGE-1)/2;
                    levelSprite.position = ccp(screenSize.width/2-(offsetFactor*spriteWidth)-paddingOffset,screenSize.height/2);
                }
                [page addChild:levelSprite];
                
                //Add rounded rectangle behind texture
                CCSprite* rectSprite = [CCSprite spriteWithTexture:[backgroundSprite texture]];
                rectSprite.position = levelSprite.position;
                [rectSprite setTag:i];
                [page addChild:rectSprite z:-1];
                
                prev = levelSprite;
                
                //If we filled up the page, create a new page
                if(i%SPRITES_PER_PAGE == 0)
                {
                    [pages addObject:page];
                    page = [[CCLayer alloc] init];
                    
                    prev = nil;
                }
            }
            else 
            {
                //TODO: display something for unbeaten levels
            }
        }
        
        //Don't add the page if there's nothing on it.
        if([[page children] count]>0)
        {
            [pages addObject:page];
        }
        
        CCScrollLayer *scroller = [[CCScrollLayer alloc] initWithLayers:pages widthOffset: 0];
        
        //Set display page to page containing highest level completed by user
        int pageSelection = highestLevel/SPRITES_PER_PAGE;
        [scroller selectPage:pageSelection];
        
        [self addChild:scroller];
        
        [self addBackButton];
    }
    return self;
}

+(CCSprite*) createRectForWidth:(int)width height:(int)height
{
    CGSize size = CGSizeMake(width, height);
    CGPoint center = CGPointMake(size.width/2, size.height/2); 
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGMutablePathRef boxPath = CGPathCreateMutable();
    CGFloat radius = 10.0;
    
    CGContextBeginPath(context);
    
    CGPathMoveToPoint(boxPath, nil, center.x , center.y - height/2);
    CGPathAddArcToPoint(boxPath, nil, center.x + width/2, center.y - height/2, center.x + width/2, center.y + height/2, radius);
    CGPathAddArcToPoint(boxPath, nil, center.x + width/2, center.y + height/2, center.x - width/2, center.y + height/2, radius);
    CGPathAddArcToPoint(boxPath, nil, center.x - width/2, center.y + height/2, center.x - width/2, center.y, radius);
    CGPathAddArcToPoint(boxPath, nil, center.x - width/2, center.y - height/2, center.x, center.y - height/2, radius);
    
    CGPathCloseSubpath(boxPath);
    CGContextAddPath(context, boxPath);    
    CGContextClosePath(context);
    CGContextClip(context);

    CGRect rect = CGRectMake(center.x-width/2, center.y-height/2, width, height);
    [SinglePlayerMenu createGradient:rect];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    CCSprite* sprite = [CCSprite spriteWithCGImage:image.CGImage key:@"image"];
    return sprite;
}

+(void) createGradient:(CGRect) rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
		
	size_t num_locations = 2;
	CGFloat locations[2] = { 0.0, 0.5 };
	CGFloat components[8] = {  0.92, 0.92, 0.92, 1.0, 0.82, 0.82, 0.82, 0.4 };
	
	CGGradientRef gradient = CGGradientCreateWithColorComponents (space, components, locations, num_locations);
    
    CGPoint startPoint, endPoint;
    startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMidY(rect)); 
    endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect));
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
}

+(void) levelSelect: (int) levelNum
{    
    if(levelNum<=highestLevel)
    {
        SinglePlayerGame *game = [SinglePlayerGame gameWithLevel:levelNum];
        [[CCDirector sharedDirector] replaceScene:[CCTransitionFlipAngular transitionWithDuration:kSceneTransitionTime scene:game]];
    }
}


@end
