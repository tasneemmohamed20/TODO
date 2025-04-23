//
//  DoneViewController.h
//  TODO
//
//  Created by Macos on 23/04/2025.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DoneViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITableView *doneTable;
@property (strong, nonatomic) NSMutableArray *doneTasks;

typedef NS_ENUM(NSInteger, Status) {
    StatusTODO = 0,
    StatusInProgress = 1,
    StatusDone = 2,
};

typedef NS_ENUM(NSInteger, Priority) {
    PriorityLow = 0,
    PriorityMid = 1,
    PriorityHigh = 2,
};

@end

NS_ASSUME_NONNULL_END
