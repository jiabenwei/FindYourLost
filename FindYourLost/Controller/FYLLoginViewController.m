//
//  FYLLoginViewController.m
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/7.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "FYLLoginViewController.h"
#import "FYLRegisterViewController.h"

static const CGFloat ItemHeight = 38;

@interface FYLLoginViewController ()

@property (nonatomic , strong) UITextField *userNameTextField;
@property (nonatomic , strong) UITextField *passwordTextField;

@property (nonatomic , strong) UIView *userNameBgView;
@property (nonatomic , strong) UIView *passwordBgView;

@property (nonatomic , strong) UIButton *loginBtn;
@property (nonatomic , strong) UILabel *tipLabel;

@property (nonatomic , strong) UIButton *registerBtn;
@property (nonatomic , strong) UILabel *registerLabel;
@property (nonatomic , copy)   loginHandle loginHandel;

@property (nonatomic , strong) UIButton *backBtn;
@property (nonatomic , strong) UILabel *barTitleLabel;

@end

@implementation FYLLoginViewController

- (instancetype)initWithLoginHandle:(loginHandle)loginHandle {
    if (self = [super init]) {
        self.loginHandel = loginHandle;
    }
    return self;

}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Login";
    [self setupUI];
    [self bindEvent];
    // Do any additional setup after loading the view.
}

- (void)bindEvent {
    @weakify(self);
    RACSignal *validUserName = [self.userNameTextField.rac_textSignal map:^id(NSString *value) {
        @strongify(self);
        self.tipLabel.hidden = YES;
        return @([self isValidUserName:value]);
    }];
    RACSignal *validPassword = [self.passwordTextField.rac_textSignal map:^id(NSString *value) {
        @strongify(self);
        self.tipLabel.hidden = YES;
        return @([self isValidPassword:value]);
    }];
    
    RACSignal *loginActiveSignal = [RACSignal combineLatest:@[validUserName,validPassword] reduce:^id(NSNumber *userNameValid,NSNumber *passwordValid){
        return @([userNameValid boolValue] && [passwordValid boolValue]);
    }];
    [[loginActiveSignal map:^id(NSNumber *loginActive) {
        @strongify(self);
        self.loginBtn.enabled = [loginActive boolValue];
        return [loginActive boolValue] ? [UIColor colorWithRed:0.64f green:0.78f blue:0.22f alpha:0.50f] : [UIColor colorWithRed:0.64f green:0.64f blue:0.64f alpha:0.50f];
    }] subscribeNext:^(UIColor *color) {
        @strongify(self);
        [self.loginBtn setBackgroundColor:color];
    }];
    
    [[[[self.loginBtn rac_signalForControlEvents:UIControlEventTouchUpInside] doNext:^(id x) {
        @strongify(self);
        self.loginBtn.enabled = NO;
        [self.view endEditing:YES];
        self.tipLabel.hidden = YES;
    }] flattenMap:^id(id value) {
        @strongify(self);
        return [self verifyUserNameAndPassword];
    }] subscribeNext:^(NSNumber *signedId) {
        @strongify(self);
        self.loginBtn.enabled = YES;
        if ([signedId isEqual:@0]) {
            //success
            [ProgressHUD showSuccess:@"login success"];
            [self jumpToGameCenter];
        }else if([signedId isEqual:@1]){
            //wrongpassword
            self.tipLabel.hidden = NO;
            self.tipLabel.text = @"invalid password";
            [ProgressHUD dismiss];
        }else if([signedId isEqual:@2]){
            //no user
            self.tipLabel.hidden = NO;
            self.tipLabel.text = @"invalid userName";
            [ProgressHUD dismiss];
        }else{
            self.tipLabel.hidden = NO;
            self.tipLabel.text = @"request timeout";
            [ProgressHUD dismiss];
        }
    }];
    
    [[[self.registerBtn rac_signalForControlEvents:UIControlEventTouchUpInside] doNext:^(id x) {
        @strongify(self);
        self.registerBtn.enabled = NO;
        [self.view endEditing:YES];
        
    }] subscribeNext:^(id x) {
        @strongify(self);
        [self pushToRegister];
        self.registerBtn.enabled = YES;
    }];
}

