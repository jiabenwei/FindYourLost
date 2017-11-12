//
//  FYLMYContributionViewModel.h
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/11.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FYLMYContributionViewModel : NSObject

@property (nonatomic , strong) RACCommand *loadDateCommand;
@property (nonatomic , strong) NSNumber *loadError;
@property (nonatomic , strong) RACCommand *jumpCommand;

@property (nonatomic , strong) NSMutableArray *dataArray;

- (NSInteger)itemCount;

- (id)modelAtIndexPath:(NSIndexPath *)indexPath;

@end
