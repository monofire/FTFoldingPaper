/*Copyright (c) 2017 monofire <monofirehub@gmail.com>
 
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

#import "ExpandingCellAnimationView.h"

@implementation ExpandingCellAnimationView

-(NSArray *)submitFoldComponents{
    
/* example of animation view with 2 fold components*/
    
    FTFoldComponent *foldComponentA = [[FTFoldComponent alloc]initWithSuperView:self
                                                                 topViewNibName:@"FoldComponentTopLayer"
                                                              bottomViewNibName:@"FoldComponentTopLayer"];
    
    FTFoldComponent *foldComponentB = [[FTFoldComponent alloc]initWithSuperView:self
                                                                 topViewNibName:@"FoldComponentTopLayer"
                                                              bottomViewNibName:@"FoldComponentBottomLayer"];
    
    
    return @[foldComponentA,foldComponentB];
}


-(void)configureAnimationContext:(FTAnimationContext *)animationContext{
    
    /* please refer to FTAnimationContext interface to get the
     full list of possible configuration parameters */
    
    animationContext.expandAnimationDuration = 0.6f;
    animationContext.collapseAnimationDuration = 0.6f;
    animationContext.foldAngleFinalValue = - M_PI/6;
    animationContext.animationMediaTimingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
}






@end
