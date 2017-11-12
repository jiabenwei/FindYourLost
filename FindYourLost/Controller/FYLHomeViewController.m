//
//  FYLHomeViewController.m
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/6.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "FYLHomeViewController.h"
#import "FYLLoginViewController.h"
#import "FYLHomeViewModel.h"
#import "FYLHomeTableViewCell.h"
#import "FYLDetailViewController.h"
#import "MJRefresh.h"
#import "FYLIPRecorder.h"

@interface FYLHomeViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , strong) FYLHomeViewModel *viewModel;
@property (nonatomic , assign) BOOL isLoadingMore;

@end

@implementation FYLHomeViewController

- (void)jumpToBarIndex:(NSString *)index andRefresh:(BOOL)refresh {
    self.viewModel.currentPage = 0;
    self.viewModel.isNoMoreData = NO;
    [self.viewModel.loadDataCommand execute:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewModel = [[FYLHomeViewModel alloc] init];
    [self.view setNeedsUpdateConstraints];
    [self setupUI];
    [self bindEvent];
    [ProgressHUD show];
    self.viewModel.currentPage = 0;
    self.viewModel.isNoMoreData = NO;
    [self.viewModel.loadDataCommand execute:nil];
    
    @weakify(self);
    self.viewModel.jumpCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSIndexPath *indexPath) {
        @strongify(self);
        [self jumpToDetailWithIndexPath:indexPath];
        return [RACSignal empty];
    }];
    
    BmobObject *obj = [[BmobObject alloc] initWithClassName:TABLEVISITOR];
    [obj setObject:[FYLIPRecorder getDeviceWANIPAddress] forKey:@"visitorIP"];
    [obj saveInBackground];
}


- (void)jumpToDetailWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.viewModel.dataArray.count) {
        BmobObject *object = [self.viewModel modelAtIndexPath:indexPath];
        FYLDetailViewController *detail = [[FYLDetailViewController alloc] initWithModel:object];
        [self.navigationController pushViewController:detail animated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [ProgressHUD dismiss];
}

- (void)bindEvent {
    @weakify(self);
    [RACObserve(self.viewModel, loadError) subscribeNext:^(NSNumber *error) {
        @strongify(self);
        self.isLoadingMore = NO;
        [ProgressHUD dismiss];
        [self dismissNoDataView];
        [self.tableView.mj_header endRefreshing];
        if ([error boolValue]) {
            // no data
            [self showNoDataView:UIEdgeInsetsMake(kTopHeight, 0, kTabBarHeight, 0)];
        }else{
            [self.tableView reloadData];
        }
    }];

}

- (void)addFreshView {
    if (!self.tableView.mj_header) {
        self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            self.viewModel.currentPage = 0;
            self.viewModel.isNoMoreData = NO;
            [self.viewModel.loadDataCommand execute:nil];
        }];
    }
}

- (void)setupUI {
    self.cNavigationBar.hidden = NO;
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.cNavigationBar.mas_bottom);
        make.bottom.equalTo(self.view).offset(-44-kSafeBottomHeight);
    }];
    [self addFreshView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:NSClassFromString(@"FYLHomeTableViewCell") forCellReuseIdentifier:@"FYLHomeTableViewCell"];
    }
    return _tableView;
}

#pragma mark - TableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel numberOfRows];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FYLHomeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FYLHomeTableViewCell" forIndexPath:indexPath];
    cell.indexPath = indexPath;
    cell.viewModel = self.viewModel;
    if (indexPath.row < [self.viewModel numberOfRows]) {
        [cell updateWithModel:[self.viewModel modelAtIndexPath:indexPath]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (!self.isLoadingMore && !self.viewModel.isNoMoreData) {
        if (indexPath.row == self.viewModel.dataArray.count-3) {
            self.isLoadingMore = YES;
            [self.viewModel.loadDataCommand execute:nil];
        }
    }
    
    
}

@end
