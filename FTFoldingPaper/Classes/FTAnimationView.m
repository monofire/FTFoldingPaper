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

#import "FTAnimationView.h"
#import "FTAnimationView+Tools.h"

@interface FTAnimationView()

@property (nonatomic,readwrite) AnimationState animationState;
@property (nonatomic,readwrite) CurrentViewConfiguration currentViewConfiguration;

@end

@implementation FTAnimationView{
    
    CADisplayLink *_displayLink;
    CALayer *_yTranslationChangeGuideLayer;
    CGFloat _previousYTranslation;
    AnimationType _currentAnimationType;
    BOOL _foldComponentsLayoutIsNeeded;
}



#pragma mark -
#pragma mark - Init
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self onInit];
    }
    return self;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self onInit];
    }
    return self;
}

-(void) onInit{
    self.currentViewConfiguration = ANIMATION_VIEW_IS_COLLAPSED;
    self.backgroundColor = [UIColor blackColor];
    self.autoresizesSubviews = NO;
    self.clipsToBounds = YES;
    self.layer.anchorPoint = CGPointMake(0.5f, 0.0f);
    _foldComponentsLayoutIsNeeded = NO;
}


#pragma mark -
#pragma mark - Lifecycle
-(void)layoutSubviews{
    [super layoutSubviews];
    if (!_foldComponentsLayoutIsNeeded){
        _foldComponentsLayoutIsNeeded = YES;
        [self requestFoldComponens];
        [self requestAnimationContext];
    }
}

-(void)dealloc{
    [self releaseDisplayLink];
}



#pragma mark -
#pragma mark - Fold components and animation context setup

-(void) requestFoldComponens{
    self.foldComponents = [self submitFoldComponents];
}


-(void) requestAnimationContext{
    self.animationContext = [[FTAnimationContext alloc]initWithCellFoldComponents:self.foldComponents];
    [self configureAnimationContext:self.animationContext];
    [self.animationContext calculate];
}


-(NSArray*) submitFoldComponents{
    
    /* Example:
     FTFoldComponent *foldComponentA = [[FTFoldComponent alloc]initWithSuperView:self
     topViewNibName:@"FoldComponentTopLayer"
     bottomViewNibName:@"FoldComponentBottomLayer"];
     
     FTFoldComponent *foldComponentB = [[FTFoldComponent alloc]initWithSuperView:self
     topViewNibName:@"FoldComponentTopLayerB"
     bottomViewNibName:@"FoldComponentBottomLayerB"];
     
     return @[foldComponentA,foldComponentB];
     */
    
    NSLog(@"::: FTAnimationView initialisation ERROR.  You must override -(void) submitFoldComponents; in subclasses of FTAnimationView %p", self);
    return nil;
}


-(void) configureAnimationContext: (FTAnimationContext *) animationContext{
    /* might be overriden in subclasses to change default params of animation context */
}


#pragma mark -
#pragma mark - Animation operations

-(void) animateWithType: (AnimationType) animationType{
    
    self.animationState = (animationType == EXPAND_CELL_ANIMATION) ?
    EXPANDING_ANIMATION_IS_PERFORMING :
    COLLAPSING_ANIMATION_IS_PERFORMING;
    
    
    _currentAnimationType = animationType;
    [self initDisplayLink];
    [self initFrameMetadataCalculationWithAnimationType:animationType];
    
    [self composeAndStartAnimationWithType:animationType];
}


