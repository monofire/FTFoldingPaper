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

#import "ExampleTableModel.h"

#define kNumberOfCellsInTable 15

@implementation ExampleTableModel

-(NSDictionary *)submitCellsIDs{
    
    return  @{@"ExpandingTableViewCellID":@"ExpandingTableViewCell"};
    
}


/* Submit your table architecture. In this example table consists only from cells of one type.
 You can implement any custom architecture, combining different cell types for different table rows */

-(NSArray *)submitTableCellsMetadata{
    
    NSMutableArray *cellsMetadata = [[NSMutableArray alloc]init];
    
    for (NSInteger i = 0; i < kNumberOfCellsInTable; i++) {
        
        FTTableCellMetadata *tableCellMetadata = nil;
        
        tableCellMetadata = [[FTTableCellMetadata alloc]initWithReuseID:@"ExpandingTableViewCellID" isExpandable:YES isExpanded:NO];
        
        [cellsMetadata addObject:tableCellMetadata];
    }
    
    return cellsMetadata;
}

@end
