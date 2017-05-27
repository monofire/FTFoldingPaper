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

#import "FTTableView.h"


/* kCellsBelowMultiplier estimates number of rows that should be moved below collapsing cell
 
 increase if you use cells with big height in expanded state (e.g. cells that cover biggest part of the table view being expanded )
 and you see black gaps between cells during collapse animation
 
 default value is 5
 
 */
#define kCellsBelowMultiplier 5



@interface FTTableView () <FTTableCellAnimationProtocol>
@property (nonatomic,readwrite) FTTableCell *selectedCell;

@end


@implementation FTTableView{
    
    NSMutableArray *_pathsForCellsBelowSelectedCell;
    __weak UITableViewCell *_bottomVisibleCell;
    NSIndexPath *_indexPathAtTheBeginningOfAnimation;
}


#pragma mark -
#pragma mark - Cell animations

-(void) animateCell: (FTTableCell *) cell withAnimationType: (AnimationType) animationType{
    
    if (cell.animationView.animationState == ANIMATION_IDLE){
        
        [self lockUserInteractions]; /* prohibit scrolling & touching during the animation */
        self.selectedCell = cell;
        _indexPathAtTheBeginningOfAnimation = [self indexPathForCell:cell];
        [self populatePathsForCellsBelowSelectedCell:cell animationType:animationType];
        cell.cellDelegate = self;
        [cell animateWithType:animationType];
    }
}



#pragma mark -
#pragma mark - Prepare cells below selected to the animation

/* get cells that are placed below animated cell and should be animated concurrently:
 - move down if animated cell expands
 - move up if animated cell collapses
 */

-(void) populatePathsForCellsBelowSelectedCell:(FTTableCell *) cell
                                 animationType:(AnimationType) animationType{
    
    NSIndexPath *selectedCellPath = _indexPathAtTheBeginningOfAnimation;
    _pathsForCellsBelowSelectedCell = [[NSMutableArray alloc]init];
    
    /* in case of expanding animation - only visible cells below animated cell, should be animated */
    if (animationType == EXPAND_CELL_ANIMATION ){
        
        for (NSIndexPath *indexPath in [self indexPathsForVisibleRows]){
            if (indexPath.row > selectedCellPath.row) /* filter only cells that placed below selected cell */
                [_pathsForCellsBelowSelectedCell addObject:indexPath];
        }
    }
    
    
    /* in case of collapsing animation - visible cells *and* some hidden cells below animated cell, should be animated */
    else{
        
        NSInteger maxVisibleRowForCellsBelowAnimatedCell = [self maxVisibleRowForCellsBelowSelectedCell:selectedCellPath];
        for (NSInteger i = selectedCellPath.row + 1; i <= maxVisibleRowForCellsBelowAnimatedCell; i++ ){ /* +1 means start from row below current animated cell */
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:selectedCellPath.section];
            [_pathsForCellsBelowSelectedCell addObject:indexPath];
        }
    }
    
    /* set pointer on bottom visible cell */
    if (animationType == COLLAPSE_CELL_ANIMATION)
        [self setBottomVisibleCellWithSelectedCell:cell];
    
}


-(NSInteger) maxVisibleRowForCellsBelowSelectedCell:(NSIndexPath *) selectedCellIndexPath{
    
    NSInteger numberOfRowsBelowSelected = [[[self indexPathsForVisibleRows]lastObject]row] - selectedCellIndexPath.row;
    if (numberOfRowsBelowSelected == 0) numberOfRowsBelowSelected = 1; /* adjust cases when no cells below selected are visible */
    
    
    NSInteger estimatedMaxVisibleRowIndex = selectedCellIndexPath.row + numberOfRowsBelowSelected * kCellsBelowMultiplier;
    NSInteger totalNumberOfCells = [self totalNumberOfCellsInTable];
    
    if (estimatedMaxVisibleRowIndex >= totalNumberOfCells)
    /* case when animated cell is placed close to the end of table - no room for doubleRangeOfVisibleRows */
        return totalNumberOfCells -1; /* -1 to get the cell row index from number of cells */
    
    else
    /* case when there is doubleRangeOfVisibleRows below animated cell */
        return estimatedMaxVisibleRowIndex;
}