#pragma mark - Immediate animation
-(void) configureHeightImmediatelyWithType:(AnimationType) animationType{
    
    if (animationType == EXPAND_CELL_ANIMATION)
        [self enableZPerspective];
    
    /* enumerate fold components */
    for (NSUInteger i = 0; i < self.foldComponents.count; i++){
        
        /* get fold component */
        FTFoldComponent *foldComponent = [self.foldComponents objectAtIndex:i];
        
        /* get animations object */
        FTFoldComponentAnimations *foldComponentAnimations = [self.animationContext.foldComponentsAnimations objectAtIndex:i];
        
        CAKeyframeAnimation *topLayerRotationAnimation = (animationType == EXPAND_CELL_ANIMATION) ?
        foldComponentAnimations.topLayerRotationAnimation :
        foldComponentAnimations.topLayerRotationAnimationInverted;
        
        CAKeyframeAnimation *bottomLayerRotationAnimation = (animationType == EXPAND_CELL_ANIMATION) ?
        foldComponentAnimations.bottomLayerRotationAnimation :
        foldComponentAnimations.bottomLayerRotationAnimationInverted;
        
        CAKeyframeAnimation *topLayerYTransitionAnimation = (animationType == EXPAND_CELL_ANIMATION) ?
        foldComponentAnimations.topLayerYTranslationAnimation :
        foldComponentAnimations.topLayerYTranslationAnimationInverted;
        
        CAKeyframeAnimation *bottomLayerYTranslationAnimation = (animationType == EXPAND_CELL_ANIMATION) ?
        foldComponentAnimations.bottomLayerYTranslationAnimation :
        foldComponentAnimations.bottomLayerYTranslationAnimationInverted;
        
        
        /* set final values */
        [foldComponent.topLayer setValue:
         [NSNumber numberWithFloat:[[topLayerRotationAnimation.values lastObject]floatValue]]
                              forKeyPath:@"transform.rotation.x"];
        
        [foldComponent.bottomLayer setValue:
         [NSNumber numberWithFloat:[[bottomLayerRotationAnimation.values lastObject]floatValue]]
                                 forKeyPath:@"transform.rotation.x"];
        
        
        if (i > 0)
            [foldComponent.topLayer setValue:
             [NSNumber numberWithFloat:[[topLayerYTransitionAnimation.values lastObject]floatValue]] forKeyPath:@"transform.translation.y"];
        
        [foldComponent.bottomLayer setValue:
         [NSNumber numberWithFloat:[[bottomLayerYTranslationAnimation.values lastObject]floatValue]] forKeyPath:@"transform.translation.y"];
    }
    
    
    /* set self height */
    CGFloat selfHeight = (animationType == EXPAND_CELL_ANIMATION) ?
    self.bounds.size.height + [self bottomFoldComponentYTranslation] :
    0.0f;
    
    [self setSelfHeight:selfHeight];
    
    
    /* set configuration */
    self.currentViewConfiguration = (animationType == EXPAND_CELL_ANIMATION) ?
    ANIMATION_VIEW_IS_EXPANDED : ANIMATION_VIEW_IS_COLLAPSED;
    
}


