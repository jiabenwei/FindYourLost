//
//  FYLSetViewController.m
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/7.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "FYLSetViewController.h"

@interface FYLSetViewController ()

@property (nonatomic , strong) UIButton *backBtn;
@property (nonatomic , strong) UILabel *barTitleLabel;

@property (nonatomic , strong) UIView *currentVersionBg;
@property (nonatomic , strong) UIView *clearCacheBg;
@property (nonatomic , strong) UILabel *versionTitleLab;
@property (nonatomic , strong) UILabel *clearCacheLab;
@property (nonatomic , strong) UILabel *currentVersion;
@property (nonatomic , strong) UILabel *cacheLabel;

@property (nonatomic , strong) UIButton *logOutBtn;



@end

@implementation FYLSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.cNavigationBar.hidden = NO;
    [self.view setNeedsUpdateConstraints];
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
    
    self.currentVersionBg = [self bgView];
    [self.view addSubview:self.currentVersionBg];
    [self.currentVersionBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(RatioPoint(120+kSafeBottomHeight));
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(Screen_Width-RatioPoint(30), 40));
    }];
    
    self.clearCacheBg = [self bgView];
    [self.view addSubview:self.clearCacheBg];
    [self.clearCacheBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.currentVersionBg.mas_bottom).offset(5);
        make.centerX.equalTo(self.currentVersionBg);
        make.size.equalTo(self.currentVersionBg);
    }];
    
    self.versionTitleLab = [self titleLabel];
    [self.currentVersionBg addSubview:self.versionTitleLab];
    [self.versionTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.currentVersionBg);
        make.left.equalTo(self.currentVersionBg).offset(15);
    }];
    self.versionTitleLab.text = @"Current version";
    
    self.currentVersion = [self subTitleLabel];
    [self.currentVersionBg addSubview:self.currentVersion];
    [self.currentVersion mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.currentVersionBg).offset(-15);
        make.centerY.equalTo(self.currentVersionBg);
    }];
    self.currentVersion.text = @"v1.0";
    
    self.clearCacheLab = [self titleLabel];
    [self.clearCacheBg addSubview:self.clearCacheLab];
    [self.clearCacheLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.clearCacheBg);
        make.left.equalTo(self.clearCacheBg).offset(15);
    }];
    self.clearCacheLab.text = @"Clear cache";
    
    self.cacheLabel = [self subTitleLabel];
    [self.clearCacheBg addSubview:self.cacheLabel];
    [self.cacheLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.clearCacheBg).offset(-15);
        make.centerY.equalTo(self.clearCacheBg);
    }];
    
    NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    float cachSize = [self folderSizeAtPath:cachPath];
    self.cacheLabel.text = [NSString stringWithFormat:@"%.1fM",cachSize];
    
    @weakify(self);
    [self.clearCacheBg bk_whenTapped:^{
        @strongify(self);
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Clear the cache?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancle" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
        @weakify(self);
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            @strongify(self);
            [self clearOldCache];
        }];
        [alert addAction:sureAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
    
    
    
    
    [self.view addSubview:self.logOutBtn];
    [self.logOutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.clearCacheBg.mas_bottom).offset(80);
        make.size.equalTo(self.clearCacheBg);
        make.centerX.equalTo(self.clearCacheBg);
    }];
    
    [self.logOutBtn bk_whenTapped:^{
        @strongify(self);
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Log Out?" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancle" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:cancelAction];
        @weakify(self);
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            @strongify(self);
            [self logOut];
        }];
        [alert addAction:sureAction];
        [self presentViewController:alert animated:YES completion:nil];
    }];
    
    
    // Do any additional setup after loading the view.
}

- (void)logOut {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:FYLUSERID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:FYLUSERNAME];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:FYLUSERIMAGE];
    BOOL ret = [[NSUserDefaults standardUserDefaults] synchronize];
    if (ret) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)clearOldCache {
    [ProgressHUD show];
    [[SDImageCache sharedImageCache] clearDiskOnCompletion:nil];
    [[SDImageCache sharedImageCache] clearMemory];
    dispatch_async(
                   dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),^{
                       NSString *cachPath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                       //                               NSLog(@"%@", cachPath);
                       NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachPath];
                       //                               NSLog(@"files :%ld",[files count]);
                       for (NSString *p in files) {
                           NSError *error;
                           NSString *path = [cachPath stringByAppendingPathComponent:p];
                           if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                               [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
                               
                           }
                           
                       }
                       [self performSelectorOnMainThread:@selector(clearCacheSuccess) withObject:nil waitUntilDone:YES];});
    
}

- (void)clearCacheSuccess {
    [ProgressHUD showSuccess];
    self.cacheLabel.text = @"0M";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIButton *)logOutBtn {
    if (!_logOutBtn) {
        _logOutBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_logOutBtn setTitle:@"Log Out" forState:UIControlStateNormal];
        _logOutBtn.titleLabel.font = [UIFont systemFontOfSize:18];
        _logOutBtn.backgroundColor = [UIColor colorWithRed:0.88f green:0.08f blue:0.08f alpha:0.50f];
//        _logOutBtn.layer.borderColor = UIColorFromRGB(0xDDDDDD).CGColor;
//        _logOutBtn.layer.borderWidth = 0.5;
        _logOutBtn.clipsToBounds = YES;
    }
    return _logOutBtn;
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
        _barTitleLabel.text = @"Setting";
        [_barTitleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_barTitleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _barTitleLabel;
}

- (UIView *)bgView {
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectZero];
    bgView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1f];
//    bgView.layer.borderColor = UIColorFromRGB(0xDDDDDD).CGColor;
//    bgView.layer.borderWidth = 0.5;
    return bgView;
}


- (UILabel *)titleLabel {
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = UIColorFromRGB(0xFFFFFF);
    [titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    return titleLabel;
}


- (UILabel *)subTitleLabel {
    UILabel *subTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    subTitleLabel.font = [UIFont systemFontOfSize:12];
    subTitleLabel.textColor = UIColorFromRGB(0x555555);
    [subTitleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [subTitleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    return subTitleLabel;
}

- (float)folderSizeAtPath:(NSString*)folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]){
        return 0;
    }
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/(1024.0*1024.0);
}

- (long long) fileSizeAtPath:(NSString*)filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
    
}

@end
