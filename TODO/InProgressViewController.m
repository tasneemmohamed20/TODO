//
//  InProgressViewController.m
//  TODO
//
//  Created by Macos on 23/04/2025.
//

#import "InProgressViewController.h"
#import "PresenttViewController.h"

@interface InProgressViewController () <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UISegmentedControl *prioritySegmentedControl;
@property (strong, nonatomic) UIImageView *emptyStateImageView;
@end

@implementation InProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.inProgressTable.delegate = self;
    self.inProgressTable.dataSource = self;
    self.inProgressTable.separatorInset = UIEdgeInsetsZero;
    self.inProgressTable.rowHeight = 60;
    
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
    [self loadInProgressTasks];
}

- (void)updateEmptyStateVisibility {
    self.emptyStateImageView.hidden = self.inProgressTasks.count > 0;
    self.inProgressTable.hidden = self.inProgressTasks.count == 0;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadInProgressTasks];

}

- (IBAction)deleteTaskAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
    
    // Check if index is valid
    if (indexPath.row >= self.inProgressTasks.count) {
        return;
    }
    
    
    [self.inProgressTasks removeObjectAtIndex:indexPath.row];
    
    
    NSMutableArray *allTasks = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"tasks"] mutableCopy];
    if (!allTasks) {
        allTasks = [NSMutableArray array];
    }
    
   
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status != %@", @(StatusInProgress)];
    NSArray *nonInProgressTasks = [allTasks filteredArrayUsingPredicate:predicate];
    NSMutableArray *updatedTasks = [nonInProgressTasks mutableCopy];
    [updatedTasks addObjectsFromArray:self.inProgressTasks];
    
   
    [[NSUserDefaults standardUserDefaults] setObject:updatedTasks forKey:@"tasks"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    [self.inProgressTable reloadData];
    [self updateEmptyStateVisibility];
}

- (void)loadInProgressTasks {
    NSArray *allTasks = [[NSUserDefaults standardUserDefaults] arrayForKey:@"tasks"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %@", @(StatusInProgress)];
    NSArray *filteredTasks = [allTasks filteredArrayUsingPredicate:predicate];
    self.inProgressTasks = [filteredTasks mutableCopy];
    
    [self.inProgressTable reloadData];
    [self updateEmptyStateVisibility];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.inProgressTasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"inProgressCell" forIndexPath:indexPath];
    
    cell.contentView.layer.borderWidth = 1.0;
    cell.contentView.layer.borderColor = [UIColor orangeColor].CGColor;
    cell.contentView.layer.cornerRadius = 10.0;
    
    NSDictionary *task = self.inProgressTasks[indexPath.row];
    Priority priority = [task[@"priority"] integerValue];
    
    UILabel *titleLabel = [cell viewWithTag:1];
    UILabel *aboutLabel = [cell viewWithTag:2];
    UIButton *deleteButton = [cell viewWithTag:3];
    UIImageView *priorityImage = [cell viewWithTag:4];
    
    titleLabel.text = task[@"title"];
    aboutLabel.text = task[@"about"];
    deleteButton.tag = indexPath.row;
    
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
    NSDictionary *selectedTask = self.inProgressTasks[indexPath.row];
    
    // Create and configure the detail view controller
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PresenttViewController *detailVC = [storyboard instantiateViewControllerWithIdentifier:@"TaskDetailViewController"];
    detailVC.updateDelegate = self;
    [detailVC setTaskDetails:selectedTask];
    
    // Present the detail view controller
    [self presentViewController:detailVC animated:YES completion:nil];
}


- (void) updateTasksTableView{
    [self loadInProgressTasks];
    [self.inProgressTable reloadData];
    [self updateEmptyStateVisibility];
}

- (IBAction)PriorityFilter:(id)sender {
    NSInteger selectedSegment = self.prioritySegmentedControl.selectedSegmentIndex;
    
    NSArray *allTasks = [[NSUserDefaults standardUserDefaults] arrayForKey:@"tasks"];
    NSPredicate *inProgressPredicate = [NSPredicate predicateWithFormat:@"status == %@", @(StatusInProgress)];
    NSArray *inProgressFilteredTasks = [allTasks filteredArrayUsingPredicate:inProgressPredicate];
    
    if (selectedSegment == 0) {
        self.inProgressTasks = [inProgressFilteredTasks mutableCopy];
    } else{
        Priority selectedPriority = (Priority)(selectedSegment -1);
        self.selectedPriority = selectedPriority;
        NSPredicate *priorityPredicate = [NSPredicate predicateWithFormat:@"status == %@ AND priority == %@", @(StatusInProgress), @(selectedPriority)];
        NSArray *filteredTasks = [inProgressFilteredTasks filteredArrayUsingPredicate:priorityPredicate];
        self.inProgressTasks = [filteredTasks mutableCopy];
    }
    [self.inProgressTable reloadData];
    [self updateEmptyStateVisibility];
}

@end
