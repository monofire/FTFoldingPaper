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

#import "FTTableCellSeparator.h"




@interface FTTableCellSeparator()

@property (nonatomic,readwrite) CGFloat height;
@property (nonatomic,readwrite) CGFloat offsetFromCellLeftEdge;
@property (nonatomic,readwrite) CGFloat offsetFromCellRightEdge;


@end

@implementation FTTableCellSeparator



-(instancetype)initWithFrame:(CGRect)frame{
    NSLog(@"::: FTTableCellSeparator initialisation ERROR! Please use designated initWithHeight: offsetFromCellLeftEdge: offsetFromCellRightEdge: color: instead");
    return nil;
}

-(instancetype)initWithHeight:(CGFloat)height
       offsetFromCellLeftEdge:(CGFloat)offsetFromCellLeftEdge
      offsetFromCellRightEdge:(CGFloat)offsetFromCellRightEdge
                        color:(UIColor*) color{
    
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.height = height;
        self.offsetFromCellLeftEdge = offsetFromCellLeftEdge;
        self.offsetFromCellRightEdge = offsetFromCellRightEdge;
        self.backgroundColor = color;
    }
    return self;
}


-(void) hide{
    self.alpha = 0;
}


-(void) show{
    self.alpha = 1;
}


@end
