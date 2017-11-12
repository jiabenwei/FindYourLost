//
//  FYLAddViewController.m
//  FindYourLost
//
//  Created by jiabenwei on 2017/11/8.
//  Copyright © 2017年 jiabenwei. All rights reserved.
//

#import "FYLAddViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface FYLAddViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIScrollViewDelegate>

@property (nonatomic , strong) UIButton *addPhotoBtn;
@property (nonatomic , strong) UIAlertController *alertController;
@property (nonatomic , strong) UITextField *titleTextField;
@property (nonatomic , strong) UITextField *whereTextField;
@property (nonatomic , strong) UITextField *phoneTextField;
@property (nonatomic , strong) UIButton *backBtn;
@property (nonatomic , strong) UILabel *barTitleLabel;
@property (nonatomic , strong) UIScrollView *scrollView;
@property (nonatomic , strong) UIView *contentView;
@property (nonatomic , strong) UILabel *dateLabel;
@property (nonatomic , strong) UIDatePicker *datePick;
@property (nonatomic , strong) UIView *blackCoverView;
@property (nonatomic , strong) UITextView *desTextView;
@property (nonatomic , strong) UILabel *placeHolderLabel;
@property (nonatomic , strong) UIButton *uploadBtn;
@property (nonatomic , strong) UIImage *photoImage;
@property (nonatomic , strong) NSString *type;
@property (nonatomic , copy) refreshHandle refreshHandle;
@property (nonatomic , strong) NSString *pictureUrlString;
@property (nonatomic , strong) BmobObject *model;
@property (nonatomic , strong) UIButton *finishButton;

@end

@implementation FYLAddViewController

- (instancetype)initWithModel:(BmobObject *)model andHandle:(refreshHandle)handle {
    if (self = [super init]) {
        self.refreshHandle = handle;
        self.model = model;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupUI];
    [self bindingEvents];
}

- (void)bindingEvents {
    @weakify(self);
    RACSignal *validTitle = [self.titleTextField.rac_textSignal map:^id(NSString *value) {
        return @(value.length > 0);
    }];
    RACSignal *validAddress = [self.whereTextField.rac_textSignal map:^id(NSString *value) {
        return @(value.length > 0);
    }];
    RACSignal *validPhone = [self.phoneTextField.rac_textSignal map:^id(NSString * value) {
        return @(value.length > 0);
    }];
    
    RACSignal *validPhoto = [RACObserve(self.addPhotoBtn, currentBackgroundImage) map:^id(id value) {
        if (self.addPhotoBtn.currentBackgroundImage) {
            return @(YES);
        }
        return @(NO);
    }];
    
    RACSignal *uploadActiveSignal = [RACSignal combineLatest:@[validTitle,validAddress,validPhone,validPhoto] reduce:^id(NSNumber *titleValid,NSNumber *addressValid,NSNumber *phoneValid,NSNumber *photoValid){
        return @([titleValid boolValue] && [addressValid boolValue] && [phoneValid boolValue] && [photoValid boolValue]);
    }];
    [[uploadActiveSignal map:^id(NSNumber *uploadActive) {
        return [uploadActive boolValue] ? [UIColor colorWithRed:0.64f green:0.78f blue:0.22f alpha:0.50f] : [UIColor colorWithRed:0.64f green:0.64f blue:0.64f alpha:0.50f];
    }] subscribeNext:^(UIColor *color) {
        @strongify(self);
        [self.uploadBtn setBackgroundColor:color];
    }];
    
    
    [[[[self.uploadBtn rac_signalForControlEvents:UIControlEventTouchUpInside] doNext:^(id x) {
        @strongify(self);
        self.uploadBtn.enabled = NO;
        self.finishButton.enabled = NO;
        [self.view endEditing:YES];
    }] flattenMap:^id(id value) {
        @strongify(self);
        return [self uploadMessage];
    }] subscribeNext:^(NSNumber *signedId) {
        @strongify(self);
        self.uploadBtn.enabled = YES;
        self.finishButton.enabled = YES;
        if ([signedId isEqual:@0]) {
            //success
            [self uploadAndBackToHomeView];
        }else if([signedId isEqual:@1]){
            //wrongpassword
            [ProgressHUD showError:@"upload error"];
        }
    }];

    [[[[self.finishButton rac_signalForControlEvents:UIControlEventTouchUpInside] doNext:^(id x) {
        @strongify(self);
        self.uploadBtn.enabled = NO;
        self.finishButton.enabled = NO;
        [self.view endEditing:YES];
    }] flattenMap:^id(id value) {
        @strongify(self);
        return [self changeStatus];
    }] subscribeNext:^(NSNumber *signedId) {
        @strongify(self);
        self.uploadBtn.enabled = YES;
        self.finishButton.enabled = YES;
        if ([signedId isEqual:@0]) {
            //success
            [self backToHomeViewAndRefrsh];
        }else if([signedId isEqual:@1]){
            //wrongpassword
            [ProgressHUD showError:@"upload error"];
        }
    }];
}

