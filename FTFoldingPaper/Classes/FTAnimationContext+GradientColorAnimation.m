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

#import "FTAnimationContext+GradientColorAnimation.h"




@implementation FTAnimationContext (GradientColorAnimation)

#pragma mark -
#pragma mark - Interface

-(FTFoldComponentGradientAnimations*) foldComponentGradientAnimationsWithRange: (struct FoldComponentGradientColorAnimationRange)animationRange
                                                                numberOfFrames:(NSInteger) numberOfFrames{
    
    FTFoldComponentGradientAnimations *animations = [[FTFoldComponentGradientAnimations alloc]init];
    
    animations.topLayerGradientColorAnimation.values = [self colorAnimationFramesWithNumberOfFrames:numberOfFrames
                                                                               startColorFirstValue:animationRange.topFoldStartColorFirstValue
                                                                                startColorLastValue:animationRange.topFoldStartColorLastValue
                                                                                 endColorFirstValue:animationRange.topFoldEndColorFirstValue
                                                                                  endColorLastValue:animationRange.topFoldEndColorLastValue];
    
    
    
    animations.bottomLayerGradientColorAnimation.values = [self colorAnimationFramesWithNumberOfFrames:numberOfFrames
                                                                                  startColorFirstValue:animationRange.bottomFoldStartColorFirstValue
                                                                                   startColorLastValue:animationRange.bottomFoldStartColorLastValue
                                                                                    endColorFirstValue:animationRange.bottomFoldEndColorFirstValue
                                                                                     endColorLastValue:animationRange.bottomFoldEndColorLastValue];
    
    

    animations.topLayerGradientColorAnimationInverted.values = [self colorAnimationFramesWithNumberOfFrames:numberOfFrames
                                                                                       startColorFirstValue:animationRange.topFoldStartColorLastValue
                                                                                        startColorLastValue:animationRange.topFoldStartColorFirstValue
                                                                                         endColorFirstValue:animationRange.topFoldEndColorLastValue
                                                                                          endColorLastValue:animationRange.topFoldEndColorFirstValue];
    
    
    
    
    animations.bottomLayerGradientColorAnimationInverted.values = [self colorAnimationFramesWithNumberOfFrames:numberOfFrames
                                                                                          startColorFirstValue:animationRange.bottomFoldStartColorLastValue
                                                                                           startColorLastValue:animationRange.bottomFoldStartColorFirstValue
                                                                                            endColorFirstValue:animationRange.bottomFoldEndColorLastValue
                                                                                             endColorLastValue:animationRange.bottomFoldEndColorFirstValue];
    return animations;
}



#pragma mark -
#pragma mark - Calculate animation


-(NSMutableArray*) colorAnimationFramesWithNumberOfFrames:(NSInteger) numberOfFrames
                                     startColorFirstValue:(CGColorRef) startColorFirstValue
                                      startColorLastValue:(CGColorRef) startColorLastValue
                                       endColorFirstValue:(CGColorRef) endColorFirstValue
                                        endColorLastValue:(CGColorRef) endColorLastValue{
    
    /* declare output array */
    NSMutableArray *colorAnimationFrames = [[NSMutableArray alloc]initWithCapacity:numberOfFrames];
    
    
    /* set calculation step */
    struct ColorComponents startColorStep = [self colorStepWithNumberOfFrames:numberOfFrames
                                                                   firstValue:startColorFirstValue
                                                                    lastValue:startColorLastValue];
    
    struct ColorComponents endColorStep = [self colorStepWithNumberOfFrames:numberOfFrames
                                                                 firstValue:endColorFirstValue
                                                                  lastValue:endColorLastValue];
    
    CGColorRef startColor = nil;
    CGColorRef endColor = nil;
    
    /* calculate frames values */
    for (NSInteger i = 0; i < numberOfFrames; i++) {
        
        /* if final frame - do not calculate, set final values */
        if (i == numberOfFrames - 1){
            
            startColor = startColorLastValue;
            endColor = endColorLastValue;
            
        } else { /* calculate */
            
            /* get calculated colors */
            startColor = [self colorRefWithColorFirstValue:startColorFirstValue enumerationIndex:i colorStep:startColorStep];
            endColor = [self colorRefWithColorFirstValue:endColorFirstValue enumerationIndex:i colorStep:endColorStep];
        }
        
        /* compose "colors" object */
        NSArray *colors = @[(__bridge id)startColor, (__bridge id)endColor];
        [colorAnimationFrames addObject:colors];
        

    }
    
    return colorAnimationFrames;
}


#pragma mark -
#pragma mark - Calculate color step for gradient color animation

-(struct ColorComponents) colorStepWithNumberOfFrames: (NSInteger) numberOfFrames
                                           firstValue: (CGColorRef)  firstValue
                                            lastValue: (CGColorRef)  lastValue{
    struct ColorComponents colorStep;
    
    /* get range */
    CGFloat* componentsFirst = (CGFloat*)CGColorGetComponents(firstValue);
    CGFloat* componentsLast = (CGFloat*)CGColorGetComponents(lastValue);
    CGFloat alphaFirst = CGColorGetAlpha(firstValue);
    CGFloat alphaLast = CGColorGetAlpha(lastValue);
    
    /* calculate step */
    
    /* "- 1" to address enumeration starting with 0 index */
    colorStep.red = (componentsLast[0] - componentsFirst[0]) / (numberOfFrames - 1);
    colorStep.green = (componentsLast[1] - componentsFirst[1]) / (numberOfFrames - 1);
    colorStep.blue = (componentsLast[2] - componentsFirst[2]) / (numberOfFrames - 1);
    colorStep.alpha = (alphaLast - alphaFirst) / (numberOfFrames - 1);
    
    return colorStep;
}


#pragma mark -
#pragma mark - Calculate color for gradient color animation

-(CGColorRef) colorRefWithColorFirstValue: (CGColorRef) colorFirstValue
                        enumerationIndex: (NSInteger) enumerationIndex
                               colorStep: (struct ColorComponents) colorStep{
    
    
    /* decompose colorRef */
    CGFloat* components = (CGFloat*)CGColorGetComponents(colorFirstValue);
    CGFloat alpha = CGColorGetAlpha(colorFirstValue);
    
    
    /* calculate components values based on first value and step */
    struct ColorComponents calculatedComponents;
    
    calculatedComponents.red =  components[0] + colorStep.red * enumerationIndex;
    calculatedComponents.green = components[1] + colorStep.green * enumerationIndex;
    calculatedComponents.blue =  components[2] + colorStep.blue * enumerationIndex;
    calculatedComponents.alpha = alpha + colorStep.alpha * enumerationIndex;
    
    /* compose colorRef */
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat colorComponents[4] = {calculatedComponents.red, calculatedComponents.green, calculatedComponents.blue, calculatedComponents.alpha};
    CGColorRef cgColorRef = CGColorCreate(colorSpace,colorComponents);

    /* release mem */
    CGColorSpaceRelease(colorSpace);
    components = nil;

    return cgColorRef;
}


@end