#pragma mark - Animation
-(void) composeAndStartAnimationWithType: (AnimationType) animationType {
    
    /* set animation transaction duration */
    CGFloat animationDuration = (animationType == EXPAND_CELL_ANIMATION) ?
    (self.animationContext.expandAnimationDuration) :
    (self.animationContext.collapseAnimationDuration);
    
    
    /* set animation transaction */
    [CATransaction begin];
    
    
    /* set completion handler */
    [CATransaction setCompletionBlock:^{
        [self onAnimationCompleted];
    }];
    
    
    /* animation duration */
    [CATransaction setValue:[NSNumber numberWithFloat:animationDuration]
                     forKey:kCATransactionAnimationDuration];
    
    /* enable perspective */
    [self enableZPerspective];
    
    
    /* get parent layer animation object */
    CAKeyframeAnimation *parentLayerHeightAnimation = (animationType == EXPAND_CELL_ANIMATION) ?
    self.animationContext.parentLayerAnimations.parentLayerHeightAnimation :
    self.animationContext.parentLayerAnimations.parentLayerHeightAnimationInverted;
    
    /* set parent layer animation */
    [self.layer addAnimation:parentLayerHeightAnimation forKey:@"parent layer height animation"];
    
    

    /* enumerate fold components */
    for (NSUInteger i = 0; i < self.foldComponents.count; i++){
        
        /* get fold component */
        FTFoldComponent *foldComponent = [self.foldComponents objectAtIndex:i];
        
        /* get animations object */
        FTFoldComponentAnimations *foldComponentAnimations = [self.animationContext.foldComponentsAnimations objectAtIndex:i];
        
        CAKeyframeAnimation *topLayerRotationAnimation = (animationType == EXPAND_CELL_ANIMATION) ?
        foldComponentAnimations.topLayerRotationAnimation :
        foldComponentAnimations.topLayerRotationAnimationInverted;
        
        CAKeyframeAnimation *bottomLayerRotationAnimation = (animationType == EXPAND_CELL_ANIMATION) ?
        foldComponentAnimations.bottomLayerRotationAnimation :
        foldComponentAnimations.bottomLayerRotationAnimationInverted;
        
        CAKeyframeAnimation *topLayerYTransitionAnimation = (animationType == EXPAND_CELL_ANIMATION) ?
        foldComponentAnimations.topLayerYTranslationAnimation :
        foldComponentAnimations.topLayerYTranslationAnimationInverted;
        
        CAKeyframeAnimation *bottomLayerYTranslationAnimation = (animationType == EXPAND_CELL_ANIMATION) ?
        foldComponentAnimations.bottomLayerYTranslationAnimation :
        foldComponentAnimations.bottomLayerYTranslationAnimationInverted;
        
        
        
        /* apply rotation*/
        [foldComponent.topLayer addAnimation:topLayerRotationAnimation forKey:@"topLayer rotation animation"];
        [foldComponent.bottomLayer addAnimation:bottomLayerRotationAnimation forKey:@"bottomLayer rotation animation"];
        
        
        /* apply y-translation */
        /* starting from the second component, Y translation is used not only for the bottom but also for the topLayer */
        if (i > 0)
            [foldComponent.topLayer addAnimation:topLayerYTransitionAnimation forKey:@"topLayer y-translation animation"];
        
        [foldComponent.bottomLayer addAnimation:bottomLayerYTranslationAnimation forKey:@"bottomLayer y-translation animation"];
        
        
        
        /* get gradient animation object */
        CAKeyframeAnimation  *topLayerGradientColorAnimation = (animationType == EXPAND_CELL_ANIMATION) ?
        self.animationContext.foldComponentGradientAnimations.topLayerGradientColorAnimation :
        self.animationContext.foldComponentGradientAnimations.topLayerGradientColorAnimationInverted;
        
        CAKeyframeAnimation  *bottomLayerGradientColorAnimation = (animationType == EXPAND_CELL_ANIMATION) ?
        self.animationContext.foldComponentGradientAnimations.bottomLayerGradientColorAnimation :
        self.animationContext.foldComponentGradientAnimations.bottomLayerGradientColorAnimationInverted;
        
        
        /* apply gradient animation */
        [foldComponent.topGradientLayer addAnimation:topLayerGradientColorAnimation forKey:@"topLayer gradient color animation"];
        [foldComponent.bottomGradientLayer addAnimation:bottomLayerGradientColorAnimation forKey:@"bottomLayer gradient color animation"];
        
        
    
        /* set final rotation values */
        [foldComponent.topLayer setValue:
         [NSNumber numberWithFloat:[[topLayerRotationAnimation.values lastObject]floatValue]] forKeyPath:@"transform.rotation.x"];
        
        [foldComponent.bottomLayer setValue:
         [NSNumber numberWithFloat:[[bottomLayerRotationAnimation.values lastObject]floatValue]] forKeyPath:@"transform.rotation.x"];
        
        /* set final translation values */
        if (i > 0)
            [foldComponent.topLayer setValue:
             [NSNumber numberWithFloat:[[topLayerYTransitionAnimation.values lastObject]floatValue]] forKeyPath:@"transform.translation.y"];
        
        [foldComponent.bottomLayer setValue:
         [NSNumber numberWithFloat:[[bottomLayerYTranslationAnimation.values lastObject]floatValue]] forKeyPath:@"transform.translation.y"];
        
        
    }
    
    
    /* set final height value for parent layer */
    [self.layer  setValue: [NSNumber numberWithFloat:[[parentLayerHeightAnimation.values lastObject]floatValue]] forKeyPath:@"bounds.size.height"] ;
    
    
    /* start animation transaction */
    [CATransaction commit];
}




