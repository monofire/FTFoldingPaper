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

#import "FTViewController.h"
#import "FTViewController+CellsConfiguration.h"

@interface FTViewController ()<FTTableViewAnimationProtocol>

@end


#pragma mark -
#pragma mark - Init

@implementation FTViewController{
    FTTableView *_tableView;
    FTTableModel *_tableModel;
}

-(FTTableModel*) submitTableModel{
    
    NSLog(@"FTViewController initalisation ERROR!  You have to override   -(FTTableModel*) submitTableModel");
    return nil;
}

-(FTTableView*) submitTableView{
    
    NSLog(@"FTViewController initalisation ERROR!  You have to override   -(FTTableView*) submitTableView");
    return nil;
}



#pragma mark -
#pragma mark - Lifecycle

-(void)awakeFromNib{
    [super awakeFromNib];
    _tableModel = [self submitTableModel];
    
}

-(void)viewDidLoad{
    [super viewDidLoad];
    
    /* to be called once, after tableView is loaded */
    /* NOTE: in your project you must ensure that  -onTableViewIsLoaded is called once per this view controller lifecycle
     and if needed delegete -onTableViewIsLoaded call to the object which controlls this controller life cycle e.g parent view controller, etc */
    [self onTableViewIsLoaded];
}

-(void)onTableViewIsLoaded{
    
    _tableView = [self submitTableView];
    [self setupTableModel];
    [self setupTable];
}


#pragma mark -
#pragma mark - Table Model
-(void) setupTableModel{
    [_tableModel registerCellsForTable:_tableView];
}


-(FTTableCellMetadata *) tableCellMetadataForRowAtIndex:(NSIndexPath*) indexPath{
    return [_tableModel.tableCellsMetadata objectAtIndex:indexPath.row];
}

#pragma mark -
#pragma mark - Table View
-(void) setupTable{
    _tableView.tableAnimationDelegate = self;
}



#pragma mark -
#pragma mark - Calls from UITableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _tableModel.tableCellsMetadata.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FTTableCellMetadata *tableCellMetadata = [_tableModel.tableCellsMetadata objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableCellMetadata.cellReuseID];
    
    [self setCellHeightMetadata:tableCellMetadata withCell:cell tableModel:_tableModel];
    if (tableCellMetadata.isExpandable)
        [self setAnimationViewConfigurationIfNeededWithCellMetadata:tableCellMetadata withCell:(FTTableCell*)cell];
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FTTableCellMetadata *tableCellMetadata = [_tableModel.tableCellsMetadata objectAtIndex:indexPath.row];
    return tableCellMetadata.cellCurrentHeight;
}



#pragma mark - Cell Selection
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FTTableCellMetadata *tableCellMetadata = [_tableModel.tableCellsMetadata objectAtIndex:indexPath.row];
    
    /* process cell selection */
    if (tableCellMetadata.isExpandable){
        
        FTTableCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if (tableCellMetadata.isExpanded){
            [_tableView animateCell:cell withAnimationType:COLLAPSE_CELL_ANIMATION];
        }
        else{
            [_tableView animateCell:cell withAnimationType:EXPAND_CELL_ANIMATION];
        }
    }
}




#pragma mark -
#pragma mark - Calls from FTTableView
-(void) onSelectedCell: (FTTableCell*) selectedCell heightUpdate: (CGFloat) newCellHeight atIndexPath:(NSIndexPath*) indexPath{

    /* update cell metadata */
    FTTableCellMetadata *tableCellMetadata = [_tableModel.tableCellsMetadata objectAtIndex:indexPath.row];
    tableCellMetadata.cellCurrentHeight = newCellHeight;
}


-(void)onSelectedCellCollapsed:(FTTableCell *)cell atIndexPath:(NSIndexPath*) indexPath{
    
    /* update cell metadata */
    FTTableCellMetadata *tableCellMetadata = [_tableModel.tableCellsMetadata objectAtIndex:indexPath.row];
    tableCellMetadata.isExpanded = NO;
    
    [_tableModel removeCellToExpandedCellsPool:cell];
}


-(void)onSelectedCellExpanded:(FTTableCell *)cell atIndexPath:(NSIndexPath*) indexPath{
    
    /* update cell metadata */
    FTTableCellMetadata *tableCellMetadata = [_tableModel.tableCellsMetadata objectAtIndex:indexPath.row];
    tableCellMetadata.isExpanded = YES;
    
    [_tableModel addCellToExpandedCellsPool:cell withCollapsedHeight:tableCellMetadata.cellCollapsedHeight];
}



@end
