//
//  FYLMineViewModel.h
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/9.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FYLMineViewModel : NSObject

- (instancetype)init;

@property (nonatomic , strong) NSArray *cellNamesArray;
@property (nonatomic , strong) RACCommand *loadDataCommand;
@property (nonatomic , strong) RACCommand *jumpCommand;
@property (nonatomic , strong) NSMutableArray *dataArray;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (CGFloat) heightForRowAtIndexPath:(NSIndexPath *)indexPath;

- (id)modelAtIndexPath:(NSIndexPath *)indexPath;
- (Class)cellClassAtIndexPath:(NSIndexPath *)indexPath;

@end
