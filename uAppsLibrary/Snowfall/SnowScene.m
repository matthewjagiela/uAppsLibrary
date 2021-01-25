//
//  SnowScene.m
//  uSurf
//
//  Created by Matthew Jagiela on 11/22/15.
//  Copyright © 2015 Matthew Jagiela. All rights reserved.
//

#import "SnowScene.h"

@implementation SnowScene
NSString *const bundle = @"uAppsLibraryRes.bundle";
-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor clearColor];
        NSBundle *bundle = [NSBundle bundleForClass:self.classForCoder];
        NSString *emitterPath = [bundle pathForResource:@"Snow" ofType:@"sks"];
        SKEmitterNode *snow = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
        snow.position = CGPointMake(CGRectGetMidX(self.frame), self.size.height);
        snow.targetNode = self.scene;
        [self addChild:snow];
        
    }
    return self;
}

@end
