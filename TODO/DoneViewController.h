//
//  DoneViewController.h
//  TODO
//
//  Created by Macos on 23/04/2025.
//

#import <UIKit/UIKit.h>
#import "UpdateProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface DoneViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UpdateProtocol>

@property (weak, nonatomic) IBOutlet UITableView *doneTable;
@property (strong, nonatomic) NSMutableArray *doneTasks;
@property id < UpdateProtocol> updateDelegate;

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

@property (nonatomic) Priority selectedPriority;

@end

NS_ASSUME_NONNULL_END
