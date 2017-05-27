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

#import "FTFoldComponent.h"


@implementation FTFoldComponent


#pragma mark -
#pragma mark - Init
-(instancetype) initWithSuperView: (UIView *) superview
                   topViewNibName: (NSString* )topViewNibName
                bottomViewNibName: (NSString* )bottomViewNibName{
    
    self = [super init];
    if (self) {
        
        [self initViewsWithTopViewNibName:topViewNibName
                        bottomViewNibName:bottomViewNibName];
        
        [self setViewsWithFrame:superview.frame];
        [self setLayersWithSuperView:superview];
    }
    return self;
}



#pragma mark - Init Views
-(void) initViewsWithTopViewNibName: (NSString* )topFragmentNibName
                  bottomViewNibName: (NSString* )bottomViewNibName{
    
    self.topView = [[[NSBundle mainBundle] loadNibNamed:topFragmentNibName owner:nil options:nil]objectAtIndex:0];
    self.bottomView = [[[NSBundle mainBundle] loadNibNamed:bottomViewNibName owner:nil options:nil]objectAtIndex:0];
}

-(void) setViewsWithFrame: (CGRect) frame{
    
    self.topView.frame = CGRectMake(0.0f,
                                    0.0f,
                                    frame.size.width,
                                    self.topView.bounds.size.height);
    
    
    self.bottomView.frame = CGRectMake(0.0f,
                                       0.0f,
                                       frame.size.width,
                                       self.bottomView.bounds.size.height);
    
}

#pragma mark - Init Layers
-(void) setLayersWithSuperView: (UIView*) superview{
    
    /* assign layers */
    self.topLayer = self.topView.layer;
    self.bottomLayer = self.bottomView.layer;
    
    /* set frames */
    self.topLayer.bounds = self.topView.bounds;
    self.bottomLayer.bounds = self.bottomView.bounds;
    
    
    /* set anchors */
    self.topLayer.anchorPoint = CGPointMake(0.0f, 0.0f);
    self.bottomLayer.anchorPoint = CGPointMake(0.0f, 1.0f);
    
    /* reset position */
    self.topLayer.position = CGPointZero;
    self.bottomLayer.position = CGPointZero;
    
    
    /* add gradient layers */
    [self setGradientLayersWithTopLayer:self.topLayer bottomLayer:self.bottomLayer];
    
    /* rotate layers to hide them from viewer */
    [self.topLayer setValue:[NSNumber numberWithFloat:-M_PI_2] forKeyPath:@"transform.rotation.x"];
    [self.bottomLayer setValue:[NSNumber numberWithFloat:M_PI_2] forKeyPath:@"transform.rotation.x"];
    
    /* enable antialiasing */
    self.topLayer.allowsEdgeAntialiasing = YES;
    self.bottomLayer.allowsEdgeAntialiasing = YES;
    
    
    /* add to superview */
    [superview addSubview:self.topView];
    [superview addSubview:self.bottomView];
    
}



/* init and set gradient layers */
-(void) setGradientLayersWithTopLayer: (CALayer*) topLayer bottomLayer: (CALayer*) bottomLayer{
    
    self.topGradientLayer = [[CAGradientLayer alloc]init];
    self.topGradientLayer.frame = CGRectMake(0.0f, 0.0f, topLayer.bounds.size.width, topLayer.bounds.size.height);
    
    self.topGradientLayer.startPoint = CGPointMake(1.0f, 0.5f);
    self.topGradientLayer.endPoint = CGPointMake(0.0f, 0.5f);
    
    
    self.topGradientLayer.colors = @[(id)[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.2f].CGColor,
                                     (id)[UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:0.2f].CGColor];
    
    [topLayer addSublayer:self.topGradientLayer];
    
    
    
    self.bottomGradientLayer = [[CAGradientLayer alloc]init];
    
    self.bottomGradientLayer.frame = CGRectMake(0.0f, 0.0f, bottomLayer.bounds.size.width, bottomLayer.bounds.size.height);
    
    self.bottomGradientLayer.startPoint = CGPointMake(1.0f, 0.0f);
    self.bottomGradientLayer.endPoint = CGPointMake(0.0f, 1.0f);
    
    
    self.bottomGradientLayer.colors = @[(id)[UIColor colorWithRed:0.2f green:0.2f blue:0.2f alpha:0.2f].CGColor,
                                        (id)[UIColor colorWithRed:1 green:1 blue:1 alpha:0.05f].CGColor];
    
    [bottomLayer addSublayer:self.bottomGradientLayer];
}




@end
