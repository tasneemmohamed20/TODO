//
//  ViewController.h
//  TODO
//
//  Created by Macos on 23/04/2025.
//

#import <UIKit/UIKit.h>
#import "UpdateProtocol.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UpdateProtocol>

typedef NS_ENUM(NSInteger, Priority) {
    PriorityLow = 0,
    PriorityMid = 1,
    PriorityHigh = 2,
};

typedef NS_ENUM(NSInteger, Status) {
    StatusTODO = 0,
    StatusInProgress = 1,
    StatusDone = 2,
};

@property (weak, nonatomic) IBOutlet UITableView *tasksTable;
@property (weak, nonatomic) IBOutlet UITextField *tilteTF;
@property (weak, nonatomic) IBOutlet UITextField *aboutTf;
@property (nonatomic) Priority selectedPriority;
@property (weak, nonatomic) enum status;

@end