- (void)pushToRegister {
    FYLRegisterViewController *controller = [[FYLRegisterViewController alloc] init];
    controller.backCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        if (self.loginHandel) {
            self.loginHandel(YES);
        }
        [self dismissViewControllerAnimated:YES completion:nil];
        return [RACSignal empty];
    }];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)jumpToGameCenter {
    if (self.loginHandel) {
        self.loginHandel(YES);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)getUserInfo:(BmobObject *)user {
    if (user) {
        NSString *userId = [user objectForKey:@"objectId"];
        NSString *userName = [user objectForKey:@"nickName"];
        NSString *userImage = [user objectForKey:@"imageUrl"];
        if (userId && userId.length) {
            [[NSUserDefaults standardUserDefaults] setObject:userId forKey:FYLUSERID];
            [[NSUserDefaults standardUserDefaults] setObject:userName forKey:FYLUSERNAME];
            [[NSUserDefaults standardUserDefaults] setObject:userImage forKey:FYLUSERIMAGE];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

- (RACSignal *)verifyUserNameAndPassword {
    
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [ProgressHUD show];
        BmobQuery   *bquery = [BmobQuery queryWithClassName:TABLEUSER];
        [bquery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
            if (!error) {
                BOOL isHaveUser = NO;
                NSString *password = nil;
                BmobObject *object = nil;
                for (BmobObject *obj in array) {
                    NSString *nickName = [obj objectForKey:@"nickName"];
                    if ([nickName isEqualToString:self.userNameTextField.text]) {
                        isHaveUser = YES;
                        object = obj;
                        password = [obj objectForKey:@"password"];
                        break;
                    }
                }
                if (isHaveUser) {
                    //findUser
                    if ([password isEqualToString:self.passwordTextField.text]) {
                        //success
                        [self getUserInfo:object];
                        [subscriber sendNext:@(0)];
                    }else{
                        //wrongpassword
                        [subscriber sendNext:@(1)];
                    }
                }else{
                    //nouser
                    [subscriber sendNext:@(2)];
                    
                }
            }else{
                [subscriber sendNext:@(3)];
            }
            
            [subscriber sendCompleted];
        }];
        
        return nil;
    }];
    
}


- (BOOL)isValidPassword:(NSString *)password {
    return password.length;
}

- (BOOL)isValidUserName:(NSString *)userName {
    return userName.length;
}

- (void)setupUI {
    self.cNavigationBar.hidden = NO;
    self.cNavigationBar.backgroundColor = [UIColor clearColor];
    [self.cNavigationBar addSubview:self.backBtn];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(44, 44));
        make.left.equalTo(self.cNavigationBar).offset(5);
        make.bottom.equalTo(self.cNavigationBar);
    }];
    
//    [self.cNavigationBar addSubview:self.barTitleLabel];
//    [self.barTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(self.cNavigationBar);
//        make.bottom.equalTo(self.cNavigationBar);
//        make.height.mas_equalTo(44);
//    }];
    
    UIView *superView = self.view;
    [superView addSubview:self.userNameBgView];
    
    [self.userNameBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(superView).offset(RatioPoint(120+kSafeBottomHeight));
        make.centerX.equalTo(superView);
        make.size.mas_equalTo(CGSizeMake(Screen_Width-RatioPoint(60), ItemHeight));
        
    }];
    
    superView = self.userNameBgView;
    [superView addSubview:self.userNameTextField];
    
    [self.userNameTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(superView).insets(UIEdgeInsetsMake(0, RatioPoint(15), 0, RatioPoint(15)));
    }];
    
    superView = self.view;
    [superView addSubview:self.passwordBgView];
    [self.passwordBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.userNameBgView.mas_bottom).offset(15);
        make.centerX.equalTo(superView);
        make.size.equalTo(self.userNameBgView);
    }];
    
    superView = self.passwordBgView;
    [superView addSubview:self.passwordTextField];
    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(superView).insets(UIEdgeInsetsMake(0, RatioPoint(15), 0, RatioPoint(15)));
    }];
    
    superView = self.view;
    [superView addSubview:self.loginBtn];
    [self.loginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordBgView.mas_bottom).offset(RatioPoint(80));
        make.size.equalTo(self.userNameBgView);
        make.centerX.equalTo(self.userNameBgView);
    }];
    
    [superView addSubview:self.tipLabel];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordBgView.mas_bottom).offset(10);
        make.left.equalTo(superView).offset(RatioPoint(20));
    }];
    
    [superView addSubview:self.registerLabel];
    [self.registerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.loginBtn.mas_bottom).offset(60);
        make.right.equalTo(self.passwordBgView);
    }];
    
    [superView addSubview:self.registerBtn];
    [self.registerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(100, 35));
        make.center.equalTo(self.registerLabel);
    }];
}