- (void)backToHomeViewAndRefrsh {
    [ProgressHUD showSuccess:@"upload success"];
    if (self.refreshHandle) {
        self.refreshHandle(YES,self.type);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (RACSignal *)changeStatus {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [ProgressHUD show:@"uploading"];
        BmobObject  *object = [BmobObject objectWithoutDataWithClassName:TABLELOST objectId:self.model.objectId];
        [object setObject:@"2" forKey:@"status"];
        [object updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
            if (isSuccessful) {
                [subscriber sendNext:@(0)];
            } else {
                [subscriber sendNext:@(1)];
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];
}

- (void)uploadAndBackToHomeView {
    if (self.model) {
        BmobObject  *object = [BmobObject objectWithoutDataWithClassName:TABLELOST objectId:self.model.objectId];
        if (self.photoImage) {
            [object setObject:self.pictureUrlString forKey:@"photoUrl"];
        }
        [object setObject:self.type forKey:@"type"];     //1 lost 2 found
        [object setObject:@"1"      forKey:@"status"];   //1 ing 2 finish
        [object setObject:self.titleTextField.text forKey:@"titleString"];
        [object setObject:self.dateLabel.text forKey:@"dateString"];
        [object setObject:self.whereTextField.text forKey:@"addressString"];
        [object setObject:self.phoneTextField.text forKey:@"phoneNum"];
        if (self.desTextView.text) {
            [object setObject:self.desTextView.text forKey:@"desString"];
        }
        [object updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
            if (isSuccessful) {
                [ProgressHUD showSuccess:@"upload success"];
                if (self.refreshHandle) {
                    self.refreshHandle(YES,self.type);
                }
                [self.navigationController popViewControllerAnimated:YES];
            } else {
               [ProgressHUD showError:@"upload error"];
            }

        }];

    }else{
        BmobObject *lost = [BmobObject objectWithClassName:TABLELOST];
        NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:FYLUSERID];
        [lost setObject:userId    forKey:@"userId"];
        [lost setObject:self.pictureUrlString forKey:@"photoUrl"];
        [lost setObject:self.type forKey:@"type"];     //1 lost 2 found
        [lost setObject:@"1"      forKey:@"status"];   //1 ing 2 finish
        [lost setObject:self.titleTextField.text forKey:@"titleString"];
        [lost setObject:self.dateLabel.text forKey:@"dateString"];
        [lost setObject:self.whereTextField.text forKey:@"addressString"];
        [lost setObject:self.phoneTextField.text forKey:@"phoneNum"];
        if (self.desTextView.text) {
            [lost setObject:self.desTextView.text forKey:@"desString"];
        }
        [lost saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
            if (isSuccessful) {
                //back game
                [ProgressHUD showSuccess:@"upload success"];
                if (self.refreshHandle) {
                    self.refreshHandle(YES,self.type);
                }
                [self.navigationController popViewControllerAnimated:YES];
            }else{
                [ProgressHUD showError:@"upload error"];
            }
            
        }];
    }
    

    
}

- (RACSignal *)uploadMessage {
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [ProgressHUD show:@"uploading"];
        if (self.photoImage == nil) {
            [subscriber sendNext:@0];
            [subscriber sendCompleted];
            return nil;
        }
        NSData *data = UIImagePNGRepresentation(self.photoImage);
        NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:FYLUSERID];
        BmobFile *file1 = [[BmobFile alloc] initWithFileName:[NSString stringWithFormat:@"%@%@.png",self.titleTextField.text,userId] withFileData:data];
        [file1 saveInBackground:^(BOOL isSuccessful, NSError *error) {
            if (isSuccessful) {
                self.pictureUrlString = file1.url;
                [subscriber sendNext:@(0)];
            }else{
                [subscriber sendNext:@(1)];//imageError
            }
            [subscriber sendCompleted];
        }];
        return nil;
    }];

}