#pragma mark - Animation events

-(void) onFrameUpdate{
    
    CGFloat heightChangePerFrame = [self heightChangePerFrame];
    
    if (self.animationViewDelegate)
        [self.animationViewDelegate onAnimationViewHeightChanged:heightChangePerFrame  animationView:self];
}


-(void) onAnimationCompleted{
    
    [self removeAllAnimations];
    
    /* disable perspective in order to hide from viewer fold components with -pi/2 angle on x-axis */
    if (_currentAnimationType == COLLAPSE_CELL_ANIMATION )
        [self disableZPerspective];
    
    [self releaseDisplayLink];
    
    self.animationState = ANIMATION_IDLE;
    
    CGFloat lastFrameHeightChange = [self finalHeightChange];
    
    /* update state */
    self.currentViewConfiguration = (_currentAnimationType == EXPAND_CELL_ANIMATION) ?
    ANIMATION_VIEW_IS_EXPANDED : ANIMATION_VIEW_IS_COLLAPSED;
    
    
    if (self.animationViewDelegate)
        [self.animationViewDelegate onAnimationViewAnimationFinishedWithLastFrameHeightChange:lastFrameHeightChange
                                                                                animationType:_currentAnimationType                                                                               animationView:self];
}





#pragma mark - Display link

-(void) initDisplayLink{
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(onFrameUpdate)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}


-(void) releaseDisplayLink{
    if (_displayLink)
        [_displayLink removeFromRunLoop:[NSRunLoop mainRunLoop]  forMode:NSDefaultRunLoopMode];
    _displayLink = nil;
}



#pragma mark - Frame operations
-(void) initFrameMetadataCalculationWithAnimationType: (AnimationType) animationType{
    
    /* set layer that will be inspected during animation to obtain y-translation change */
    FTFoldComponent *lastFoldComponent = [self.foldComponents lastObject];
    _yTranslationChangeGuideLayer = lastFoldComponent.bottomLayer;
    
    
    
    /* reset y translation marker */
    _previousYTranslation = _yTranslationChangeGuideLayer.frame.origin.y + _yTranslationChangeGuideLayer.frame.size.height;
    

    
    /* set destination y-translation value (value to be achieved at the end of animation) */
    FTFoldComponentAnimations *foldComponentAnimations = [self.animationContext.foldComponentsAnimations lastObject];
    
    NSArray *bottomLayerYTranslationAnimationFrames = (animationType == EXPAND_CELL_ANIMATION) ?
    foldComponentAnimations.bottomLayerYTranslationAnimation.values :
    foldComponentAnimations.bottomLayerYTranslationAnimationInverted.values;
    
    self.destinationHeightAfterAnimation = [[bottomLayerYTranslationAnimationFrames lastObject]floatValue];
}


-(CGFloat) heightChangePerFrame{
    
    CGFloat currentYTranslation = _yTranslationChangeGuideLayer.presentationLayer.frame.origin.y + _yTranslationChangeGuideLayer.presentationLayer.frame.size.height;
    CGFloat heightChangePerFrame = currentYTranslation - _previousYTranslation;
    _previousYTranslation = currentYTranslation;
    
    return heightChangePerFrame;
}


-(CGFloat) finalHeightChange{
    return  self.destinationHeightAfterAnimation - _previousYTranslation;
}



@end








