//
//  FYLMineTableViewCell.h
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/9.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FYLMineViewModel;
@interface FYLMineTableViewCell : UITableViewCell

@property (nonatomic , strong) NSIndexPath *indexPath;
@property (nonatomic ,weak) FYLMineViewModel *viewModel;

- (void)updateWithModel:(id)model;


@end
