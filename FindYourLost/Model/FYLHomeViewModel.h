//
//  FYLHomeViewModel.h
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/10.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FYLHomeViewModel : NSObject

@property (nonatomic , strong) NSMutableArray *dataArray;
@property (nonatomic , strong) RACCommand *loadDataCommand;
@property (nonatomic , strong) RACCommand *jumpCommand;
@property (nonatomic , strong) NSNumber *loadError;
@property (nonatomic , assign) NSInteger currentPage;
@property (nonatomic , assign) BOOL isNoMoreData;

- (NSInteger)numberOfRows;

- (id)modelAtIndexPath:(NSIndexPath *)indexPath;

@end
