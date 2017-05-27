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

#import "FTAnimationContext+FoldComponentsAnimation.h"
#import "FTFoldComponent.h"

#define trigCalculationsEPS 0.01f


CG_INLINE struct AnimationValueRange
AnimationValueRangeMake(CGFloat fromValue, CGFloat toValue)
{
    struct AnimationValueRange range; range.fromValue = fromValue; range.toValue = toValue; return range;
}




@implementation FTAnimationContext (FoldComponentsAnimation)



#pragma mark -
#pragma mark - Interface

-(NSArray *) foldAnimationsForFoldComponents: (NSArray *) foldComponents
                       parentLayerAnimations: (FTParentLayerAnimations *) parentLayerAnimations{
    
    /* calculate animation time frames */
    NSArray *timeFrames = [self animationTimeFrames];
    
    /* calculate angle range */
    struct AnimationValueRange angleRangeBetweenFolds = [self angleRangeBetweenFolds];
    
    /* calculate angle step */
    CGFloat angleChangeStepFromRange = [self angleChangeStepFromRange:angleRangeBetweenFolds];
    
    
    return [self animationsForFoldComponents:foldComponents
                      angleRangeBetweenFolds:angleRangeBetweenFolds
                             angleChangeStep:angleChangeStepFromRange
                         animationTimeFrames:timeFrames
                       parentLayerAnimations:parentLayerAnimations];
    
}



#pragma mark -
#pragma mark - Setup


-(NSArray *) animationTimeFrames{
    
    NSMutableArray *animationTimeFrames =  [[NSMutableArray alloc]initWithCapacity:self.numberOfAnimationInterpolationFrames];
    
    for (NSInteger i = 0; i < self.numberOfAnimationInterpolationFrames; i++){
        
        /* calculate time frame */
        CGFloat timeFrame = (CGFloat)i / (CGFloat)(self.numberOfAnimationInterpolationFrames - 1); /* "- 1" to address enumeration starting with 0 index */
        [animationTimeFrames addObject:[NSNumber numberWithFloat:timeFrame]];
    }
    return animationTimeFrames;
}


-(struct AnimationValueRange) angleRangeBetweenFolds{
    
    /* set angle change range (between expanding/collapsing fold layers) */
    return AnimationValueRangeMake( -M_PI_2, self.foldAngleFinalValue);
}


-(CGFloat) angleChangeStepFromRange: (struct AnimationValueRange) angleRangeBetweenFolds{
    
    /* calculate angle change per step */
    return (angleRangeBetweenFolds.toValue - angleRangeBetweenFolds.fromValue) /
    (self.numberOfAnimationInterpolationFrames - 1 ); /* "- 1" to address enumeration starting with 0 index */
}





#pragma mark -
#pragma mark - Animations Creation

-(NSArray *) animationsForFoldComponents: (NSArray *) foldComponents
                  angleRangeBetweenFolds: (struct AnimationValueRange) angleRangeBetweenFolds
                         angleChangeStep: (CGFloat) angleChangeStep
                     animationTimeFrames:(NSArray *) animationTimeFrames
                   parentLayerAnimations: (FTParentLayerAnimations *) parentLayerAnimations{
    
    /* init output array */
    NSMutableArray *foldComponentsAnimations = [[NSMutableArray alloc]initWithCapacity:foldComponents.count];
    
    
    /* enumerate fold components */
    for (NSInteger i = 0; i < foldComponents.count; i++){
        
        
        
        /* get upper fold components if any  */
        NSInteger upperFoldAnimatonIndex = i - 1;
        FTFoldComponentAnimations *upperFoldAnimations = (upperFoldAnimatonIndex < 0) ? /* if first fold element - return nil */
        nil:
        [foldComponentsAnimations objectAtIndex:upperFoldAnimatonIndex];
        
        
        /* get current fold component */
        FTFoldComponent *currentFold = [foldComponents objectAtIndex:i];
        CGFloat currentFoldTopLayerHeight = currentFold.topLayer.bounds.size.height;
        
        
        
        /* create new foldAnimations object */
        FTFoldComponentAnimations *foldAnimations = [[FTFoldComponentAnimations alloc]init];
        
        
        
        /* set new foldAnimations object */
        
        BOOL bottomComponentIsReached = (i == foldComponents.count - 1);
        
        [self setValuesForFoldAnimations:foldAnimations
                 withUpperFoldAnimations:upperFoldAnimations
               currentFoldTopLayerHeight:currentFoldTopLayerHeight
                  angleRangeBetweenFolds:angleRangeBetweenFolds
                         angleChangeStep:angleChangeStep
     calculateParentLayerHeightDirective:bottomComponentIsReached
                   parentLayerAnimations:parentLayerAnimations];
        
        
        [self setTimeFramesForFoldAnimations:foldAnimations animationTimeFrames:animationTimeFrames];
        
        [self setTimingFunctionForFoldAnimations:foldAnimations];
        
        
        
        /* add new foldAnimations object to collection */
        [foldComponentsAnimations addObject:foldAnimations];
        
        
    }
    
    return foldComponentsAnimations;
}






