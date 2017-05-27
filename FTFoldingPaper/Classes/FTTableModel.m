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



#import "FTTableModel.h"

@implementation FTTableModel{
    
    NSDictionary *_cellReuseAndXibIDs;
    NSMutableDictionary *_expandedCells;
}



#pragma mark -
#pragma mark - Init
- (instancetype)init
{
    self = [super init];
    if (self) {
        _expandedCells = [[NSMutableDictionary alloc]init];
        _cellReuseAndXibIDs = [self submitCellsIDs];
        self.tableCellsMetadata = [self submitTableCellsMetadata];
    }
    return self;
}




-(NSDictionary*) submitCellsIDs{
    
    NSLog(@"FTTableModel initalisation ERROR!  You have to override   -(NSDictionary*) submitCellsIDs");
    
    /* set here cells that will be used in table... */
    /* usign dictionary format - cell reuse ID : cell xib name */
    
    /* example
     return  @{@"StandardTableViewCellID":@"StandardTableViewCell",
     @"ExpandingTableViewCellID":@"ExpandingTableViewCell"};
     */
    
    return nil;
}


/* design structure of your table view content here... */
-(NSMutableArray *) submitTableCellsMetadata{
    
    NSLog(@"FTTableModel initalisation ERROR!  You have to override   -(NSMutableArray *) submitTableCellsMetadata");
    
    /* example
    for (NSInteger i = 0; i < 15; i++) {
        
        FTTableCellMetadata *tableCellMetadata = nil;
        
        
        if (i==0 || i==2 || i==5 || i==7 || i==12){
            tableCellMetadata =  [[FTTableCellMetadata alloc]initWithReuseID:@"StandardTableViewCellID" isExpandable:NO isExpanded:NO];
            
            [self.tableCellsMetadata addObject:tableCellMetadata];
            continue;
        }
        
        tableCellMetadata = [[FTTableCellMetadata alloc]initWithReuseID:@"ExpandingTableViewCellID" isExpandable:YES isExpanded:NO];
        [self.tableCellsMetadata addObject:tableCellMetadata];
    }
    */
    
    return nil;
}



#pragma mark -
#pragma mark - Table View Controller Interface
-(void) registerCellsForTable: (UITableView *) table {
    
    NSArray *cellReuseIDs = [_cellReuseAndXibIDs allKeys];
    
    for (NSString *cellReuseID in cellReuseIDs){
        NSString *cellXibName = [_cellReuseAndXibIDs objectForKey:cellReuseID];
        UINib *cellNib = [UINib nibWithNibName:cellXibName bundle:nil];
        [table registerNib:cellNib forCellReuseIdentifier:cellReuseID];
    }
}



#pragma mark - Expanded cells pool operations
- (CGFloat) collapsedHeightForExpandedCellIfAny: (FTTableCell *) cell{
    
    NSNumber *collapsedHeight = [_expandedCells objectForKey:[NSValue valueWithPointer:(__bridge const void * _Nullable)(cell)]];
    if (collapsedHeight)
        return [collapsedHeight floatValue];
    
    return -1; /* if no object found = no expanded cells with that address */
}

-(void) addCellToExpandedCellsPool: (FTTableCell *) cell withCollapsedHeight: (CGFloat) collapsedHeight{
    [_expandedCells setObject:[NSNumber numberWithFloat:collapsedHeight] forKey:[NSValue valueWithPointer:(__bridge const void * _Nullable)(cell)]];
}

-(void) removeCellToExpandedCellsPool: (FTTableCell *) cell{
    [_expandedCells removeObjectForKey:[NSValue valueWithPointer:(__bridge const void * _Nullable)(cell)]];
}



@end
