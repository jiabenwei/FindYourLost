//
//  FYLMYContributionViewModel.m
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/11.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "FYLMYContributionViewModel.h"

@interface FYLMYContributionViewModel()

@end


@implementation FYLMYContributionViewModel

- (instancetype)init {
    if (self = [super init]) {
        
        @weakify(self);
        self.loadDateCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSNumber *input) {
            @strongify(self);
            [self loadDataWithType:input];
            return [RACSignal empty];
        }];
    }
    return self;
}

- (void)loadDataWithType:(NSNumber *)type {
    BmobQuery  *bquery = [BmobQuery queryWithClassName:TABLELOST];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:FYLUSERID];
    [bquery whereKey:@"userId" equalTo:userId];
    if ([type isEqual:@1]) {
        //lost
        [bquery whereKey:@"type" equalTo:@"1"];
    }else{
        [bquery whereKey:@"type" equalTo:@"2"];
    }
    @weakify(self);
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        @strongify(self);
        if (!error) {
            [self.dataArray removeAllObjects];
            [self.dataArray addObjectsFromArray:array];
        }
        [self checkError];
    }];

}

- (void)checkError {
    if (self.dataArray.count == 0) {
        self.loadError = @(YES);
    }else{
        self.loadError = @(NO);
    }
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}


- (NSInteger)itemCount {
    return self.dataArray.count;
}

- (id)modelAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item < self.dataArray.count) {
        return self.dataArray[indexPath.item];
    }
    return nil;
}

@end