#pragma mark -
#pragma mark - Fold movement calculation


-(void) setValuesForFoldAnimations: (FTFoldComponentAnimations *) foldAnimations
           withUpperFoldAnimations: (FTFoldComponentAnimations *) upperFoldAnimation
         currentFoldTopLayerHeight: (CGFloat) currentFoldTopLayerHeight
            angleRangeBetweenFolds: (struct AnimationValueRange) angleRangeBetweenFolds
                   angleChangeStep: (CGFloat) angleChangeStep
calculateParentLayerHeightDirective: (BOOL) calculateParentLayerHeightDirective
             parentLayerAnimations: (FTParentLayerAnimations *) parentLayerAnimations{
    
    
    NSMutableArray *topLayerRotationAnimationFrames = [[NSMutableArray alloc]initWithCapacity:self.numberOfAnimationInterpolationFrames];
    NSMutableArray *bottomLayerRotationAnimationFrames = [[NSMutableArray alloc]initWithCapacity:self.numberOfAnimationInterpolationFrames];
    NSMutableArray *topLayerYTranslationAnimationFrames = [[NSMutableArray alloc]initWithCapacity:self.numberOfAnimationInterpolationFrames];
    NSMutableArray *bottomLayerYTranslationAnimationFrames = [[NSMutableArray alloc]initWithCapacity:self.numberOfAnimationInterpolationFrames];
    
    
    NSMutableArray *topLayerRotationAnimationFramesInverted = [[NSMutableArray alloc]initWithCapacity:self.numberOfAnimationInterpolationFrames];
    NSMutableArray *bottomLayerRotationAnimationFramesInverted = [[NSMutableArray alloc]initWithCapacity:self.numberOfAnimationInterpolationFrames];
    NSMutableArray *topLayerYTranslationAnimationFramesInverted = [[NSMutableArray alloc]initWithCapacity:self.numberOfAnimationInterpolationFrames];
    NSMutableArray *bottomLayerYTranslationAnimationFramesInverted = [[NSMutableArray alloc]initWithCapacity:self.numberOfAnimationInterpolationFrames];
    
    NSMutableArray *parentLayerHeightAnimationFrames = [[NSMutableArray alloc]initWithCapacity:self.numberOfAnimationInterpolationFrames];
    NSMutableArray *parentLayerHeightAnimationFramesInverted = [[NSMutableArray alloc]initWithCapacity:self.numberOfAnimationInterpolationFrames];
    
    
    /* calculate frames values */
    for (NSInteger i = 0; i < self.numberOfAnimationInterpolationFrames; i++) {
        
        
        /* calculate params */
        struct AnimationFrameParams animationFrameParams = [self animationFrameParamsWithUpperFoldAnimations:upperFoldAnimation
                                                                                   currentFoldTopLayerHeight:currentFoldTopLayerHeight
                                                                                      angleRangeBetweenFolds:angleRangeBetweenFolds
                                                                                             angleChangeStep:angleChangeStep
                                                                                                  frameIndex:i
                                                                                                    inverted:NO];
        
        [topLayerRotationAnimationFrames addObject:[NSNumber numberWithFloat:animationFrameParams.topLayerRotation]];
        [bottomLayerRotationAnimationFrames addObject:[NSNumber numberWithFloat:animationFrameParams.bottomLayerRotation]];
        [topLayerYTranslationAnimationFrames addObject:[NSNumber numberWithFloat:animationFrameParams.topLayerYTranslation]];
        [bottomLayerYTranslationAnimationFrames addObject:[NSNumber numberWithFloat:animationFrameParams.bottomLayerYTranslation]];
        
        
        
        /* inverted = collapse animation */
        struct AnimationFrameParams animationFrameParamsInverted = [self animationFrameParamsWithUpperFoldAnimations:upperFoldAnimation
                                                                                           currentFoldTopLayerHeight:currentFoldTopLayerHeight
                                                                                              angleRangeBetweenFolds:angleRangeBetweenFolds
                                                                                                     angleChangeStep:angleChangeStep
                                                                                                          frameIndex:i
                                                                                                            inverted:YES];
        
        [topLayerRotationAnimationFramesInverted addObject:[NSNumber numberWithFloat:animationFrameParamsInverted.topLayerRotation]];
        [bottomLayerRotationAnimationFramesInverted addObject:[NSNumber numberWithFloat:animationFrameParamsInverted.bottomLayerRotation]];
        [topLayerYTranslationAnimationFramesInverted addObject:[NSNumber numberWithFloat:animationFrameParamsInverted.topLayerYTranslation]];
        [bottomLayerYTranslationAnimationFramesInverted addObject:[NSNumber numberWithFloat:animationFrameParamsInverted.bottomLayerYTranslation]];
        
        
        /* calculate parent layer height if this is bottom fold component */
        
        if (calculateParentLayerHeightDirective){
            CGFloat parentLayerHeight = animationFrameParams.foldHeight + animationFrameParams.topLayerYTranslation;
            CGFloat parentLayerHeightInvertedAnimation = animationFrameParamsInverted.foldHeight + animationFrameParamsInverted.topLayerYTranslation;
            
            
            [parentLayerHeightAnimationFrames addObject:[NSNumber numberWithFloat:parentLayerHeight]];
            [parentLayerHeightAnimationFramesInverted addObject:[NSNumber numberWithFloat:parentLayerHeightInvertedAnimation]];
        }
        
        
    }
    
    /* set frame values */
    foldAnimations.topLayerRotationAnimation.values = topLayerRotationAnimationFrames;
    foldAnimations.bottomLayerRotationAnimation.values = bottomLayerRotationAnimationFrames;
    foldAnimations.topLayerYTranslationAnimation.values = topLayerYTranslationAnimationFrames;
    foldAnimations.bottomLayerYTranslationAnimation.values = bottomLayerYTranslationAnimationFrames;
    
    foldAnimations.topLayerRotationAnimationInverted.values = topLayerRotationAnimationFramesInverted;
    foldAnimations.bottomLayerRotationAnimationInverted.values = bottomLayerRotationAnimationFramesInverted;
    foldAnimations.topLayerYTranslationAnimationInverted.values = topLayerYTranslationAnimationFramesInverted;
    foldAnimations.bottomLayerYTranslationAnimationInverted.values = bottomLayerYTranslationAnimationFramesInverted;
    
    
    
    if (calculateParentLayerHeightDirective){
    
        /* set parent layer animations obj */
        parentLayerAnimations.parentLayerHeightAnimation.values = parentLayerHeightAnimationFrames;
        parentLayerAnimations.parentLayerHeightAnimationInverted.values = parentLayerHeightAnimationFramesInverted;
    }
    
}




