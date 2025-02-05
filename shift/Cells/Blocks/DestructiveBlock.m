//
//  DestructiveBlock.m
//  shift
//
//  Created by Donghun Lee on 2/20/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "DestructiveBlock.h"
#import "BoardLayer.h"
#import "RamBlock.h"
#import "BlockTrain.h"

@implementation DestructiveBlock

-(id) initWithName:(NSString *)blockName
{
    NSString *filename = [NSString stringWithFormat:@"block_destructive.png"];
    if ((self = [super initWithFilename:filename])) {
        health = platformMinCollisionForce * 10;
        comparable = NO;
        movable = NO;
        name = blockName;
    }
    return self;
}

-(BOOL) onCollideWithCell:(CellSprite *)cell force:(float)force
{
    if(![cell isKindOfClass:[RamBlock class]] || force < platformMinCollisionForce)
    {
        return NO;
    }
    
    if (![self takeHit:force])
    {
        BlockSprite *ram = (BlockSprite *)cell;
        if (ram.blockTrain != nil) {
            [ram.blockTrain snap];
        }
    }
    
    return YES;
}

-(void) crack
{
    CCRenderTexture *cracked = [CCRenderTexture renderTextureWithWidth:self.contentSize.width
                                                                height:self.contentSize.height];
    [cracked beginWithClear:0 g:0 b:0 a:0];
    CCSprite *current = [CCSprite spriteWithTexture:self.texture];
    current.scaleY = -1;
    current.position = ccp(current.contentSize.width / 2, current.contentSize.height / 2);
    [current visit];
    
    CCSprite *crack = [CCSprite spriteWithFile:@"crack1.png"];
    crack.blendFunc = (ccBlendFunc){GL_ZERO, GL_ONE_MINUS_SRC_ALPHA};
    int randomX = arc4random() % (int)self.contentSize.width;
    int randomY = arc4random() % (int)self.contentSize.height;
    crack.position = ccp(randomX, randomY);
    int degrees = arc4random() % 360;
    crack.rotation = degrees;
    [crack visit];
    [cracked end];
    
    self.texture = cracked.sprite.texture;
}

-(BOOL) takeHit:(int)damage
{
    health -= damage;
    
    if (health <= 0) {
        [self destroyBlock];
        return NO;
    }
    else {
        [self crack];
        return YES;
    }
}

-(void) destroyBlock
{
    [self.board removeBlock: self];
    [[SimpleAudioEngine sharedEngine] playEffect:@SFX_DESTRUCT];
}


@end
