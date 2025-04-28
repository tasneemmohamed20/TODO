//
//  ViewController.m
//  TODO
//
//  Created by Macos on 23/04/2025.
//

#import "ViewController.h"
#import "PresenttViewController.h"



@interface ViewController ()
@property (strong, nonatomic) NSMutableArray *tasks;
@property (strong, nonatomic) NSMutableArray *filteredTasks;

@property (weak, nonatomic) IBOutlet UISegmentedControl *prioritySegmentedControl;
@property (strong, nonatomic) UIImageView *emptyStateImageView;
@end

@implementation ViewController

PresenttViewController *detailVC;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tasksTable.delegate = self;
    self.tasksTable.dataSource = self;
//    self.tasksTable.separatorInset = UIEdgeInsetsZero;
    self.tasksTable.rowHeight = 60;
//    self.tasksTable.estimatedSectionHeaderHeight = 0;
//    self.tasksTable.estimatedSectionFooterHeight = 0;
    [self styleTextField:_tilteTF];
    [self styleTextField:_aboutTf];
    [self loadTODOTasks];
    
    self.emptyStateImageView = [[UIImageView alloc] init];
       self.emptyStateImageView.image = [UIImage imageNamed:@"zerotask"];       self.emptyStateImageView.contentMode = UIViewContentModeScaleAspectFit;
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
}

- (void)updateEmptyStateVisibility {
    self.emptyStateImageView.hidden = self.tasks.count > 0;
    self.tasksTable.hidden = self.tasks.count == 0;
}

- (void)styleTextField:(UITextField *)textField {
    textField.layer.borderWidth = 1.0;
    textField.layer.borderColor = [UIColor orangeColor].CGColor;
    textField.layer.cornerRadius = 8.0;
    textField.clipsToBounds = YES;
    
//    UIView *leftPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, textField.frame.size.height)];
//    textField.leftView = leftPaddingView;
    textField.leftViewMode = UITextFieldViewModeAlways;
}

- (void)loadTODOTasks {
    // Get all tasks from UserDefaults
    NSArray *allTasks = [[NSUserDefaults standardUserDefaults] arrayForKey:@"tasks"];
    if (!allTasks) {
        self.tasks = [NSMutableArray array];
        [self updateEmptyStateVisibility];
        return;
    }
    
    // Filter for StatusTODO tasks
    NSPredicate *todoPredicate = [NSPredicate predicateWithFormat:@"status == %@", @(StatusTODO)];
    NSArray *todoTasks = [allTasks filteredArrayUsingPredicate:todoPredicate];
    self.tasks = [todoTasks mutableCopy];
    
    [self.tasksTable reloadData];
    [self updateEmptyStateVisibility];

}


- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self loadTODOTasks];
}


- (IBAction)priorityButtons:(id)sender {
    NSInteger selectedIndex = [sender selectedSegmentIndex];
    
    if (self.tilteTF.text.length == 0 && self.aboutTf.text.length == 0) {
        // Get all TODO tasks
        NSArray *allTasks = [[NSUserDefaults standardUserDefaults] arrayForKey:@"tasks"];
        NSPredicate *todoPredicate = [NSPredicate predicateWithFormat:@"status == %@", @(StatusTODO)];
        NSArray *todoTasks = [allTasks filteredArrayUsingPredicate:todoPredicate];
        
        if (selectedIndex == 0) {
            // Show all TODO tasks
            self.tasks = [todoTasks mutableCopy];
        } else {
            // Filter TODO tasks by priority
            Priority selectedPriority = (Priority)(selectedIndex - 1);
            self.selectedPriority = selectedPriority;
            
            NSPredicate *priorityPredicate = [NSPredicate predicateWithFormat:@"priority == %@", @(selectedPriority)];
            NSArray *filteredTasks = [todoTasks filteredArrayUsingPredicate:priorityPredicate];
            self.tasks = [filteredTasks mutableCopy];
        }
        
        [self.tasksTable reloadData];
        [self updateEmptyStateVisibility];

    }
}
- (IBAction)addTaskAction:(id)sender {
    NSString *title = _tilteTF.text;
    NSString *about = _aboutTf.text;
    NSDate *date = [NSDate date];
    if (self.prioritySegmentedControl.selectedSegmentIndex == 0) {
        self.selectedPriority = self.prioritySegmentedControl.selectedSegmentIndex;}
    else {
        self.selectedPriority = self.prioritySegmentedControl.selectedSegmentIndex - 1;}
    

    if (title.length > 0 && about.length > 0) {
        NSDictionary *task = @{
            @"title": title,
            @"about": about,
            @"priority": @(self.selectedPriority),
            @"date": date,
            @"status": @(StatusTODO)
        };
        NSLog(@"Task added: %ld", self.selectedPriority);
        [self.tasks addObject:task];
        [self saveTasks];
        [self.tasksTable reloadData];
        [self updateEmptyStateVisibility];

        
        _tilteTF.text = @"";
        _aboutTf.text = @"";
//        self.selectedPriority = PriorityLow;
        self.prioritySegmentedControl.selectedSegmentIndex = 0;
        
        NSLog(@"Task added: %@", task);
    }
    
}


