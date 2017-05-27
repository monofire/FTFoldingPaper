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

#import "ExcerciseDataModel.h"



#define kDataSourceSize 15
#define kNumberOfFoldComponentLayers 2

@implementation ExcerciseDataModel{
    
    NSArray *_exerciseLoadValues;
    NSArray *_exerciseNameValues;
    NSArray *_exerciseLoadColorValues;
    NSArray *_randomWeekDays;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.excerciseData = [[NSMutableArray alloc]init];
        [self populateValuesPools];
        [self populateDataModelWithRandomValues];
    }
    return self;
}





-(void) populateValuesPools{
    
    _exerciseLoadValues = @[@"5 x 12",@"3 x 8",@"3 x 5",@"1 x 7",@"6 x 10",@" 2 x 7", @"5 x 5"];
    
    
    _exerciseNameValues = @[@"45 Degree Side Crunch",
                            @"Ab Crunch Machine",
                            @"Elevated Legs",
                            @"Crunch, Side",
                            @"Dumbbell Flyes",
                            @"Inclined Bench",
                            @"Bicep Barbell",
                            @"Curl Bar",
                            @"Concentration",
                            @"Forearm Curl",
                            @"Hammer Curl"];
    
    
    _exerciseLoadColorValues = @[[UIColor colorWithRed:255.0f/255.0f green:220.0f/255.0f blue:7.0f/255.0f alpha:1.0f],
                                 [UIColor colorWithRed:254.0f/255.0f green:126.0f/255.0f blue:174.0f/255.0f alpha:1.0f],
                                 [UIColor colorWithRed:218.0f/255.0f green:133.0f/255.0f blue:216.0f/255.0f alpha:1.0f],
                                 [UIColor colorWithRed:175.0f/255.0f green:255.0f/255.0f blue:0.0f/255.0f alpha:1.0f]];
    
    
    _randomWeekDays = [self randomWeekDays];
}





-(void)populateDataModelWithRandomValues{
    
    for (NSInteger i = 0; i < kDataSourceSize; i++)
        [self.excerciseData addObject:[self randomWeekdayCellDataWithRandomDayIndex:i]];
    
}







#pragma mark -
#pragma mark - Randomisation tools

-(WeekdayCellData *) randomWeekdayCellDataWithRandomDayIndex:(NSInteger) randomDayIndex{
    
    WeekdayCellData *weekdayCellData = [[WeekdayCellData alloc]init];
    weekdayCellData.weekDayName = [_randomWeekDays objectAtIndex:randomDayIndex];
    weekdayCellData.cellFoldComponentsData = [self randomCellFoldComponents];
    
    return weekdayCellData;
}


-(NSArray*) randomCellFoldComponents{

    NSMutableArray *randomCellFoldComponents = [[NSMutableArray alloc]init];
    
    for (NSInteger i = 0; i < kNumberOfFoldComponentLayers; i++)
        [randomCellFoldComponents addObject:[self randomFoldComponentData]];
    
    return randomCellFoldComponents;
}


-(ExerciseFoldComponentData*) randomFoldComponentData{
    
    NSString *randomExerciseLoad = [self randomObjectFromArray:_exerciseLoadValues];
    UIColor *randomExcerciseLoadColor = [self randomObjectFromArray:_exerciseLoadColorValues];
    NSString *randomExerciseName = [self randomObjectFromArray:_exerciseNameValues];
    
    return [[ExerciseFoldComponentData alloc]initWithExerciseLoad:randomExerciseLoad
                                                exerciseLoadColor:randomExcerciseLoadColor
                                                     exerciseName:randomExerciseName];
}

-(id) randomObjectFromArray: (NSArray*) array{
    return [array objectAtIndex:arc4random() % array.count];
}


-(NSArray*) randomWeekDays{
    
    NSArray *weekDays = @[@"MONDAY",@"TUESDAY",@"WEDNESDAY",@"THURSDAY",@"FRIDAY",@"SATURDAY",@"SUNDAY"];
    NSMutableArray *randomWeekDays = [[NSMutableArray alloc]initWithCapacity:kDataSourceSize];
    NSInteger randomFirstWeekDay = arc4random() % 6;
    
    
    for (NSInteger i = 0; i < kDataSourceSize; i++){
        
        switch (i) {
                
            case 0:
                [randomWeekDays addObject:@"TODAY"];
                break;
                
            case 1:
                [randomWeekDays addObject:@"TOMORROW"];
                break;
                
            default:
                
                if (randomFirstWeekDay == weekDays.count) randomFirstWeekDay = 0;
                [randomWeekDays addObject:[weekDays objectAtIndex:randomFirstWeekDay]];
                randomFirstWeekDay++;
                break;
        }
    }
    
    return randomWeekDays;
}




@end
