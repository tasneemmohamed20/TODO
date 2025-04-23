//
//  PresenttViewController.m
//  TODO
//
//  Created by Macos on 23/04/2025.
//

#import "PresenttViewController.h"

@interface PresenttViewController ()
@property (nonatomic, strong) NSString *taskTitle;
@property (nonatomic, strong) NSString *taskDescription;
@property (nonatomic, strong) NSDate *taskDate;
@property (nonatomic) NSInteger priority;
@property (nonatomic) NSInteger status;
@end

@implementation PresenttViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Display task details
    [self displayTaskDetails];
}

- (void)setTaskDetails:(NSDictionary *)taskDict {
    self.taskTitle = taskDict[@"title"];
    self.taskDescription = taskDict[@"about"];
    self.taskDate = taskDict[@"date"];
    self.priority = [taskDict[@"priority"] integerValue];
    self.status = [taskDict[@"status"] integerValue];
    
    [self displayTaskDetails];
}

- (void)displayTaskDetails {
    // Display title and description
    self.titleTF.text = self.taskTitle;
    self.DescriptionTF.text = self.taskDescription;
    
    // Format and display date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    self.DataLable.text = [dateFormatter stringFromDate:self.taskDate];
    
    // Set segmented controls
    [self.prioritySegmentedControl setSelectedSegmentIndex:self.priority];
    [self.statusSegmentedControl setSelectedSegmentIndex:self.status];
    
    NSLog(@"Task Date: %@", self.taskDate);
}

- (IBAction)priorityBtns:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    self.priority = segmentedControl.selectedSegmentIndex;
}

- (IBAction)StatusBtns:(id)sender {
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    self.status = segmentedControl.selectedSegmentIndex;
}
- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveAction:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *tasks = [[defaults arrayForKey:@"tasks"] mutableCopy];
    
    NSInteger taskIndex = -1;
    for (NSInteger i = 0; i < tasks.count; i++) {
        NSDictionary *task = tasks[i];
        NSDate *savedDate = task[@"date"];
        if ([savedDate isEqual:self.taskDate]) {
            taskIndex = i;
            break;
        }
    }
    
    if (taskIndex != -1) {
        NSMutableDictionary *existingTask = [tasks[taskIndex] mutableCopy];
        BOOL hasChanges = NO;
        
        // Check title changes
        NSString *newTitle = self.titleTF.text;
        if (![newTitle isEqualToString:existingTask[@"title"]]) {
            existingTask[@"title"] = newTitle;
            hasChanges = YES;
        }
        
        // Check description changes
        NSString *newDescription = self.DescriptionTF.text;
        if (![newDescription isEqualToString:existingTask[@"about"]]) {
            existingTask[@"about"] = newDescription;
            hasChanges = YES;
        }
        
        // Check priority changes
        NSInteger currentPriority = [existingTask[@"priority"] integerValue];
        NSInteger newPriority = self.prioritySegmentedControl.selectedSegmentIndex;
        if (currentPriority != newPriority) {
            existingTask[@"priority"] = @(newPriority);
            hasChanges = YES;
        }
        
        // Check status changes
        NSInteger currentStatus = [existingTask[@"status"] integerValue];
        NSInteger newStatus = self.statusSegmentedControl.selectedSegmentIndex;
        if (currentStatus != newStatus) {
            existingTask[@"status"] = @(newStatus);
            hasChanges = YES;
        }
        
        if (hasChanges) {
            tasks[taskIndex] = existingTask;
            [defaults setObject:tasks forKey:@"tasks"];
            [defaults synchronize];
        }
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