- (void)setupUI {
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

    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(kTopHeight, 0, 0, 0));
    }];
    
    [self.scrollView addSubview:self.contentView];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.bottom.equalTo(self.scrollView);
        make.width.mas_equalTo(Screen_Width);
    }];
    
    [self creatSubViewsForContentView];
}

- (void)creatSubViewsForContentView {
    UIView *photoBgView = [self bgView];
    [self.contentView addSubview:photoBgView];
    [photoBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(15);
        make.left.equalTo(self.contentView).offset(RatioPoint(15));
        make.right.equalTo(self.contentView).offset(-RatioPoint(15));
        make.height.mas_equalTo(80);
    }];
    
    UILabel *photoTitle = [self titleLabel];
    [photoBgView addSubview:photoTitle];
    [photoTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(photoBgView).offset(15);
        make.centerY.equalTo(photoBgView);
    }];
    photoTitle.text = @"Photograph";
    
    [photoBgView addSubview:self.addPhotoBtn];
    [self.addPhotoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(photoBgView).offset(5);
        make.right.equalTo(photoBgView).offset(-15);
        make.size.mas_equalTo(CGSizeMake(70, 70));
    }];
    
    if (self.model) {
        [_addPhotoBtn sd_setBackgroundImageWithURL:[NSURL URLWithString:[self.model objectForKey:@"photoUrl"]] forState:UIControlStateNormal];
    }else{
        [_addPhotoBtn setTitle:@"+" forState:UIControlStateNormal];
    }
    

    UIView *typeBgView = [self bgView];
    [self.contentView addSubview:typeBgView];
    [typeBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(photoBgView.mas_bottom).offset(10);
        make.left.right.equalTo(photoBgView);
        make.height.mas_equalTo(40);
    }];
    
    UILabel *typeTitle = [self titleLabel];
    [typeBgView addSubview:typeTitle];
    [typeTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(typeBgView).offset(15);
        make.centerY.equalTo(typeBgView);
    }];
    typeTitle.text = @"Lost/Found";
    
    UILabel *foundLabel = [self subtitleLabel];
    [typeBgView addSubview:foundLabel];
    [foundLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(typeBgView).offset(5);
        make.bottom.equalTo(typeBgView).offset(-5);
        make.right.equalTo(typeBgView).offset(-15);
        make.width.mas_equalTo(50);
    }];
    foundLabel.text = @"Found";
    
    UILabel *lostLabel = [self subtitleLabel];
    [typeBgView addSubview:lostLabel];
    [lostLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.width.equalTo(foundLabel);
        make.right.equalTo(foundLabel.mas_left);
    }];
    lostLabel.text = @"Lost";
    
    @weakify(self);
    [foundLabel bk_whenTapped:^{
        @strongify(self);
        [self.view endEditing:YES];
        [self setLostLabelOn:NO lostLabel:lostLabel foundLabel:foundLabel];
    }];
    
    [lostLabel bk_whenTapped:^{
        @strongify(self);
        [self.view endEditing:YES];
        [self setLostLabelOn:YES lostLabel:lostLabel foundLabel:foundLabel];
    }];
    if (self.model) {
        if ([[self.model objectForKey:@"type"] isEqualToString:@"1"]) {
             [self setLostLabelOn:YES lostLabel:lostLabel foundLabel:foundLabel];
        }else{
            [self setLostLabelOn:NO lostLabel:lostLabel foundLabel:foundLabel];
        }
    }else{
        [self setLostLabelOn:YES lostLabel:lostLabel foundLabel:foundLabel];
    }
    
    UIView *titleBgView = [self bgView];
    [titleBgView bk_whenTapped:^{
        @strongify(self);
        [self.titleTextField becomeFirstResponder];
    }];
    [self.contentView addSubview:titleBgView];
    [titleBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(typeBgView.mas_bottom).offset(10);
        make.left.right.equalTo(typeBgView);
        make.height.mas_equalTo(40);
    }];
    
    UILabel *titleTitle = [self titleLabel];
    [titleBgView addSubview:titleTitle];
    [titleTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleBgView).offset(15);
        make.centerY.equalTo(titleBgView);
    }];
    titleTitle.text = @"Title";
    
    self.titleTextField = [self textField:@"Please enter a title"];
    [titleBgView addSubview:self.titleTextField];
    [self.titleTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(titleBgView).insets(UIEdgeInsetsMake(5, 80, 5, 15));
    }];
    
    if (self.model) {
        self.titleTextField.text = [self.model objectForKey:@"titleString"];
    }
    
    
    UIView *whenBgView = [self bgView];
    [whenBgView bk_whenTapped:^{
        @strongify(self);
        [self.view endEditing:YES];
        [self.view addSubview:self.blackCoverView];
        [self.blackCoverView addSubview:self.datePick];
        [UIView animateWithDuration:0.25 animations:^{
            self.blackCoverView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2f];
            CGRect datePickerFrame = self.datePick.frame;
            datePickerFrame.origin.y = Screen_height-datePickerFrame.size.height;
            self.datePick.frame = datePickerFrame;
        }];
    }];
    [self.contentView addSubview:whenBgView];
    [whenBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(titleBgView.mas_bottom).offset(10);
        make.left.right.equalTo(titleBgView);
        make.height.mas_equalTo(40);
    }];
    UILabel *whenTitle = [self titleLabel];
    [whenBgView addSubview:whenTitle];
    [whenTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(whenBgView).offset(15);
        make.centerY.equalTo(whenBgView);
    }];
    whenTitle.text = @"When";
    
    [whenBgView addSubview:self.dateLabel];
    [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(whenBgView).offset(-15);
        make.centerY.equalTo(whenBgView);
    }];
   
    
    if (self.model) {
        self.dateLabel.text = [self.model objectForKey:@"dateString"];
    }else{
        NSDate *date_one = [NSDate date];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
        self.dateLabel.text = [formatter stringFromDate:date_one];
    }
    
    UIView *whereBg = [self bgView];
    [whereBg bk_whenTapped:^{
        @strongify(self);
        [self.whereTextField becomeFirstResponder];
    }];
    [self.contentView addSubview:whereBg];
    [whereBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(whenBgView.mas_bottom).offset(10);
        make.left.right.equalTo(whenBgView);
        make.height.mas_equalTo(40);
    }];
    
    UILabel *whereTitle = [self titleLabel];
    [whereBg addSubview:whereTitle];
    [whereTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(whereBg).offset(15);
        make.centerY.equalTo(whereBg);
    }];
    whereTitle.text = @"Where";
    
    self.whereTextField = [self textField:@"Please enter the address"];
    [whereBg addSubview:self.whereTextField];
    [self.whereTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(whereBg).insets(UIEdgeInsetsMake(5, 80, 5, 15));
    }];
    
    if (self.model) {
        self.whereTextField.text = [self.model objectForKey:@"addressString"];
    }
    
    UIView *phoneNumBg = [self bgView];
    [phoneNumBg bk_whenTapped:^{
        @strongify(self);
        [self.phoneTextField becomeFirstResponder];
    }];
    [self.contentView addSubview:phoneNumBg];
    [phoneNumBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(whereBg.mas_bottom).offset(10);
        make.left.right.equalTo(whereBg);
        make.height.mas_equalTo(40);
    }];
    
    UILabel *phoneTitle = [self titleLabel];
    [phoneNumBg addSubview:phoneTitle];
    [phoneTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(phoneNumBg).offset(15);
        make.centerY.equalTo(phoneNumBg);
    }];
    phoneTitle.text = @"Phone";
    
    self.phoneTextField = [self textField:@"Please enter your phoneNumber"];
    [phoneNumBg addSubview:self.phoneTextField];
    self.phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
    [self.phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(phoneNumBg).insets(UIEdgeInsetsMake(5, 80, 5, 15));
    }];
    
    if (self.model) {
        self.phoneTextField.text = [self.model objectForKey:@"phoneNum"];
    }
    
    UIView *desBgView = [self bgView];
    [self.contentView addSubview:desBgView];
    [desBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(phoneNumBg.mas_bottom).offset(10);
        make.left.right.equalTo(phoneNumBg);
        make.height.mas_equalTo(80);
    }];
    
    self.placeHolderLabel = [self titleLabel];
    [desBgView addSubview:self.placeHolderLabel];
    [self.placeHolderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(desBgView).offset(12);
        make.left.equalTo(desBgView).offset(15);
    }];
    
    self.placeHolderLabel.text = @"Please enter the description (Optional)";
    
    [desBgView addSubview:self.desTextView];
    [self.desTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(desBgView).insets(UIEdgeInsetsMake(5 , 10 , 5, 10));
    }];
    
    if (self.model && [[self.model objectForKey:@"desString"] length]) {
        self.desTextView.text = [self.model objectForKey:@"desString"];
    }
    
    [[self.desTextView rac_textSignal] subscribeNext:^(NSString *text) {
        @strongify(self);
        if (text && text.length) {
            self.placeHolderLabel.hidden = YES;
        }else{
            self.placeHolderLabel.hidden = NO;
        }
    }];
    
    
    [self.contentView addSubview:self.uploadBtn];
    if (self.model) {
        [self.contentView addSubview:self.finishButton];
        [self.finishButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(desBgView.mas_bottom).offset(50);
            make.left.equalTo(desBgView);
            make.height.mas_equalTo(40);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-60);
        }];
        [self.uploadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(desBgView.mas_bottom).offset(50);
            make.right.equalTo(desBgView);
            make.height.mas_equalTo(40);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-60);
            make.width.equalTo(self.finishButton);
            make.left.equalTo(self.finishButton.mas_right).offset(10);
        }];
    }else{
        [self.uploadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(desBgView.mas_bottom).offset(50);
            make.left.right.equalTo(desBgView);
            make.height.mas_equalTo(40);
            make.bottom.equalTo(self.contentView.mas_bottom).offset(-60);
        }];
    }
    
}


