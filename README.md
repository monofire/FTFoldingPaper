[![Build Status](https://travis-ci.org/monofire/FTFoldingPaper.svg?branch=master)](https://travis-ci.org/monofire/FTFoldingPaper)
[![Version](https://img.shields.io/cocoapods/v/FTFoldingPaper.svg?style=flat)](http://cocoapods.org/pods/FTFoldingPaper)
[![License](https://img.shields.io/cocoapods/l/FTFoldingPaper.svg?style=flat)](http://cocoapods.org/pods/FTFoldingPaper)
[![Platform](https://img.shields.io/cocoapods/p/FTFoldingPaper.svg?style=flat)](http://cocoapods.org/pods/FTFoldingPaper)


FTFoldingPaper is a UI framework built on top of the [Core Animation](https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/CoreAnimation_guide/Introduction/Introduction.html#//apple_ref/doc/uid/TP40004514). It is designed to emulate paper folding effects and can be integrated with [UITableView](https://developer.apple.com/library/content/documentation/UserExperience/Conceptual/TableView_iPhone/AboutTableViewsiPhone/AboutTableViewsiPhone.html), used independently or paired with other UI components.

![ftfoldingpaperexample](https://cloud.githubusercontent.com/assets/25864772/26519063/5f09228a-42c4-11e7-9a05-b6385976a16f.gif)

## How To Get Started
- Install FTFoldingPaper to your project using CocoaPods.
- Follow instructions below.

## Installation with CocoaPods
[CocoaPods](https://cocoapods.org) is a dependency manager, which automates and simplifies the process of using 3rd-party libraries like FTFoldingPaper in your projects. 


You can install CocoaPods with the following command:
```bash
$ sudo gem install cocoapods
```

Then execute:
```bash
$ cd <path to your project folder>
$ pod init
```

Open pod file for edit with Xcode or another editor:
```
$ open -a Xcode podfile
```

Add the following text under "target 'your project name' do" line:
```ruby
pod 'FTFoldingPaper'
```

Finally, execute:
```bash
$ pod install
```

You're done! Now open your project by clicking on the newly created xcworkspace file.




## Architecture:
![ftfoldingpaperstructure](https://cloud.githubusercontent.com/assets/25864772/26519231/72b6b980-42c6-11e7-84a2-1e4cc7b20b8c.jpg)

**Paper folding animation:**  
FTFoldComponent  
FTAnimationView  
FTAnimationContext  
FTParentLayerAnimations  
FTFoldComponentAnimations  
FTFoldComponentGradientAnimations  

**Integration with UITableView:**  
FTViewController  
FTTableModel  
FTTableCellMetadata  
FTTableView  
FTTableCell  
FTTableCellSeparator  


## Usage:


1. Create xibs of the top and bottom layers for all your fold components.  
Note that each fold component requires top and bottom layers.

1.1 Press '⌘ + N'. Select "User Interface" -> "View"  
1.2 Open and edit each xib according to your needs: (add UI components, setup Autolayout).  
1.3 Create data model object to manage UI components of your layer, if any required.  



2. Subclass and configure `FTAnimationView` with `FTFoldComponents` and `FTAnimationContext`.

`FTAnimationView` hosts fold components and manages animation. Animation process is configured with `FTAnimationContext`

Override the next two methods in `FTAnimationView`:
```objective-c
/* example of animation view with 2 fold components*/
-(NSArray *)submitFoldComponents{

FTFoldComponent *foldComponentA = [[FTFoldComponent alloc]initWithSuperView:self
topViewNibName:@<your top layer xib name>
bottomViewNibName:@<your bottom layer xib name>];

FTFoldComponent *foldComponentB = [[FTFoldComponent alloc]initWithSuperView:self
topViewNibName:@<your top layer xib name>
bottomViewNibName:@<your bottom layer xib name>];

return @[foldComponentA,foldComponentB];
}

/* please refer to FTAnimationContext interface to get the 
full list of possible configuration parameters */

-(void)configureAnimationContext:(FTAnimationContext *)animationContext{

animationContext.expandAnimationDuration = 0.6f;
animationContext.collapseAnimationDuration = 0.6f;
animationContext.foldAngleFinalValue = - M_PI/6;
animationContext.animationMediaTimingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
}
```

At this point you have `FTAnimationView` that is ready to be used in your UI. 
Continue with steps 3 - 7 if you need to integrate it into the `UITableView` component.

## Usage with UITableView:

3. Subclass `FTTableCell` and create cell prototype. 
You can create as many different cells as you need in order to fulfill your UI tasks.

3.1 Press '⌘ + N'. Create new subclass of `UITableViewCell`. Tick "Also create XIB file".  
3.2 Open .h file of your class. Change parent class to `FTTableCell` like this:  
```objective-c
@interface <your class name> : FTTableCell
```
3.3 Open and edit cell xib according to your needs: (add UI components, setup Autolayout).  
3.4 Create data model object to manage UI components of your cell if any required.  
3.5 Set cell identifier.  


4. Configure each subclassed `FTTableCell` with `FTAnimationView` and `FTTableCellSeparator` overriding following methods in `FTTableCell`:

```objective-c
-(FTAnimationView *)submitAnimationView{
return [[<name of your FTAnimationView subclass> alloc]init];
}


/* do not override if you need cell without separator */
-(FTTableCellSeparator *)submitCellSeparator{
return [[FTTableCellSeparator alloc]initWithHeight:1.0f
offsetFromCellLeftEdge:0.0f
offsetFromCellRightEdge:0.0f
color:[UIColor colorWithRed:92.0f/255.0f green:94.0f/255.0f blue:102.0f/255.0f alpha:0.1f]];
}
```


5. Subclass and configure `FTTableModel`.
`FTTableModel` is responsible for the architecture of your table view: which cells are used and in which order.  It can manage `FTTableCell` and `UITableViewCell` cells in any combinations.

Override the following methods in `FTTableModel`:

```objective-c
-(NSDictionary *)submitCellsIDs{

return  @{@"<id of your cell>":@"<xib name of your cell>"};

}

/* Submit your table architecture. In this example, the table consists only of cells of one type. You can implement any custom architecture combining different cell types for different rows */

-(NSArray *)submitTableCellsMetadata{

NSMutableArray *cellsMetadata = [[NSMutableArray alloc]init];

for (NSInteger i = 0; i < kNumberOfCellsInTable; i++) {

FTTableCellMetadata *tableCellMetadata = nil;

tableCellMetadata = [[FTTableCellMetadata alloc]initWithReuseID:@"<xib name of your cell>" isExpandable:YES isExpanded:NO];

[cellsMetadata addObject:tableCellMetadata];
}

return cellsMetadata;
}
```

6. Add TableView UI component to your controller in the storyboard.  

6.1 Configure your TableView UI component.  
6.2 Set `FTTableView` as the custom class for your table (in storyboard settings).  


7. Subclass and configure `FTTableViewController`.  
`FTTableViewController` bridges `FTTableView` with `FTTableModel` and provides other logic to manage cells operations. 

7.1 In your subclassed `FTTableViewController`, link your `FTTableView` and subscribe for `UITableViewDelegate` and `UITableViewDataSource` protocols. Example:

```objective-c
self.tableView.dataSource = self;
self.tableView.delegate = self;
```

7.2 Override the following methods in your subclassed `FTTableViewController`:

```objective-c
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
```

7.3 Implement your data model to manage the content of your cells.  
7.4 Implement mechanism to update the content of your cells using your data model.  
You can override `-(void)tableView: willDisplayCell: forRowAtIndexPath:` for that purpose.


## Author
monofire, monofirehub@gmail.com

## License
This project is licensed under the MIT License - see the LICENSE.md file for details
