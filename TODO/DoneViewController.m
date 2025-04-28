//
//  DoneViewController.m
//  TODO
//
//  Created by Macos on 23/04/2025.
//

#import "DoneViewController.h"
#import "PresenttViewController.h"


@interface DoneViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UISegmentedControl *prioritySegmentedControl;

@property (strong, nonatomic) UIImageView *emptyStateImageView;

@end

@implementation DoneViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.doneTable.delegate = self;
    self.doneTable.dataSource = self;
    self.doneTable.separatorInset = UIEdgeInsetsZero;
    self.doneTable.rowHeight = 60;
    self.emptyStateImageView = [[UIImageView alloc] init];
    self.emptyStateImageView.image = [UIImage imageNamed:@"zerotask"];     self.emptyStateImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.emptyStateImageView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.emptyStateImageView];
    
    // Center the image view
    [NSLayoutConstraint activateConstraints:@[
        [self.emptyStateImageView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.emptyStateImageView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor],
        [self.emptyStateImageView.widthAnchor constraintEqualToConstant:200], // Adjust size as needed
        [self.emptyStateImageView.heightAnchor constraintEqualToConstant:200]
    ]];
    
    [self updateEmptyStateVisibility];
    [self loadInDoneTasks];
}

- (void)updateEmptyStateVisibility {
    self.emptyStateImageView.hidden = self.doneTasks.count > 0;
    self.doneTable.hidden = self.doneTasks.count == 0;
}


- (IBAction)deleteTaskAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
    
    // Remove from doneTasks array
    [self.doneTasks removeObjectAtIndex:indexPath.row];
    
    // Get all tasks from UserDefaults
    NSMutableArray *allTasks = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"tasks"] mutableCopy];
    
    // Update the tasks in UserDefaults by removing done tasks
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status != %@", @(StatusDone)];
    NSArray *nonDoneTasks = [allTasks filteredArrayUsingPredicate:predicate];
    NSMutableArray *updatedTasks = [nonDoneTasks mutableCopy];
    [updatedTasks addObjectsFromArray:self.doneTasks];
    
    // Save back to UserDefaults
    [[NSUserDefaults standardUserDefaults] setObject:updatedTasks forKey:@"tasks"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Reload table view
    [self.doneTable reloadData];
    [self updateEmptyStateVisibility];

}

- (void)loadInDoneTasks {
    // Initialize doneTasks array if not already done
    if (!self.doneTasks) {
        self.doneTasks = [NSMutableArray array];
    }

    
    NSArray *allTasks = [[NSUserDefaults standardUserDefaults] arrayForKey:@"tasks"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %@", @(StatusDone)];
    NSArray *filteredTasks = [allTasks filteredArrayUsingPredicate:predicate];
    self.doneTasks = [filteredTasks mutableCopy];
    
    // Reload table view to display the data
    [self.doneTable reloadData];
    [self updateEmptyStateVisibility];

}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.doneTasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"doneCell" forIndexPath:indexPath];
    
    cell.contentView.layer.borderWidth = 1.0;
    cell.contentView.layer.borderColor = [UIColor orangeColor].CGColor;
    cell.contentView.layer.cornerRadius = 10.0;
    
    NSDictionary *task = self.doneTasks[indexPath.row];
    Priority priority = [task[@"priority"] integerValue];
    
    UILabel *titleLabel = [cell viewWithTag:1];
    UILabel *aboutLabel = [cell viewWithTag:2];
    UIButton *deleteButton = [cell viewWithTag:3];
    UIImageView *priorityImage = [cell viewWithTag:4];
    
    deleteButton.tag = indexPath.row;
    
    titleLabel.text = task[@"title"];
    aboutLabel.text = task[@"about"];
    
    switch (priority) {
        case PriorityLow:
            [priorityImage setImage:[UIImage imageNamed:@"yellow"]];
            break;
        case PriorityMid:
            [priorityImage setImage:[UIImage imageNamed:@"green"]];
            break;
        case PriorityHigh:
            [priorityImage setImage:[UIImage imageNamed:@"red"]];
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 85;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Get the selected task
    NSDictionary *selectedTask = self.doneTasks[indexPath.row];
    
    // Create and configure the detail view controller
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PresenttViewController *detailVC = [storyboard instantiateViewControllerWithIdentifier:@"TaskDetailViewController"];
    detailVC.updateDelegate = self;
    [detailVC setTaskDetails:selectedTask];
    
    // Present the detail view controller
    [self presentViewController:detailVC animated:YES completion:nil];
}

- (void) updateTasksTableView{
    [self loadInDoneTasks];
    [self.doneTable reloadData];
    [self updateEmptyStateVisibility];

}

- (IBAction)PriorityFilter:(id)sender {
    NSInteger selectedSegment = self.prioritySegmentedControl.selectedSegmentIndex;
    NSArray *allTasks = [[NSUserDefaults standardUserDefaults] arrayForKey:@"tasks"];
    NSPredicate *inProgressPredicate = [NSPredicate predicateWithFormat:@"status == %@", @(StatusDone)];
    NSArray *doneFilteredTasks = [allTasks filteredArrayUsingPredicate:inProgressPredicate];
    
    if (selectedSegment == 0) {
        self.doneTasks = [doneFilteredTasks mutableCopy];
    }else{
        Priority selectedPriority = (Priority)(selectedSegment-1);
        self.selectedPriority = selectedPriority;
        NSPredicate *priorityPredicate = [NSPredicate predicateWithFormat:@"status == %@ AND priority == %@", @(StatusDone), @(selectedPriority)];
        NSArray *filtereTasks = [doneFilteredTasks filteredArrayUsingPredicate:priorityPredicate];
        self.doneTasks = [filtereTasks mutableCopy];

    }
    [self.doneTable reloadData];
    [self updateEmptyStateVisibility];

}

@end
