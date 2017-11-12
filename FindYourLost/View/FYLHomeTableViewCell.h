//
//  FYLHomeTableViewCell.h
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/10.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FYLHomeViewModel;

@interface FYLHomeTableViewCell : UITableViewCell

@property (nonatomic , weak) FYLHomeViewModel *viewModel;
@property (nonatomic , strong) NSIndexPath *indexPath;


- (void)updateWithModel:(id)obj;

@end