#pragma mark -
#pragma mark - Fold movement calculation helpers

-(void) setTimeFramesForFoldAnimations: (FTFoldComponentAnimations *) foldAnimations
                   animationTimeFrames: (NSArray*) animationTimeFrames{
    
    foldAnimations.topLayerRotationAnimation.keyTimes = animationTimeFrames;
    foldAnimations.bottomLayerRotationAnimation.keyTimes = animationTimeFrames;
    foldAnimations.topLayerYTranslationAnimation.keyTimes = animationTimeFrames;
    foldAnimations.bottomLayerYTranslationAnimation.keyTimes = animationTimeFrames;
    
    foldAnimations.topLayerRotationAnimationInverted.keyTimes = animationTimeFrames;
    foldAnimations.bottomLayerRotationAnimationInverted.keyTimes = animationTimeFrames;
    foldAnimations.topLayerYTranslationAnimationInverted.keyTimes = animationTimeFrames;
    foldAnimations.bottomLayerYTranslationAnimationInverted.keyTimes = animationTimeFrames;
    
}



-(void) setTimingFunctionForFoldAnimations: (FTFoldComponentAnimations *) foldAnimations{
    
    foldAnimations.topLayerRotationAnimation.timingFunction = self.animationMediaTimingFunction;
    foldAnimations.bottomLayerRotationAnimation.timingFunction = self.animationMediaTimingFunction;
    foldAnimations.topLayerYTranslationAnimation.timingFunction = self.animationMediaTimingFunction;
    foldAnimations.bottomLayerYTranslationAnimation.timingFunction = self.animationMediaTimingFunction;
    
    foldAnimations.topLayerRotationAnimationInverted.timingFunction = self.animationMediaTimingFunction;
    foldAnimations.bottomLayerRotationAnimationInverted.timingFunction = self.animationMediaTimingFunction;
    foldAnimations.topLayerYTranslationAnimationInverted.timingFunction = self.animationMediaTimingFunction;
    foldAnimations.bottomLayerYTranslationAnimationInverted.timingFunction = self.animationMediaTimingFunction;
}




