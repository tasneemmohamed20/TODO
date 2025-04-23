//
//  InProgressViewController.m
//  TODO
//
//  Created by Macos on 23/04/2025.
//

#import "InProgressViewController.h"

@interface InProgressViewController () <UITableViewDelegate, UITableViewDataSource>
@end

@implementation InProgressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.inProgressTable.delegate = self;
    self.inProgressTable.dataSource = self;
    self.inProgressTable.separatorInset = UIEdgeInsetsZero;
    self.inProgressTable.rowHeight = 60;
    
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
}

- (void)loadInProgressTasks {
    NSArray *allTasks = [[NSUserDefaults standardUserDefaults] arrayForKey:@"tasks"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"status == %@", @(StatusInProgress)];
    NSArray *filteredTasks = [allTasks filteredArrayUsingPredicate:predicate];
    self.inProgressTasks = [filteredTasks mutableCopy];
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





@end
