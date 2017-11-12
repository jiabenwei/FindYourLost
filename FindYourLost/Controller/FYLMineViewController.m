//
//  FYLMineViewController.m
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/6.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "FYLMineViewController.h"
#import "FYLSetViewController.h"
#import "FYLMineViewModel.h"
#import "FYLMineTableViewCell.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "FYLSetViewController.h"
#import "FYLLoginViewController.h"
#import "FYLMYContributionViewController.h"

@interface FYLMineViewController ()<UITableViewDelegate , UITableViewDataSource ,UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (nonatomic , strong) UITableView *mainTableView;
@property (nonatomic , strong) FYLMineViewModel *viewModel;
@property (nonatomic , strong) UIView *headerInfoView;
@property (nonatomic , strong) UIImageView *iconImageView;
@property (nonatomic , strong) UILabel *userNameLabel;
@property (nonatomic , strong) UIAlertController *alertController;

@end

@implementation FYLMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewModel = [[FYLMineViewModel alloc] init];
    
    @weakify(self);
    self.viewModel.jumpCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(NSIndexPath * indexPath) {
        @strongify(self);
        if (![FYLCommon isLogin]) {
            FYLLoginViewController *loginViewController = [[FYLLoginViewController alloc] initWithLoginHandle:^(BOOL isLogin) {
                if (isLogin) {
                    [self jumpToDetailWithIndexPath:indexPath];
                }
            }];
            UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:loginViewController];
            navigation.navigationBarHidden = YES;
            [self.navigationController presentViewController:navigation animated:YES completion:nil];
            
        }else{
            [self jumpToDetailWithIndexPath:indexPath];
        }
        return [RACSignal empty];
    }];
    
    
    [self.viewModel.loadDataCommand execute:nil];
    [self setupUI];
    [self bindEvent];
}


- (void)jumpToDetailWithIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        FYLType type = 0;
        if (indexPath.row == 0) {
            type = FYLTypeLost;
        }else{
            type = FYLTypeFound;
        }
        FYLMYContributionViewController *viewController = [[FYLMYContributionViewController alloc] initWithType:type];
        [self.navigationController pushViewController:viewController animated:YES];
    }else{
        //setting
        FYLSetViewController *setViewController = [[FYLSetViewController alloc] init];
        [self.navigationController pushViewController:setViewController animated:YES];
    }
}


- (void)setupUI {
    [self.view addSubview:self.mainTableView];
    [self.mainTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    [self.headerInfoView addSubview:self.iconImageView];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(70, 70));
        make.centerX.equalTo(self.headerInfoView);
        make.top.equalTo(self.headerInfoView).offset(60);
    }];
    self.iconImageView.layer.cornerRadius = 35;
    
    
    [self.headerInfoView addSubview:self.userNameLabel];
    [self.userNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.headerInfoView);
        make.top.equalTo(self.iconImageView.mas_bottom).offset(15);
    }];
    
}

- (void)bindEvent {
    @weakify(self);
    [RACObserve(self.viewModel, dataArray) subscribeNext:^(id x) {
        @strongify(self);
        [self.mainTableView reloadData];
    }];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([FYLCommon isLogin]) {
        self.userNameLabel.text = [[NSUserDefaults standardUserDefaults] objectForKey:FYLUSERNAME];
        NSString *urlString = [[NSUserDefaults standardUserDefaults] objectForKey:FYLUSERIMAGE];
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:urlString] placeholderImage:[UIImage imageNamed:@"addPicture"]];
    }else{
        self.iconImageView.image = [UIImage imageNamed:@"addPicture"];
        self.userNameLabel.text = @"Login/Register";
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableView *)mainTableView {
    if (!_mainTableView) {
        _mainTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _mainTableView.backgroundColor = [UIColor clearColor];
        _mainTableView.delegate = self;
        _mainTableView.dataSource = self;
        _mainTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _mainTableView.scrollIndicatorInsets = _mainTableView.contentInset;
        [_mainTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        _mainTableView.tableHeaderView = self.headerInfoView;
        for (NSString *cellName in self.viewModel.cellNamesArray) {
            [_mainTableView registerClass:NSClassFromString(cellName) forCellReuseIdentifier:cellName];
        }
    }
    return _mainTableView;
}

#pragma mark - UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.viewModel numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.viewModel numberOfRowsInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.viewModel heightForRowAtIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 40.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    Class class = [self.viewModel cellClassAtIndexPath:indexPath];
    FYLMineTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(class) forIndexPath:indexPath];
    cell.indexPath = indexPath;
    cell.viewModel = self.viewModel;
    [cell updateWithModel:[self.viewModel modelAtIndexPath:indexPath]];
    return cell;
}

