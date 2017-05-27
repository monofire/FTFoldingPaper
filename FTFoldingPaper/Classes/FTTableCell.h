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

#import <UIKit/UIKit.h>
#import "FTAnimationView.h"
#import "FTTableCellSeparator.h"


/*::: FTTableCell expands UITableViewCell functionality to host FTAnimationView and perform expand/collapse animations */

@class FTTableCell;

@protocol FTTableCellAnimationProtocol <NSObject>

-(void) onCellHeightChanged: (CGFloat) cellHeightChangePerFrame
              currentHeight: (CGFloat) currentHeight
                       cell: (FTTableCell *) cell;

-(void) onCellHeightAnimationFinishedWithLastFrameHeightChange: (CGFloat) lastFrameHeightChange
                                                   finalHeight: (CGFloat) finalHeight
                                                 animationType: (AnimationType) animationType
                                                          cell: (FTTableCell *) cell;
@end


@interface FTTableCell : UITableViewCell

@property (nonatomic, weak) id <FTTableCellAnimationProtocol> cellDelegate;




-(void) animateWithType: (AnimationType) animationType;

@property (nonatomic) FTAnimationView *animationView;
@property (nonatomic) FTTableCellSeparator *tableCellSeparator;

/* while subclassing please override -(FTAnimationView*) submitAnimationView; */
/* do not call directly */
-(FTAnimationView*) submitAnimationView;

/* Submit gradient layer to be applied on the cell. No frame is required. Default value is nil */
-(CAGradientLayer* ) submitGradientLayer;

/* Submit cell separator. Do not override if you need cell without separator */
-(FTTableCellSeparator* ) submitCellSeparator;


@end
