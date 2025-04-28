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
    // Input validation
    if (!self.titleTF.text.length || !self.DescriptionTF.text.length) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                     message:@"Title and description cannot be empty"
                                                              preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *existingTasks = [defaults arrayForKey:@"tasks"];
    NSMutableArray *tasks = existingTasks ? [NSArray arrayWithArray:existingTasks].mutableCopy : [NSMutableArray array];
    
    // Compare dates using timeIntervalSince1970 for more reliable comparison
    NSInteger taskIndex = -1;
    for (NSInteger i = 0; i < tasks.count; i++) {
        NSDictionary *task = tasks[i];
        NSDate *savedDate = task[@"date"];
        if (fabs([savedDate timeIntervalSince1970] - [self.taskDate timeIntervalSince1970]) < 1.0) {
            taskIndex = i;
            break;
        }
    }
    
    if (taskIndex != -1) {
        // Create new task dictionary instead of modifying existing one
        NSDictionary *updatedTask = @{
            @"title": self.titleTF.text,
            @"about": self.DescriptionTF.text,
            @"date": self.taskDate,
            @"priority": @(self.prioritySegmentedControl.selectedSegmentIndex),
            @"status": @(self.statusSegmentedControl.selectedSegmentIndex)
        };
        
        tasks[taskIndex] = updatedTask;
        
        // Save and handle errors
        [defaults setObject:tasks forKey:@"tasks"];
        BOOL success = [defaults synchronize];
        
        if (!success) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                         message:@"Failed to save changes"
                                                                  preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
            return;
        }
    }
    [_updateDelegate updateTasksTableView];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