- (void)saveTasks {
    NSArray *allTasks = [[NSUserDefaults standardUserDefaults] arrayForKey:@"tasks"];
    NSMutableArray *updatedTasks;
    
    if (allTasks) {
        updatedTasks = [allTasks mutableCopy];
        // Remove all TODO tasks
        NSPredicate *nonTodoPredicate = [NSPredicate predicateWithFormat:@"status != %@", @(StatusTODO)];
        [updatedTasks filterUsingPredicate:nonTodoPredicate];
    } else {
        updatedTasks = [NSMutableArray array];
    }
    
    // Add current TODO tasks
    [updatedTasks addObjectsFromArray:self.tasks];
    
    [[NSUserDefaults standardUserDefaults] setObject:updatedTasks forKey:@"tasks"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(IBAction)searchButton:(id)sender {
    NSString *titleSearch = self.tilteTF.text;
    NSString *aboutSearch = self.aboutTf.text;
    
    // Get all tasks from UserDefaults
    NSArray *allTasks = [[NSUserDefaults standardUserDefaults] arrayForKey:@"tasks"];
    
    // Create predicate based on which fields have content
    NSPredicate *predicate;
    if (titleSearch.length > 0 && aboutSearch.length > 0) {
        // Search both title and about
        predicate = [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@ OR about CONTAINS[cd] %@", titleSearch, aboutSearch];
    } else if (titleSearch.length > 0 && aboutSearch.length == 0) {
        // Search only title
        predicate = [NSPredicate predicateWithFormat:@"title CONTAINS[cd] %@", titleSearch];
    } else if (aboutSearch.length > 0 && titleSearch.length == 0) {
        // Search only about
        predicate = [NSPredicate predicateWithFormat:@"about CONTAINS[cd] %@", aboutSearch];
    }
    
    // Apply filter if predicate exists
    if (predicate) {
        NSArray *filteredTasks = [allTasks filteredArrayUsingPredicate:predicate];
        self.tasks = [filteredTasks mutableCopy];
        [self.tasksTable reloadData];
    } else {
        // If no search terms, restore all tasks
//        self.tasks = [allTasks mutableCopy];
        [self updateEmptyStateVisibility];

        [self.tasksTable reloadData];
    }
}

- (IBAction)deleteTaskAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
    
    // Get all tasks
    NSMutableArray *allTasks = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"tasks"] mutableCopy];
    if (!allTasks) {
        allTasks = [NSMutableArray array];
    }
    
    // Get task to delete from current tasks array
    NSDictionary *taskToDelete = self.tasks[indexPath.row];
    
    // Remove task from all tasks
    [allTasks removeObject:taskToDelete];
    
    // Save updated tasks
    [[NSUserDefaults standardUserDefaults] setObject:allTasks forKey:@"tasks"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Update current view based on selected filter
    if (self.prioritySegmentedControl.selectedSegmentIndex == 0) {
        // Show all TODO tasks
        NSPredicate *todoPredicate = [NSPredicate predicateWithFormat:@"status == %@", @(StatusTODO)];
        self.tasks = [[allTasks filteredArrayUsingPredicate:todoPredicate] mutableCopy];
    } else {
        // Filter by priority
        Priority selectedPriority = (Priority)(self.prioritySegmentedControl.selectedSegmentIndex - 1);
        NSPredicate *combinedPredicate = [NSPredicate predicateWithFormat:@"status == %@ AND priority == %@",
                                         @(StatusTODO), @(selectedPriority)];
        self.tasks = [[allTasks filteredArrayUsingPredicate:combinedPredicate] mutableCopy];
    }
    
    [self.tasksTable reloadData];
    [self updateEmptyStateVisibility];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.tasks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"taskCell" forIndexPath:indexPath];
    
    cell.contentView.layer.borderWidth = 1.0;
       cell.contentView.layer.borderColor = [UIColor orangeColor].CGColor;
       cell.contentView.layer.cornerRadius = 10.0;
       cell.contentView.layer.masksToBounds = YES;
       
       // Add margins to create spacing
       cell.contentView.frame = UIEdgeInsetsInsetRect(cell.contentView.frame, UIEdgeInsetsMake(5, 10, 5, 10));
    
    NSDictionary *task = self.tasks[indexPath.row];
    Priority priority = [task[@"priority"] integerValue];
    
    id titleView = [cell viewWithTag:1];
    id aboutView = [cell viewWithTag:2];
    UIButton *deleteButton = [cell viewWithTag:3];
    UIImageView *priorityImage = [cell viewWithTag:4];

    if ([titleView isKindOfClass:[UILabel class]]) {
        ((UILabel *)titleView).text = task[@"title"];
    }

    if ([aboutView isKindOfClass:[UILabel class]]) {
        ((UILabel *)aboutView).text = task[@"about"];
    }

    deleteButton.tag = indexPath.row;

//    if ([priorityImage isKindOfClass:[UIImageView class]]) {
        switch (priority) {
            case PriorityLow:
                priorityImage.image = [UIImage imageNamed:@"yellow"];
                break;
            case PriorityMid:
                priorityImage.image = [UIImage imageNamed:@"green"];
                break;
            case PriorityHigh:
                priorityImage.image = [UIImage imageNamed:@"red"];
                break;
        }
//    }
    
//        titleLabel.text = task[@"title"];
//        aboutLabel.text = task[@"about"];
return cell;
}
    
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        return 85;
    }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PresenttViewController *detailVC = [storyboard instantiateViewControllerWithIdentifier:@"TaskDetailViewController"];
    detailVC.updateDelegate = self;
    [detailVC setTaskDetails:self.tasks[indexPath.row]];
    
    [self presentViewController:detailVC animated:YES completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10; // Space between cells
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footerView = [[UIView alloc] init];
    footerView.backgroundColor = [UIColor clearColor]; // Transparent
    return footerView;
}

- (void)updateTasksTableView {
    [self loadTODOTasks];
    [self.tasksTable reloadData];
    [self updateEmptyStateVisibility];
}

@end

