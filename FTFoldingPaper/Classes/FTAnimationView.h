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
#import <UIKit/UIKit.h>
#import "FTAnimationContext.h"
#import "FTFoldComponent.h"

/* ::: FTAnimationView hosts and manages fold FTFoldComponent objects */


typedef enum{
    EXPAND_CELL_ANIMATION,
    COLLAPSE_CELL_ANIMATION,    
}AnimationType;

typedef enum{
    ANIMATION_IDLE,
    EXPANDING_ANIMATION_IS_PERFORMING,
    COLLAPSING_ANIMATION_IS_PERFORMING,
}AnimationState;


typedef enum{
    ANIMATION_VIEW_IS_EXPANDED,
    ANIMATION_VIEW_IS_COLLAPSED
}CurrentViewConfiguration;


@class FTAnimationView;


@protocol FTAnimationViewProtocol <NSObject>

-(void) onAnimationViewHeightChanged: (CGFloat) heightChangePerFrame
                       animationView: (FTAnimationView *) animationView;


-(void) onAnimationViewAnimationFinishedWithLastFrameHeightChange: (CGFloat) lastFrameHeightChange
                                                    animationType: (AnimationType) animationType
                                                    animationView: (FTAnimationView *) animationView;

@end


@interface FTAnimationView : UIView


@property (nonatomic, weak) id <FTAnimationViewProtocol> animationViewDelegate;

/* change height with animation */
-(void) animateWithType: (AnimationType) animationType;

/* change height immediately */
-(void) configureHeightImmediatelyWithType:(AnimationType) animationType;

/* inspect state */
@property (nonatomic) CGFloat destinationHeightAfterAnimation;
@property (nonatomic,readonly) AnimationState animationState;
@property (nonatomic,readonly) CurrentViewConfiguration currentViewConfiguration;

/* animation components */
/* can be changed after initalisation to alter content and animation behaviour */
@property (nonatomic) NSArray *foldComponents;
@property (nonatomic) FTAnimationContext *animationContext;

/* while subclassing please override. Do not call directly */
-(NSArray*) submitFoldComponents;

/* might be overriden in subclasses to change default params of animation context */
-(void) configureAnimationContext: (FTAnimationContext *) animationContext;


@end
