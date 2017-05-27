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

#import "FTAnimationView+Tools.h"

@implementation FTAnimationView (Tools)

-(CGFloat) bottomFoldComponentYTranslation{
    
    FTFoldComponentAnimations *foldComponentAnimations = [self.animationContext.foldComponentsAnimations lastObject];
    return [[foldComponentAnimations.bottomLayerYTranslationAnimation.values lastObject]floatValue];
}


-(void) removeAllAnimations{
    
    [self.layer removeAllAnimations];
    
    for (FTFoldComponent *foldComponent in self.foldComponents) {
        [foldComponent.topLayer removeAllAnimations];
        [foldComponent.bottomLayer removeAllAnimations];
    }
}

-(void) enableZPerspective{
    CATransform3D perspective = CATransform3DIdentity;
    perspective.m34 = self.animationContext.zPerspective;
    self.layer.sublayerTransform = perspective;
}

-(void) disableZPerspective{
    CATransform3D perspective = CATransform3DIdentity;
    perspective.m34 = 0.0f;
    self.layer.sublayerTransform = perspective;
}


-(void) setSelfHeight: (CGFloat) height{
    
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            height);
}



@end
