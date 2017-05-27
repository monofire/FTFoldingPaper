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

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

#import "FTParentLayerAnimations.h"
#import "FTFoldComponentAnimations.h"
#import "FTFoldComponentGradientAnimations.h"

#import "AnimationContextStructs.h"


/* ::: FTAnimationContext is responsible for creating and proving
 animation objects based on the in-put config */
@interface FTAnimationContext : NSObject


-(instancetype) initWithCellFoldComponents: (NSArray*) cellFoldComponents;



/* Depth of perspective effect. Default value -1.0f/500.0f */
@property (nonatomic) CGFloat zPerspective;


/* Duration of the cell expand aniamation, seconds */
@property (nonatomic) CGFloat expandAnimationDuration;

/* Duration of the cell collapse aniamation, seconds */
@property (nonatomic) CGFloat collapseAnimationDuration;

/* Destination angle between fold components at the end of expand animation
 0.0f means fully opened fold. Default value -M_PI/6 */
@property (nonatomic) CGFloat foldAngleFinalValue;


/* Number of interpolation frames for all animations. More frames - more precise animation path. Default is 10 */
@property (nonatomic) NSInteger numberOfAnimationInterpolationFrames;

/* 
 Animation flow effects
 https://developer.apple.com/reference/quartzcore/camediatimingfunction/predefined_timing_functions?language=objc */
@property (nonatomic) CAMediaTimingFunction *animationMediaTimingFunction;


/* calculate values for animation frames and create animation objects */
-(void) calculate;

/* provides precooked animations based on input configuration */
@property (nonatomic, readonly) NSArray *foldComponentsAnimations;


/* parent layer animation object */
@property (nonatomic, readonly) FTParentLayerAnimations *parentLayerAnimations;




/* Gradient animation params:
 Start color - start color of gradient fill itself
 End color - end color of gradient fill itself
 First value - color at the beginning of animation
 Last value - color at the end of aniamation
 */
@property (nonatomic)  struct FoldComponentGradientColorAnimationRange foldComponentGradientColorAnimationRange;


/* fold gradient color animation object */
@property (nonatomic, readonly) FTFoldComponentGradientAnimations *foldComponentGradientAnimations;


@end
