/*
 Copyright (c) 2017 monofire <monofirehub@gmail.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "FTAnimationContext.h"
#import "FTFoldComponent.h"

#import "FTAnimationContext+GradientColorAnimation.h"
#import "FTAnimationContext+FoldComponentsAnimation.h"



@interface FTAnimationContext()

@property (nonatomic, readwrite) NSArray *foldComponentsAnimations;
@property (nonatomic, readwrite) FTParentLayerAnimations *parentLayerAnimations;
@property (nonatomic, readwrite) FTFoldComponentGradientAnimations *foldComponentGradientAnimations;

@end

@implementation FTAnimationContext{
    NSArray *_foldComponents;
}


#pragma mark -
#pragma mark - Init

- (instancetype)init
{
    NSLog(@"::: FTCellAnimationContext - initialisation ERROR ! Please use designated initialiser -(instancetype) initWithFoldLayerHeight: (CGFloat) foldLayerHeight");
    return nil;
}

-(instancetype) initWithCellFoldComponents: (NSArray*) cellFoldComponents{
    
    self = [super init];
    if (self) {
        
        _foldComponents = cellFoldComponents;
        
        /* set default values for input params */
        self.zPerspective = -1.0f/500.0f;
        self.expandAnimationDuration = 2.0f;
        self.collapseAnimationDuration = 2.0;
        self.foldAngleFinalValue = - M_PI/6;
        self.numberOfAnimationInterpolationFrames = 10;
        self.animationMediaTimingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
      
        _foldComponentGradientColorAnimationRange.topFoldStartColorFirstValue = [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1.0f].CGColor; /* dark*/
        _foldComponentGradientColorAnimationRange.topFoldStartColorLastValue = [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.2f].CGColor;
        _foldComponentGradientColorAnimationRange.topFoldEndColorFirstValue = [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1.0f].CGColor; /* dark*/
        _foldComponentGradientColorAnimationRange.topFoldEndColorLastValue = [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:0.2f].CGColor;
        
        _foldComponentGradientColorAnimationRange.bottomFoldStartColorFirstValue =  [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1.0f].CGColor; /* dark*/
        _foldComponentGradientColorAnimationRange.bottomFoldStartColorLastValue = [UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.2f].CGColor;
        _foldComponentGradientColorAnimationRange.bottomFoldEndColorFirstValue =  [UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:1.0f].CGColor; /* dark*/
        _foldComponentGradientColorAnimationRange.bottomFoldEndColorLastValue = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.05f].CGColor;
        
        
     
        
    }
    
    
    return self;
}



#pragma mark -
#pragma mark - Animations creation

-(void) calculate{
    [self createFoldComponentsAnimations];
    [self createGradientColorAnimations];
}


-(void) createFoldComponentsAnimations{
    self.parentLayerAnimations = [[FTParentLayerAnimations alloc]init];
    self.foldComponentsAnimations = [self foldAnimationsForFoldComponents:_foldComponents parentLayerAnimations:self.parentLayerAnimations];
}


-(void) createGradientColorAnimations{
    self.foldComponentGradientAnimations = [self foldComponentGradientAnimationsWithRange:self.foldComponentGradientColorAnimationRange
                                                                           numberOfFrames:self.numberOfAnimationInterpolationFrames];
}







@end
