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

#import "ExampleViewController.h"



#import "ExampleTableModel.h"
#import "ExampleViewController+CellDisplayedData.h"


@interface ExampleViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet FTTableView *tableView;

@end

@implementation ExampleViewController{
    ExcerciseDataModel *_exerciseDataModel;
}

#pragma mark -
#pragma mark - Init
-(FTTableModel *)submitTableModel{
    return [[ExampleTableModel alloc]init];
}


-(FTTableView *)submitTableView{
    return self.tableView;
}



#pragma mark -
#pragma mark - Lifecycle


-(void)viewDidLoad{
    [super viewDidLoad];
    
    /* to be called once, after tableView is loaded */
    /* NOTE: in your project you must ensure that -setupExerciseDataModel and -subscribeToTableCalls are called once per this view controller lifecycle
     and if needed delegete -setupExerciseDataModel and -subscribeToTableCalls  calls to the object which controlls this controller life cycle e.g parent view controller, etc */
    [self setupExerciseDataModel];
    [self subscribeToTableCalls];
}


-(void) subscribeToTableCalls{
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
}


#pragma mark -
#pragma mark - Calls from UITableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [super tableView:tableView numberOfRowsInSection:section];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [self updateDisplayedDataForCell:cell atIndexPath:indexPath];
}




#pragma mark -
#pragma mark - Exercise Data Model
-(void) setupExerciseDataModel{
    _exerciseDataModel = [[ExcerciseDataModel alloc]init];
}


-(void) updateDisplayedDataForCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath{
    
    FTTableCellMetadata *tableCellMetadata = [super tableCellMetadataForRowAtIndex:indexPath];
    
    if (tableCellMetadata.isExpandable)
        [self updateDispayedDataOfExpandingCell:(FTTableCell*)cell exerciseDataModel:_exerciseDataModel indexPath:indexPath];
    
    else
        [self updateDisplayedDataOfNonExpandingCell:cell exerciseDataModel:_exerciseDataModel indexPath:indexPath];
    
}





@end
