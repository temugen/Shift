//
//  BlockSprite.m
//  shift
//
//  Created by Brad Misik on 10/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BlockSprite.h"
#import "ColorPalette.h"

@implementation BlockSprite

-(id) initWithName:(NSString *)color
{
    if ((self = [super initWithFilename:[NSString stringWithFormat:@"block.png", color]])) {
        name = color;
        self.color = [[ColorPalette sharedPalette] colorWithName:color];
    }
    return self;
}

-(id) copyWithZone:(NSZone *)zone
{
    BlockSprite *cell = [[[self class] alloc] initWithName:self.name];
    [cell resize:[self boundingBox].size];
    cell.column = column;
    cell.row = row;
    cell.health = health;
    cell.comparable = comparable;
    cell.movable = movable;
    cell.tutorial = tutorial;
    cell.color = self.color;
    return cell;
}

+(id) blockWithName:(NSString *)name
{
    return [[[self class] alloc] initWithName:name];
}

-(BOOL) onMoveWithDistance:(float)distance vertically:(BOOL)vertically
{
    if ([self isMemberOfClass:[BlockSprite class]]) {
        [self completeTutorial];
    }
    return NO;
}

@end
