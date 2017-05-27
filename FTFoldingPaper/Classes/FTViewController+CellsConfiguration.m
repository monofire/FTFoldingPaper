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

#import "FTViewController+CellsConfiguration.h"

@implementation FTViewController (CellsConfiguration)

-(void) setCellHeightMetadata: (FTTableCellMetadata*) cellMetadata withCell: (UITableViewCell*) cell  tableModel: (FTTableModel*) tableModel{
    
    
    /* default value for tableCellMetadata.cellCollapsedHeight is -1.  < 0  means height is not set */
    BOOL cellHasHeightMetadata =  cellMetadata.cellCollapsedHeight > 0;
    
    
    /* A: if cell height data is available for this row */
    if (cellHasHeightMetadata){
        
        /*A1: if cell should be collapased */
        if (!cellMetadata.isExpanded)
            cellMetadata.cellCurrentHeight = cellMetadata.cellCollapsedHeight;
        /*A2: cellMetadata.isExpanded scenario will be execuded by default */
    }
    
    
    /* B:  if cell height data is NOT available for this row */
    else{

        CGFloat collapsedHeightForExpandedCell = 0;
        
        /* lookup in already expanded cells pool */
        if (cellMetadata.isExpandable)
            collapsedHeightForExpandedCell = [tableModel collapsedHeightForExpandedCellIfAny:(FTTableCell*)cell];
        
        
        /* if UITableView is trying to reuse already expanded cell for row which should be collapsed */
        /* read and set collapsed height of this cell */
        BOOL collapsedHeightForExpandedCellIsFound = collapsedHeightForExpandedCell > 0; /* -1 means no expanded cell is found  */
        
        if (collapsedHeightForExpandedCellIsFound)
            cellMetadata.cellCollapsedHeight = collapsedHeightForExpandedCell;
        
        
        else
        /* no expanded cell is found  */
        /* means dequeued cell is not expanded and current height is collapsed height */
            cellMetadata.cellCollapsedHeight = cell.bounds.size.height;
        
        /* setup current height if needed */
        BOOL cellCurrentHeightIsNotDefined = cellMetadata.cellCurrentHeight < 0;  /* -1 means cellCurrentHeight is not set  */
        if (cellCurrentHeightIsNotDefined)
            cellMetadata.cellCurrentHeight = cellMetadata.cellCollapsedHeight;
    }
    
    
}

-(void) setAnimationViewConfigurationIfNeededWithCellMetadata: (FTTableCellMetadata*) cellMetadata withCell: (FTTableCell*) expandableCell{
    
    BOOL animationViewNeedsToBeExpanded = cellMetadata.isExpanded &&
    expandableCell.animationView.currentViewConfiguration == ANIMATION_VIEW_IS_COLLAPSED &&
    expandableCell.animationView.animationState == ANIMATION_IDLE;
    
    
    BOOL animationViewNeedsToBeCollapsed = !cellMetadata.isExpanded &&
    expandableCell.animationView.currentViewConfiguration == ANIMATION_VIEW_IS_EXPANDED &&
    expandableCell.animationView.animationState == ANIMATION_IDLE;;
    
    
    if (animationViewNeedsToBeExpanded){
        if (expandableCell.tableCellSeparator)
            [expandableCell.tableCellSeparator hide];
        [expandableCell.animationView configureHeightImmediatelyWithType:EXPAND_CELL_ANIMATION];
    }
    
    if (animationViewNeedsToBeCollapsed){
        if (expandableCell.tableCellSeparator)
            [expandableCell.tableCellSeparator show];
        [expandableCell.animationView configureHeightImmediatelyWithType:COLLAPSE_CELL_ANIMATION];
    }
}

@end