- (void)setLostLabelOn:(BOOL)on
             lostLabel:(UILabel *)lostLabel
            foundLabel:(UILabel *)foundLabel {
    if (on) {
        //Lost
        lostLabel.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        lostLabel.textColor = UIColorFromRGB(0x222222);
        foundLabel.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
        foundLabel.textColor = UIColorFromRGB(0xFFFFFF);
        self.type = @"1";
    }else{
        //Found
        foundLabel.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.5];
        foundLabel.textColor = UIColorFromRGB(0x222222);
        lostLabel.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2];
        lostLabel.textColor = UIColorFromRGB(0xFFFFFF);
        self.type = @"2";
    }
}

- (UIButton *)addPhotoBtn {
    if (!_addPhotoBtn) {
        _addPhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _addPhotoBtn.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.2f];
//        _addPhotoBtn.layer.borderColor = UIColorFromRGB(0xDDDDDD).CGColor;
//        _addPhotoBtn.layer.borderWidth = 0.5;
        @weakify(self);
        [_addPhotoBtn bk_whenTapped:^{
            @strongify(self);
            [self.view endEditing:YES];
            [self presentViewController:self.alertController animated:YES completion:nil];
        }];
    }
    return _addPhotoBtn;
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
        //
        UIImage *imagesss = [info objectForKey:UIImagePickerControllerEditedImage];
        [self.addPhotoBtn willChangeValueForKey:@"currentBackgroundImage"];
        [self.addPhotoBtn setBackgroundImage:imagesss forState:UIControlStateNormal];
        self.photoImage = imagesss;
        [self.addPhotoBtn setTitle:@"" forState:UIControlStateNormal];
        [self.addPhotoBtn didChangeValueForKey:@"currentBackgroundImage"];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

