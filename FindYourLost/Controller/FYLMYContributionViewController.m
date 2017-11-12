//
//  FYLMYContributionViewController.m
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/11.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "FYLMYContributionViewController.h"
#import "FYLMYContributionViewModel.h"
#import "FYLMYContributionCollectionViewCell.h"
#import "FYLAddViewController.h"
#import "FYLDetailViewController.h"

@interface FYLMYContributionViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic , assign) FYLType type;
@property (nonatomic , strong) UIButton *backBtn;
@property (nonatomic , strong) UILabel *barTitleLabel;
@property (nonatomic , strong) UICollectionView *collectionView;
@property (nonatomic , strong) FYLMYContributionViewModel *viewModel;

@end

@implementation FYLMYContributionViewController

- (instancetype)initWithType:(FYLType)type {
    if (self = [super init]) {
        self.type = type;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewModel = [[FYLMYContributionViewModel alloc] init];
    [self.view setNeedsUpdateConstraints];
    [self setupUI];
    [self bindEvent];
    NSNumber *type = @1;
    if (self.type == FYLTypeFound) {
        type = @2;
    }
    [ProgressHUD show];
    [self.viewModel.loadDateCommand execute:type];
}

- (void)bindEvent {
    @weakify(self);
    
    self.viewModel.jumpCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSIndexPath *indexPath) {
        @strongify(self);
        [self jumpToEditVC:indexPath];
        return [RACSignal empty];
    }];
    
    
    [RACObserve(self.viewModel, loadError) subscribeNext:^(NSNumber *loadError) {
        @strongify(self);
        [ProgressHUD dismiss];
        [self dismissNoDataView];
        if ([loadError boolValue]) {
            // no data
            [self showNoDataView:UIEdgeInsetsMake(kTopHeight, 0, 0, 0)];
        }else{
            [self.collectionView reloadData];
        }
    }];

}

- (void)jumpToEditVC:(NSIndexPath *)indexPath {
    BmobObject *model = [self.viewModel modelAtIndexPath:indexPath];
    
    if ([[model objectForKey:@"status"] isEqualToString:@"1"]) {
        FYLAddViewController *addVC = [[FYLAddViewController alloc] initWithModel:model andHandle:^(BOOL isSuccess, NSString *type) {
            if (isSuccess) {
                NSNumber *type = @1;
                if (self.type == FYLTypeFound) {
                    type = @2;
                }
                [self.viewModel.loadDateCommand execute:type];
            }
        }];
        [self.navigationController pushViewController:addVC animated:YES];
    }else{
        FYLDetailViewController *vc = [[FYLDetailViewController alloc] initWithModel:model];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
}

- (void)setupUI {
    self.cNavigationBar.hidden = NO;
    [self.cNavigationBar addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(44, 44));
        make.left.equalTo(self.cNavigationBar).offset(5);
        make.bottom.equalTo(self.cNavigationBar);
    }];
    
    [self.cNavigationBar addSubview:self.barTitleLabel];
    [self.barTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.cNavigationBar);
        make.bottom.equalTo(self.cNavigationBar);
        make.height.mas_equalTo(44);
    }];
    if (self.type == FYLTypeLost) {
        _barTitleLabel.text = @"Lost";
    }else{
        _barTitleLabel.text = @"Found";
    }
    
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self.view);
        make.top.equalTo(self.view).offset(kTopHeight);
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:@"back_white"] forState:UIControlStateNormal];
        [_backBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        @weakify(self);
        [_backBtn bk_whenTapped:^{
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    return _backBtn;
}

- (UILabel *)barTitleLabel {
    if (!_barTitleLabel) {
        _barTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _barTitleLabel.font = [UIFont systemFontOfSize:16];
        _barTitleLabel.textColor = [UIColor whiteColor];
        [_barTitleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_barTitleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _barTitleLabel;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
       
        [_collectionView registerClass:NSClassFromString(@"FYLMYContributionCollectionViewCell") forCellWithReuseIdentifier:@"FYLMYContributionCollectionViewCell"];
    }
    return _collectionView;

}

#pragma mark - UICollectionViewDelegate && DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.viewModel itemCount];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FYLMYContributionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FYLMYContributionCollectionViewCell" forIndexPath:indexPath];
    cell.indexPath = indexPath;
    cell.viewModel = self.viewModel;
    [cell updataViewWithObject:[self.viewModel modelAtIndexPath:indexPath]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(Screen_Width/2, Screen_Width/2+90);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0,0,0,0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0f;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [ProgressHUD dismiss];
}

@end
