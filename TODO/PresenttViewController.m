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
@end

@implementation PresenttViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Configure text field and text view
    self.titleTF.enabled = NO;
    self.DescriptionTF.editable = NO;
    
    // Display task details
    [self displayTaskDetails];
}

- (void)displayTaskDetails {
    // Display title
    self.titleTF.text = self.taskTitle;
    
    // Display description
    self.DescriptionTF.text = self.taskDescription;
    
    // Format and display date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    self.DataLable.text = [dateFormatter stringFromDate:self.taskDate];
}

- (void)setTaskDetails:(NSDictionary *)taskDict {
    self.taskTitle = taskDict[@"title"];
    self.taskDescription = taskDict[@"about"];
    self.taskDate = taskDict[@"date"];
    [self displayTaskDetails];
}


@end