-(NSInteger) totalNumberOfCellsInTable{
    
    NSInteger totalNumberOfCells = 0;
    for (NSInteger i = 0; i < self.numberOfSections; i++)
        totalNumberOfCells += [self numberOfRowsInSection:i];
    
    return totalNumberOfCells;
}


-(void) setBottomVisibleCellWithSelectedCell: (FTTableCell *) selectedCell {
    
    /* set bottom visible cell as last visible cell below selected */
    
    _bottomVisibleCell = nil;
    /* enumerate from the bottom */
    for (NSInteger i = _pathsForCellsBelowSelectedCell.count -1 ; i >= 0 ; i--){
        
        NSIndexPath *indexPath = [_pathsForCellsBelowSelectedCell objectAtIndex:i];
        UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
        if (cell) /* if cell is visible */{
            _bottomVisibleCell = cell;
            break;
        }
    }
    
    
    /* if no visible cells below selected, set _bottomVisibleCell as selected */
    if (!_bottomVisibleCell)
        _bottomVisibleCell = selectedCell;
    
}



#pragma mark -
#pragma mark - FTTableCell calls landing
-(void) onCellHeightChanged: (CGFloat) cellHeightChangePerFrame
              currentHeight: (CGFloat) currentHeight
                       cell: (FTTableCell *) cell{
    
    
    /* notify client re selected cell height update */
    if (self.tableAnimationDelegate)
        [self.tableAnimationDelegate onSelectedCell:cell
                                       heightUpdate:currentHeight
                                        atIndexPath:_indexPathAtTheBeginningOfAnimation];
    
    
    if (cell.animationView.animationState == COLLAPSING_ANIMATION_IS_PERFORMING){
        [self beginUpdates];
        [self endUpdates];
    }
    
    
    /* move cells below selected */
    [self updateCellsBelowSelectedCellWithHeightChange:cellHeightChangePerFrame selectedCell:cell];
    
    /* update self in case of collapsing animation */
    if (cell.animationView.animationState == COLLAPSING_ANIMATION_IS_PERFORMING){
        [self beginUpdates];
        [self endUpdates];
    }
}



-(void) onCellHeightAnimationFinishedWithLastFrameHeightChange: (CGFloat) lastFrameHeightChange
                                                   finalHeight: (CGFloat) finalHeight
                                                 animationType: (AnimationType) animationType
                                                          cell: (FTTableCell *) cell{
    
    /* notify client re selected cell final height */
    if (self.tableAnimationDelegate)
        [self.tableAnimationDelegate onSelectedCell:cell
                                       heightUpdate:finalHeight
                                        atIndexPath:_indexPathAtTheBeginningOfAnimation];
    
    
    /* move cells below selected */
    [self updateCellsBelowSelectedCellWithHeightChange:lastFrameHeightChange selectedCell:cell];
    
    
    /* notify client that animation is finished  */
    if (animationType == EXPAND_CELL_ANIMATION && self.tableAnimationDelegate)
        [self.tableAnimationDelegate onSelectedCellExpanded:cell atIndexPath:_indexPathAtTheBeginningOfAnimation];
    
    if(animationType == COLLAPSE_CELL_ANIMATION && self.tableAnimationDelegate)
        [self.tableAnimationDelegate onSelectedCellCollapsed:cell atIndexPath:_indexPathAtTheBeginningOfAnimation];
    
    
    /* update self */
    [self beginUpdates];
    [self endUpdates];
    
    
    /* animation is done - unlock ui */
    [self unlockUserInteractions];
}



#pragma mark -
#pragma mark - Cells below selected, animation tools

-(void) updateCellsBelowSelectedCellWithHeightChange:(CGFloat) cellHeightChangePerFrame selectedCell: (FTTableCell*) selectedCell{
    
    
    for (NSIndexPath *indexPath in _pathsForCellsBelowSelectedCell){
        
        UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
        if (cell){
            cell.frame = CGRectMake(cell.frame.origin.x,
                                    cell.frame.origin.y + cellHeightChangePerFrame,
                                    cell.frame.size.width,
                                    cell.frame.size.height);
        }
    }
}



#pragma mark -
#pragma mark - User interaction lock

-(void) lockUserInteractions{
    self.userInteractionEnabled = NO;
}


-(void) unlockUserInteractions{
    self.userInteractionEnabled = YES;
}



@end





