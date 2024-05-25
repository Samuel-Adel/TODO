//
//  CustomTableViewCell.h
//  workshop
//
//  Created by Samuel Adel on 18/04/2024.
//

#import <UIKit/UIKit.h>
#import "Task.h"
NS_ASSUME_NONNULL_BEGIN

@interface CustomTableViewCell : UITableViewCell
@property (nonatomic, strong) Task *task;
@end

NS_ASSUME_NONNULL_END
