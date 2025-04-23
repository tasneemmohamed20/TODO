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
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tasksTable.delegate = self;
    self.tasksTable.dataSource = self;
    self.tasksTable.separatorInset = UIEdgeInsetsZero;
    self.tasksTable.rowHeight = 60;
    self.tasksTable.estimatedSectionHeaderHeight = 0;
    self.tasksTable.estimatedSectionFooterHeight = 0;
    
   
    self.tasks = [[[NSUserDefaults standardUserDefaults] arrayForKey:@"tasks"] mutableCopy];
        if (!self.tasks) {
            self.tasks = [NSMutableArray array];
        }
    [self.tasksTable reloadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self.tasksTable reloadData];
    
}

- (IBAction)priorityButtons:(id)sender {
    
    self.selectedPriority = (Priority)[sender selectedSegmentIndex];
    
    // Only filter if text fields are empty
    if (self.tilteTF.text.length == 0 && self.aboutTf.text.length == 0) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"priority == %@", @(self.selectedPriority)];
        
        // Get all tasks from UserDefaults
        NSArray *allTasks = [[NSUserDefaults standardUserDefaults] arrayForKey:@"tasks"];
        
        // Filter tasks based on selected priority
        NSArray *filteredTasks = [allTasks filteredArrayUsingPredicate:predicate];
        
        // Update tasks array and reload table
        self.tasks = [filteredTasks mutableCopy];
        [self.tasksTable reloadData];
    }
}

- (IBAction)addTaskAction:(id)sender {
    NSString *title = _tilteTF.text;
    NSString *about = _aboutTf.text;
    NSDate *date = [NSDate date];
    if (title.length > 0 && about.length > 0) {
        NSDictionary *task = @{
            @"title": title,
            @"about": about,
            @"priority": @(self.selectedPriority),
            @"date": date,
            @"status": @(StatusInProgress)
        };
        
        [self.tasks addObject:task];
        [self saveTasks];
        [self.tasksTable reloadData];
        
        _tilteTF.text = @"";
        _aboutTf.text = @"";
        self.selectedPriority = PriorityLow;
    }
}


- (void)saveTasks {
    [[NSUserDefaults standardUserDefaults] setObject:self.tasks forKey:@"tasks"];
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
        self.tasks = [allTasks mutableCopy];
        [self.tasksTable reloadData];
    }
}

- (IBAction)deleteTaskAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:button.tag inSection:0];
    
    [self.tasks removeObjectAtIndex:indexPath.row];
    [self saveTasks];
    [self.tasksTable reloadData];
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
    
    cell.contentView.frame = UIEdgeInsetsInsetRect(cell.contentView.frame, UIEdgeInsetsMake(15, 10, 15, 10));
    
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
    
//        titleLabel.text = task[@"title"];
//        aboutLabel.text = task[@"about"];
return cell;
}
    
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
        return 85;
    }

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Get the selected task
    NSDictionary *selectedTask = self.tasks[indexPath.row];
    
    // Create and configure the detail view controller
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PresenttViewController *detailVC = [storyboard instantiateViewControllerWithIdentifier:@"TaskDetailViewController"];
    [detailVC setTaskDetails:selectedTask];
    
    // Present the detail view controller
    [self presentViewController:detailVC animated:YES completion:nil];
}

@end
