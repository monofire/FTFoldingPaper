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

#import "ExpandingTableViewCell.h"
#import "ExpandingCellAnimationView.h"




@implementation ExpandingTableViewCell


-(FTAnimationView *)submitAnimationView{
    
    return [[ExpandingCellAnimationView alloc]init];
}


/* do not override if you need cell without separator */
-(FTTableCellSeparator *)submitCellSeparator{
    return [[FTTableCellSeparator alloc]initWithHeight:1.0f
                                offsetFromCellLeftEdge:0.0f
                               offsetFromCellRightEdge:0.0f
                                                 color:[UIColor colorWithRed:92.0f/255.0f green:94.0f/255.0f blue:102.0f/255.0f alpha:0.1f]];
}


@end
