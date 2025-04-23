//
//  PresenttViewController.h
//  TODO
//
//  Created by Macos on 23/04/2025.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PresenttViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *titleTF;
@property (weak, nonatomic) IBOutlet UITextView *DescriptionTF;
@property (weak, nonatomic) IBOutlet UILabel *DataLable;
@property (weak, nonatomic) IBOutlet UISegmentedControl *prioritySegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *statusSegmentedControl;
- (void)setTaskDetails:(NSDictionary *)taskDict;

@end

NS_ASSUME_NONNULL_END