- (UITextField *)textField:(NSString *)placeholdStr {
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectZero];
    textField.textColor = [UIColor blackColor];
    textField.font = [UIFont systemFontOfSize:13];
    textField.textAlignment = NSTextAlignmentRight;
    NSMutableAttributedString *attriStr= [[NSMutableAttributedString alloc] initWithString:placeholdStr];
    [attriStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13] range:NSMakeRange(0, attriStr.length)];
    [attriStr addAttribute:NSForegroundColorAttributeName value:UIColorFromRGB(0xFFFFFF) range:NSMakeRange(0, attriStr.length)];
    [attriStr addAttribute:NSBaselineOffsetAttributeName value:@-1 range:NSMakeRange(0, attriStr.length)];
    textField.attributedPlaceholder = attriStr;
    return textField;
}


- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backBtn setImage:[UIImage imageNamed:@"back_white"] forState:UIControlStateNormal];
        [_backBtn setImageEdgeInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        @weakify(self);
        [_backBtn bk_whenTapped:^{
            @strongify(self);
            [self.view endEditing:YES];
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
        if (self.model) {
            _barTitleLabel.text = @"Edit";
        }else{
            _barTitleLabel.text = @"Add";
        }
        [_barTitleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_barTitleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _barTitleLabel;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];
        _scrollView.delegate = self;
    }
    return _scrollView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        @weakify(self);
        [_contentView bk_whenTapped:^{
            @strongify(self);
            [self.view endEditing:YES];
        }];
    }
    return _contentView;
}