- (UIView *)userNameBgView {
    if (!_userNameBgView) {
        _userNameBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _userNameBgView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
//        _userNameBgView.layer.borderColor = UIColorFromRGB(0xDDDDDD).CGColor;
//        _userNameBgView.layer.borderWidth = 0.5;
        _userNameBgView.clipsToBounds = YES;
//        _userNameBgView.layer.shadowColor = UIColorFromRGB(0x222222).CGColor;
//        _userNameBgView.layer.shadowOpacity = 0.4;
    }
    return _userNameBgView;
}

- (UIView *)passwordBgView {
    if (!_passwordBgView) {
        _passwordBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _passwordBgView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1];
//        _passwordBgView.layer.borderColor = UIColorFromRGB(0xDDDDDD).CGColor;
//        _passwordBgView.layer.borderWidth = 0.5;
        _passwordBgView.clipsToBounds = YES;
    }
    return _passwordBgView;
    
}


- (UITextField *)userNameTextField {
    if (!_userNameTextField) {
        _userNameTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _userNameTextField.textColor = [UIColor blackColor];
        NSMutableAttributedString *attriStr= [[NSMutableAttributedString alloc]initWithString:@"Please enter userName"];
        [attriStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, attriStr.length)];
        [attriStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xFFFFFF) range:NSMakeRange(0, attriStr.length)];
        [attriStr addAttribute:NSBaselineOffsetAttributeName value:@-1 range:NSMakeRange(0, attriStr.length)];
        _userNameTextField.attributedPlaceholder = attriStr;
    }
    return _userNameTextField;
}

- (UITextField *)passwordTextField {
    if (!_passwordTextField) {
        _passwordTextField= [[UITextField alloc] initWithFrame:CGRectZero];
        _passwordTextField.textColor = [UIColor blackColor];
        _passwordTextField.secureTextEntry = YES;
        NSMutableAttributedString *attriStr = [[NSMutableAttributedString alloc]initWithString:@"Please enter password"];
        [attriStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, attriStr.length)];
        [attriStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xFFFFFF) range:NSMakeRange(0, attriStr.length)];
        [attriStr addAttribute:NSBaselineOffsetAttributeName value:@-1 range:NSMakeRange(0, attriStr.length)];
        _passwordTextField.attributedPlaceholder = attriStr;
    }
    return _passwordTextField;
}
- (UIButton *)loginBtn {
    if (!_loginBtn) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginBtn setTitle:@"Login" forState:UIControlStateNormal];
        _loginBtn.titleLabel.font = [UIFont systemFontOfSize:18];
//        _loginBtn.layer.borderColor = UIColorFromRGB(0xDDDDDD).CGColor;
//        _loginBtn.layer.borderWidth = 0.5;
        _loginBtn.clipsToBounds = YES;
    }
    return _loginBtn;
}

- (UIButton *)registerBtn {
    if (!_registerBtn) {
        _registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_registerBtn setBackgroundColor:[UIColor clearColor]];
    }
    return _registerBtn;
}

- (UILabel *)registerLabel {
    if (!_registerLabel) {
        _registerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _registerLabel.font = [UIFont systemFontOfSize:15];
        _registerLabel.backgroundColor = [UIColor clearColor];
        _registerLabel.textAlignment = NSTextAlignmentRight;
        _registerLabel.text = @"Register";
        _registerLabel.textColor = UIColorFromRGB(0xFFFFFF);
    }
    return _registerLabel;
}

- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _tipLabel.font = [UIFont systemFontOfSize:12];
        _tipLabel.textColor = [UIColor redColor];
        _tipLabel.numberOfLines = 0;
        
    }
    return _tipLabel;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:@"close_white"] forState:UIControlStateNormal];
        [_backBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        @weakify(self);
        [_backBtn bk_whenTapped:^{
            @strongify(self);
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
    }
    return _backBtn;
}

- (UILabel *)barTitleLabel {
    if (!_barTitleLabel) {
        _barTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _barTitleLabel.font = [UIFont systemFontOfSize:16];
        _barTitleLabel.textColor = [UIColor whiteColor];
        _barTitleLabel.text = @"Login";
        [_barTitleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_barTitleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _barTitleLabel;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [ProgressHUD dismiss];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [ProgressHUD dismiss];
}

@end