-(struct AnimationFrameParams) animationFrameParamsWithUpperFoldAnimations: (FTFoldComponentAnimations*) upperFoldAnimation
                                                 currentFoldTopLayerHeight: (CGFloat) currentFoldTopLayerHeight
                                                    angleRangeBetweenFolds: (struct AnimationValueRange) angleRangeBetweenFolds
                                                           angleChangeStep: (CGFloat) angleChangeStep
                                                                frameIndex: (NSInteger) frameIndex
                                                                  inverted: (BOOL) inverted{
    
    struct AnimationFrameParams animationFrameParams;
    
    /* calculate topLayer angle */
    animationFrameParams.topLayerRotation = (inverted) ?
    (angleRangeBetweenFolds.toValue - frameIndex * angleChangeStep) :
    (angleRangeBetweenFolds.fromValue + frameIndex * angleChangeStep);
    
    
    /* calculate bottomLayer angle based on topLayer angle */
    animationFrameParams.bottomLayerRotation = animationFrameParams.topLayerRotation * -1.0f;
    
    /* calculate height of rotating topLayer and bottom layers = distance from top to the bottom of fold component */
    animationFrameParams.foldHeight = [self foldHeightWithTopLayerHeight:currentFoldTopLayerHeight
                                    currentFoldComponentTopLayerRotation:animationFrameParams.topLayerRotation];
    
    
    
    /* calculate y-translation based on current fold height and upper fold translation */
    animationFrameParams.topLayerYTranslation = [self upperFoldBottomLayerYTranslationWithTimeFrameIndex:frameIndex
                                                                                     upperFoldAnimations:upperFoldAnimation
                                                                                                inverted:inverted];
    
    
    animationFrameParams.bottomLayerYTranslation = animationFrameParams.topLayerYTranslation + animationFrameParams.foldHeight;
    
    
    return animationFrameParams;
    
}



-(CGFloat) upperFoldBottomLayerYTranslationWithTimeFrameIndex: (NSInteger) timeFrameIndex
                                          upperFoldAnimations: (FTFoldComponentAnimations* __nullable) upperFoldAnimations
                                                     inverted: (BOOL) inverted {
    
    if (upperFoldAnimations){
        
        CGFloat upperFoldBottomLayerYTranslation = (inverted) ?
        
        [[upperFoldAnimations.bottomLayerYTranslationAnimationInverted.values
          objectAtIndex:timeFrameIndex]floatValue] :
        
        [[upperFoldAnimations.bottomLayerYTranslationAnimation.values
          objectAtIndex:timeFrameIndex]floatValue];
        
        return upperFoldBottomLayerYTranslation;
    }
    
    return 0.0f;
}



-(CGFloat) foldHeightWithTopLayerHeight: (CGFloat) topLayerHeight
   currentFoldComponentTopLayerRotation: (CGFloat) currentFoldComponentTopLayerRotation{
    
    /* calculate angle between the fold component's layers */
    CGFloat angleBetweenLayers = M_PI - 2.0f * fabs(currentFoldComponentTopLayerRotation);
    
    CGFloat EPS = fabs (M_PI - angleBetweenLayers);
    if ( EPS > trigCalculationsEPS ) /* if there is valid angle to apply trigonometry */
        return topLayerHeight * ( sin(angleBetweenLayers) / sin(fabs(currentFoldComponentTopLayerRotation) ) );
    else
        return topLayerHeight * 2.0f;
}



@end