- (UILabel *)titleLabel {
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.font = [UIFont systemFontOfSize:14];
    titleLabel.textColor = UIColorFromRGB(0xFFFFFF);
    [titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    return titleLabel;
}

- (UIView *)bgView {
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectZero];
    bgView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.1f];
//    bgView.layer.borderColor = UIColorFromRGB(0xDDDDDD).CGColor;
//    bgView.layer.borderWidth = 0.5;
    return bgView;
}

- (UILabel *)subtitleLabel {
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    titleLabel.font = [UIFont systemFontOfSize:13];
    titleLabel.userInteractionEnabled = YES;
//    titleLabel.layer.borderColor = UIColorFromRGB(0xDDDDDD).CGColor;
//    titleLabel.layer.borderWidth = 0.5;
    titleLabel.textAlignment = NSTextAlignmentCenter;
//    titleLabel.textColor = UIColorFromRGB(0xFFFFFF);
//    [titleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
//    [titleLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    return titleLabel;
}

- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _dateLabel.font = [UIFont systemFontOfSize:13];
        _dateLabel.userInteractionEnabled = YES;
        _dateLabel.textAlignment = NSTextAlignmentRight;
        _dateLabel.textColor = UIColorFromRGB(0x222222);
        [_dateLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [_dateLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    }
    return _dateLabel;
}

- (UITextView *)desTextView {
    if (!_desTextView) {
        _desTextView = [[UITextView alloc] initWithFrame:CGRectZero];
        _desTextView.textColor = UIColorFromRGB(0x222222);
        _desTextView.font = [UIFont systemFontOfSize:13];
        _desTextView.backgroundColor = [UIColor clearColor];
    }
    return _desTextView;
}


- (UIDatePicker *)datePick {
    if (!_datePick) {
        _datePick = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, Screen_height, Screen_Width, Screen_height*0.3)];
        [_datePick setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        [_datePick setDatePickerMode:UIDatePickerModeDate];
        _datePick.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.9];
        NSDateFormatter *formatter_minDate = [[NSDateFormatter alloc] init];
        [formatter_minDate setDateFormat:@"yyyy-MM-dd"];
        NSDate *minDate = [formatter_minDate dateFromString:@"1900-01-01"];
        NSDate *maxDate = [NSDate date];
        [_datePick setMinimumDate:minDate];
        [_datePick setMaximumDate:maxDate];
        [_datePick addTarget:self action:@selector(dataValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _datePick;
}

-(void)dataValueChanged:(UIDatePicker*)picker {
    UIDatePicker *dataPicker_one = (UIDatePicker *)picker;
    NSDate *date_one = dataPicker_one.date;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    self.dateLabel.text = [formatter stringFromDate:date_one];
    
}

- (UIView *)blackCoverView {
    if (!_blackCoverView) {
        _blackCoverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Screen_Width, Screen_height)];
        @weakify(self);
        [_blackCoverView bk_whenTapped:^{
            @strongify(self);
           [UIView animateWithDuration:0.25f animations:^{
               CGRect datePickerFrame = self.datePick.frame;
               datePickerFrame.origin.y = Screen_height;
               self.datePick.frame = datePickerFrame;
               _blackCoverView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0f];
           } completion:^(BOOL finished) {
               [_blackCoverView removeFromSuperview];
           }];
        }];
    }
    return _blackCoverView;
}

- (UIButton *)uploadBtn {
    if (!_uploadBtn) {
        _uploadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_uploadBtn setTitle:@"Upload" forState:UIControlStateNormal];
        _uploadBtn.titleLabel.font = [UIFont systemFontOfSize:18];
//        _uploadBtn.layer.borderColor = UIColorFromRGB(0xDDDDDD).CGColor;
//        _uploadBtn.layer.borderWidth = 0.5;
        _uploadBtn.clipsToBounds = YES;
    }
    return _uploadBtn;
}

- (UIButton *)finishButton {
    if (!_finishButton) {
        _finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_finishButton setTitle:@"Done" forState:UIControlStateNormal];
        _finishButton.titleLabel.font = [UIFont systemFontOfSize:18];
        _finishButton.backgroundColor = [UIColor colorWithRed:0.64f green:0.78f blue:0.22f alpha:0.50f];
        //        _uploadBtn.layer.borderColor = UIColorFromRGB(0xDDDDDD).CGColor;
        //        _uploadBtn.layer.borderWidth = 0.5;
        _finishButton.clipsToBounds = YES;
    }
    return _finishButton;
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [ProgressHUD dismiss];
}

@end
