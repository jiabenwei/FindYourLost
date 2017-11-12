//
//  FYLMYContributionCollectionViewCell.h
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/11.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FYLMYContributionViewModel.h"

@interface FYLMYContributionCollectionViewCell : UICollectionViewCell

@property (nonatomic , weak) FYLMYContributionViewModel *viewModel;
@property (nonatomic , strong) NSIndexPath *indexPath;

- (void)updataViewWithObject:(BmobObject *)obj;

@end