- (UIView *)headerInfoView {
    if (!_headerInfoView) {
        _headerInfoView = [[UIView alloc] initWithFrame:CGRectMake(RatioPoint(15), 0, Screen_Width-RatioPoint(30), 200)];
        _headerInfoView.backgroundColor = [UIColor clearColor];
    }
    return _headerInfoView;
}


- (UIImageView *)iconImageView {
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _iconImageView.clipsToBounds = YES;
        _iconImageView.contentMode = UIViewContentModeScaleAspectFill;
        _iconImageView.layer.borderColor = UIColorFromRGB(0xDDDDDD).CGColor;
        _iconImageView.layer.borderWidth = 0.5;
        _iconImageView.userInteractionEnabled = YES;
        
        @weakify(self);
        [_iconImageView bk_whenTapped:^{
            @strongify(self);
            if (![FYLCommon isLogin]) {
                FYLLoginViewController *loginViewController = [[FYLLoginViewController alloc] initWithLoginHandle:nil];
                UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:loginViewController];
                navigation.navigationBarHidden = YES;
                [self.navigationController presentViewController:navigation animated:YES completion:nil];
                
            }else{
                [self presentViewController:self.alertController animated:YES completion:nil];
            }
            
        }];
    }
    return _iconImageView;
}

- (UILabel *)userNameLabel {
    if (!_userNameLabel) {
        _userNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _userNameLabel.font = [UIFont systemFontOfSize:16];
        _userNameLabel.textColor = [UIColor whiteColor];
        _userNameLabel.userInteractionEnabled = YES;
        [_userNameLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_userNameLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        @weakify(self);
        [_userNameLabel bk_whenTapped:^{
            @strongify(self);
            if (![FYLCommon isLogin]) {
                FYLLoginViewController *loginViewController = [[FYLLoginViewController alloc] initWithLoginHandle:nil];
                UINavigationController *navigation = [[UINavigationController alloc] initWithRootViewController:loginViewController];
                navigation.navigationBarHidden = YES;
                [self.navigationController presentViewController:navigation animated:YES completion:nil];
                
            }
        }];
    }
    return _userNameLabel;
}



- (UIAlertController *)alertController {
    if (!_alertController) {
        _alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancle" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Take Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                [self getImageWithSourceType:UIImagePickerControllerSourceTypeCamera];
            }else{
                //alert
                [self showAlertWithTitle:@"Camera unavailable"];
            }
        }];
        UIAlertAction *archiveAction = [UIAlertAction actionWithTitle:@"Choose from Album" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
                [self getImageWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            }else{
                [self showAlertWithTitle:@"Album unavailable"];
            }
        }];
        [_alertController addAction:cancelAction];
        [_alertController addAction:deleteAction];
        [_alertController addAction:archiveAction];
    }
    return _alertController;
}

- (void)showAlertWithTitle:(NSString *)title {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:title preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
    
}

- (void)getImageWithSourceType: (UIImagePickerControllerSourceType)sourceType{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = sourceType;
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:^{
    }];
    
}

#pragma mark - ImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        //取到选中的图片
        UIImage *imagesss = [info objectForKey:UIImagePickerControllerEditedImage];
//        [self.addPhotoBtn setBackgroundImage:imagesss forState:UIControlStateNormal];
        [self saveImage:imagesss];
    }else{
        [self showAlertWithTitle:@"Only supported pictures"];
    }
    [picker dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:^{
    }];
}

- (void)saveImage:(UIImage *)image {
    NSData *data = UIImagePNGRepresentation(image);
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:FYLUSERID];
    BmobFile *file1 = [[BmobFile alloc] initWithFileName:[NSString stringWithFormat:@"%@.png",userId] withFileData:data];
    [ProgressHUD show:@"uploading"];
    [file1 saveInBackground:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            [self saveImageUrl:file1.url];
        }else{
            [ProgressHUD showError:@"upload error!"];
        }
    }];
}

- (void)saveImageUrl:(NSString *)imageUrl {
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:FYLUSERID];
    
    BmobObject  *gameScoreChange = [BmobObject objectWithoutDataWithClassName:TABLEUSER objectId:userId];
    [gameScoreChange setObject:imageUrl forKey:@"imageUrl"];
    [gameScoreChange updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            [ProgressHUD showSuccess];
            [[NSUserDefaults standardUserDefaults] setObject:imageUrl forKey:FYLUSERIMAGE];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"addPicture"]];
        } else {
            [ProgressHUD showError:@"upload error!"];
        }
    }];
}


@end
