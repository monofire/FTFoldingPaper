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

#import "ExampleViewController+CellDisplayedData.h"

#import "ExpandingTableViewCell.h"
#import "ExerciseFoldComponentView.h"

@implementation ExampleViewController (CellDisplayedData)

-(void) updateDisplayedDataOfNonExpandingCell: (UITableViewCell *) nonExpandingCell
                            exerciseDataModel: (ExcerciseDataModel *) exerciseDataModel
                                    indexPath: (NSIndexPath*) indexPath{
    
}


-(void) updateDispayedDataOfExpandingCell: (FTTableCell *) expandingCell
                        exerciseDataModel: (ExcerciseDataModel *) exerciseDataModel
                                indexPath: (NSIndexPath*) indexPath{
    
    ExpandingTableViewCell *tableCell = (ExpandingTableViewCell*)expandingCell;
    WeekdayCellData *cellData = [exerciseDataModel.excerciseData objectAtIndex:indexPath.row];
    
    
    /* set weekDay name*/
    tableCell.weekDay.text = cellData.weekDayName;
    
    /* set fold elements */
    ExerciseFoldComponentData *exerciseFoldComponentData = nil;
    
    
    BOOL foldComponentsOfAnimationViewAreNotCreated = tableCell.animationView.foldComponents == nil;
    if (foldComponentsOfAnimationViewAreNotCreated)
        [tableCell.animationView layoutIfNeeded];
    
    
    for (NSInteger i = 0; i < tableCell.animationView.foldComponents.count; i++) {
        
        /* get fold component data */
        exerciseFoldComponentData = [cellData.cellFoldComponentsData objectAtIndex:i];
        
        /* get fold component */
        FTFoldComponent * foldComponent = [tableCell.animationView.foldComponents objectAtIndex:i];
        
        /* set fold component subViews*/
        ExerciseFoldComponentView *exerciseFoldComponentView = (ExerciseFoldComponentView*)foldComponent.topView;
        [self setView:exerciseFoldComponentView withModelData:exerciseFoldComponentData];
        
    }
}


-(void) setView: (ExerciseFoldComponentView *) view withModelData: (ExerciseFoldComponentData *) data{
    view.exerciseLoad.text = data.exerciseLoad;
    view.exerciseName.text = data.exerciseName;
    view.exerciseLoadColor.backgroundColor = data.exerciseLoadColor;
}


@end
