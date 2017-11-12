//
//  FYLMineViewModel.m
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/9.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "FYLMineViewModel.h"
#import "FYLMineModel.h"


static NSMutableDictionary *mineCellClassDic;

Class cellClassByModel(id model) {
    NSString *modelClassString = NSStringFromClass([model class]);
    Class cls = NSClassFromString(@"FYLMineTableViewCell");
    @synchronized (mineCellClassDic) {
        if (nil == mineCellClassDic) {
            mineCellClassDic = [NSMutableDictionary new];
            [mineCellClassDic setObject:@"FYLMineTableViewCell" forKey:@"FYLMineModel"];
        }
    }
    NSString *classString = [mineCellClassDic objectForKey:modelClassString];
    if (classString && classString.length) {
        cls = NSClassFromString(classString);
    }
    return cls;
}


@interface FYLMineViewModel()

@end


@implementation FYLMineViewModel

- (instancetype)init {
    if (self = [super init]) {
        @weakify(self);
        self.loadDataCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self);
            [self prepareData];
            return [RACSignal empty];
        }];
        
        
    }
    return self;
}

- (void)prepareData {
    [self willChangeValueForKey:@"dataArray"];
    NSMutableArray *section1 = [NSMutableArray array];
    FYLMineModel *lostModel = [[FYLMineModel alloc] init];
    lostModel.titleString = @"Lost";
    [section1 addObject:lostModel];
    
    FYLMineModel *foundModel = [[FYLMineModel alloc] init];
    foundModel.titleString = @"Found";
    [section1 addObject:foundModel];
    
    [self.dataArray addObject:section1];
    
    NSMutableArray *section2 = [NSMutableArray array];
    FYLMineModel *settingModel = [[FYLMineModel alloc] init];
    settingModel.titleString = @"Setting";
    [section2 addObject:settingModel];
    
    [self.dataArray addObject:section2];
    [self didChangeValueForKey:@"dataArray"];
}

- (NSMutableArray *)dataArray {
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc] init];
    }
    return _dataArray;
}

- (NSInteger)numberOfSections {
    return self.dataArray.count;
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section {
    if (section < self.dataArray.count) {
        NSArray *array = self.dataArray[section];
        return array.count;
    }
    return 0;
}

- (NSArray *)cellNamesArray {
    return @[@"FYLMineTableViewCell"];
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44.0f;
}

- (id)modelAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section < self.dataArray.count) {
        NSArray *models = self.dataArray[indexPath.section];
        if (indexPath.row < models.count) {
            return models[indexPath.row];
        }
        return nil;
    }
    return nil;
}

- (Class)cellClassAtIndexPath:(NSIndexPath *)indexPath {
    id model = [self modelAtIndexPath:indexPath];
    return cellClassByModel(model);
}

@end
