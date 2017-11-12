//
//  FYLHomeViewModel.m
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/10.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "FYLHomeViewModel.h"
#define MaxSize           20


@interface FYLHomeViewModel()

@end

@implementation FYLHomeViewModel

- (instancetype)init {
    if (self = [super init]) {
        
        @weakify(self);
        self.loadDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self);
            if (input && [input isKindOfClass:[NSString class]]) {
                [self loadDateWithKey:input];
            }else{
                [self loadDataFromService];
            }
            return [RACSignal empty];
        }];
    }
    return self;
}

- (void)loadDateWithKey:(NSString *)input {
    //invalid this version
}

- (void)loadDataFromService {
    BmobQuery  *bquery = [BmobQuery queryWithClassName:TABLELOST];
    bquery.limit = MaxSize*(self.currentPage+1);
//    bquery.skip = MaxSize * self.currentPage;
//    bquery.skip = MaxSize *self.currentPage;
    [bquery orderByDescending:@"createdAt"];
    @weakify(self);
//    NSLog(@"jjjjjjjjjjjjjjjjjjjjj");
    [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        @strongify(self);
        if (!error) {
//            if (self.currentPage == 0) {
                [self.dataArray removeAllObjects];
//            }
            [self.dataArray addObjectsFromArray:array];
            if (array.count == bquery.limit) {
                self.currentPage++;
            }else{
                self.isNoMoreData = YES;
            }
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
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}


- (NSInteger)numberOfRows {
    return self.dataArray.count;
}

- (id)modelAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.dataArray.count) {
        return self.dataArray[indexPath.row];
    }
    return nil;
}

@end
