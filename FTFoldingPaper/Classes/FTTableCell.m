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

#import "FTTableCell.h"

@interface FTTableCell() <FTAnimationViewProtocol>

@end

@implementation FTTableCell{
    CGFloat _initialCellHeight;
    
    BOOL _gradientLayerLayoutIsNeeded;
    BOOL _separatorViewLayoutIsNeeded;
    
    CAGradientLayer *_gradientLayer;
}


#pragma mark -
#pragma mark - Lifecycle

/* called by table model while registering this cell for table view */
- (void)awakeFromNib {
    [super awakeFromNib];
    [self onAwakeFromNib];
}


-(void)layoutSubviews{
    [super layoutSubviews];
    
    if (_separatorViewLayoutIsNeeded){
        _separatorViewLayoutIsNeeded = NO;
        CGFloat separatorWidth = self.bounds.size.width - (self.tableCellSeparator.offsetFromCellLeftEdge + self.tableCellSeparator.offsetFromCellRightEdge);
        self.tableCellSeparator.frame = CGRectMake(self.tableCellSeparator.offsetFromCellLeftEdge,
                                                   self.bounds.size.height - self.tableCellSeparator.height,
                                                   separatorWidth,
                                                   self.tableCellSeparator.height);
    };
    
    
    if (_gradientLayerLayoutIsNeeded){
        _gradientLayerLayoutIsNeeded = NO;
        _gradientLayer.frame = self.contentView.frame;
    }
}

#pragma mark -
#pragma mark - Animation view setup
/* while subclassing please override -(FTAnimationView*) submitAnimationView; */
/* do not call directly */
-(FTAnimationView*) submitAnimationView{
    
    /* Example:
     
     FTAnimationView *animationView = [[FTAnimationView alloc]init];
     return animationView;
     
     */
    
    NSLog(@"::: FTTableCell initialisation ERROR! You must override -(FTAnimationView*) setupAnimationView; in subclasses of FTTableCell %p", self);
    return nil;
}



#pragma mark -
#pragma mark - Gradient layer setup
-(CAGradientLayer*) submitGradientLayer{
    
    /* use only on devices with high performance
     default is nil*/
    
    /* example
     CAGradientLayer *gradientLayer = [[CAGradientLayer alloc]init];
     
     gradientLayer.startPoint = CGPointMake(1.0f, 0.5f);
     gradientLayer.endPoint = CGPointMake(0.0f, 0.5f);
     
     gradientLayer.colors = @[(id)[UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.2f].CGColor,
     (id)[UIColor colorWithRed:0.5f green:0.5f blue:0.5f alpha:0.2f].CGColor];
     */
    
    return nil;
}



#pragma mark -
#pragma mark - Initial setup

-(void) onAwakeFromNib{
    
    self.selectedBackgroundView = nil;
    
    /* save initial cell height */
    _initialCellHeight = self.bounds.size.height;
    
    /* disable selection */
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self requestAnimationView];
    
    [self requestCellSeparator];
    
    [self requestGradientLayer];
}


-(void)requestGradientLayer{
    
    _gradientLayer = [self submitGradientLayer];
    if (_gradientLayer){
        _gradientLayerLayoutIsNeeded = YES;
        [self.layer addSublayer:_gradientLayer];
    }
}



-(void)requestAnimationView{
    
    self.animationView = [self submitAnimationView];
    
    self.animationView.animationViewDelegate = self;
    
    /* set animation view to initial position - at the bottom of the cell, horisontally sized to the screen size and invisible with height 0 */
    self.animationView.frame = CGRectMake(0.0f, self.bounds.size.height, [[UIScreen mainScreen]bounds].size.width, 0.0f);
    
    /* add animation view to the cell hierarchy */
    [self.contentView addSubview:self.animationView];
    
}


-(void) requestCellSeparator{
    
    self.tableCellSeparator = [self submitCellSeparator];
    if (self.tableCellSeparator){
        _separatorViewLayoutIsNeeded = YES;
        [self.contentView addSubview:self.tableCellSeparator];
    }
}

-(FTTableCellSeparator *) submitCellSeparator{
    
    /* default is nil */
    return nil;
}

#pragma mark - Animation operations
-(void) animateWithType: (AnimationType) animationType{
    
    if(animationType == EXPAND_CELL_ANIMATION)
    /* disable subviews clipping to ensure that fold component's subviews are visible */
        self.contentView.clipsToBounds = NO;
    else
        self.contentView.clipsToBounds = YES;
    
    /* hide separator if any for better visual perception during animation */
    if (self.tableCellSeparator)
        [self.tableCellSeparator hide];
    
    [self.animationView animateWithType:animationType];
}



#pragma mark - Animation tools
-(void) updateSelfHeightWithChange: (CGFloat) heightChange{
    
    self.frame = CGRectMake(self.frame.origin.x,
                            self.frame.origin.y,
                            self.frame.size.width,
                            self.frame.size.height + heightChange);

}


#pragma mark - Animation view calls
-(void) onAnimationViewHeightChanged: (CGFloat) heightChangePerFrame
                       animationView: (FTAnimationView *) animationView{
    
    [self updateSelfHeightWithChange:heightChangePerFrame];
    
    /* pass event to the next delegate */
    if (self.cellDelegate)
        [self.cellDelegate onCellHeightChanged:heightChangePerFrame currentHeight:self.bounds.size.height cell:self];
    
    
}


-(void) onAnimationViewAnimationFinishedWithLastFrameHeightChange: (CGFloat) lastFrameHeightChange
                                                    animationType: (AnimationType) animationType
                                                    animationView: (FTAnimationView *) animationView{
    
    /* set final height  */
    [self updateSelfHeightWithChange:lastFrameHeightChange];
    
    /* show separator if any after animation */
    if (self.tableCellSeparator && animationType == COLLAPSE_CELL_ANIMATION)
        [self.tableCellSeparator show];
    
    
    /* pass event to the next delegate */
    if (self.cellDelegate)
        [self.cellDelegate onCellHeightAnimationFinishedWithLastFrameHeightChange:lastFrameHeightChange
                                                                      finalHeight: self.animationView.destinationHeightAfterAnimation + _initialCellHeight                                                                    animationType:animationType
                                                                             cell:self];
}



@end


