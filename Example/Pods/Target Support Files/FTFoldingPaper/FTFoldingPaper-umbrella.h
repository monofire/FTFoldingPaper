#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AnimationContextStructs.h"
#import "FTAnimationContext+FoldComponentsAnimation.h"
#import "FTAnimationContext+GradientColorAnimation.h"
#import "FTAnimationContext.h"
#import "FTAnimationView+Tools.h"
#import "FTAnimationView.h"
#import "FTFoldComponent.h"
#import "FTFoldComponentAnimations.h"
#import "FTFoldComponentGradientAnimations.h"
#import "FTFoldingPaper.h"
#import "FTParentLayerAnimations.h"
#import "FTTableCell.h"
#import "FTTableCellMetadata.h"
#import "FTTableCellSeparator.h"
#import "FTTableModel.h"
#import "FTTableView.h"
#import "FTViewController+CellsConfiguration.h"
#import "FTViewController.h"

FOUNDATION_EXPORT double FTFoldingPaperVersionNumber;
FOUNDATION_EXPORT const unsigned char FTFoldingPaperVersionString[];

