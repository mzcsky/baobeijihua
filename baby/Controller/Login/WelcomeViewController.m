//
//  WelcomeViewController.m
//  baby
//
//  Created by zhang da on 14-3-2.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "WelcomeViewController.h"
#import "UIButtonExtra.h"
#import "RegisterViewController.h"
#import "ResetPasswordViewController.h"
#import "ContactShareViewController.h"
#import "RootViewController.h"

//chulijian
#import "LessonViewController.h"
#import "TabbarController.h"


//chulijian


#import "UserTask.h"
#import "TaskQueue.h"
#import <ShareSDK/ShareSDK.h>
#import "ZCConfigManager.h"
#import "MemContainer.h"
#import "NSStringExtra.h"
#import "NSDictionaryExtra.h"
#import "NSDateExtra.h"
#import "Session.h"
#import "User.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import <TencentOpenAPI/TencentApiInterface.h>
#import <TencentOpenAPI/QQApi.h>
#import "Macro.h"
#import "WeiboSDK.h"
#import "WXApi.h"
#import "ShareManager.h"
#import "UserLessonLK.h"
#import "LZLoginModel.h"



@interface WelcomeViewController ()
@property (nonatomic,strong) NSString * access_token;
@property (nonatomic,strong) NSString * openid;
@end

@implementation WelcomeViewController {
    TencentOAuth *_tencentOauth;
    NSArray *_permissions;
}

- (void)dealloc {
    [_tencentOauth release];
    [super dealloc];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(getAccess_token:) name:@"WexinLogin"
                                               object:nil];


    self.view.backgroundColor = [UIColor clearColor];
    
    bg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, screentContentHeight)];
    [self.view addSubview:bg];
    bg.userInteractionEnabled = YES;
    bg.backgroundColor = [[[UIColor alloc] initWithRed:0.9 green:0.9 blue:0.9 alpha:1] autorelease];
    [bg release];
    //chulijian
    
    
//    UIButton * backBtn=[UIButton buttonWithType:UIButtonTypeCustom];
//    backBtn.frame=CGRectMake(0, 20, 40, 40);
//    backBtn.backgroundColor=[UIColor blackColor];
//    [bg addSubview:backBtn];
//    
//    [backBtn addTarget:self action:@selector(backBtnTouched) forControlEvents:UIControlEventTouchUpInside];
    
    
//    UIView *blur = [[UIView alloc] initWithFrame:CGRectMake(20, 30, 280, screentContentHeight - 60)];
//    blur.alpha = 0.6;
//    [bg addSubview:blur];
//    blur.layer.cornerRadius = 5;
//    [blur release];
    
    float posY = largeScreen? 100: 55;
    
 //   UIImageView *bbLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"baby_logo.png"]];
    UIImageView *bbLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"baby_login_V2.png"]];
    bbLogo.frame = CGRectMake(90, posY-65, 135, 140);
    [bg addSubview:bbLogo];
    [bbLogo release];
    
    posY += bbLogo.frame.size.height;
    posY += largeScreen? 100: 70;
    
    UIView *userNameBg = [[UIView alloc] initWithFrame:CGRectMake(50, posY - 60 , 220, 34)];
    userNameBg.backgroundColor = [UIColor whiteColor];
    userNameBg.layer.cornerRadius = 5;
    userNameBg.layer.borderColor = [[[UIColor alloc] initWithRed:0.88 green:0.88 blue:0.88 alpha:1] autorelease].CGColor;
    userNameBg.layer.borderWidth = 1;
    [bg addSubview:userNameBg];
    [userNameBg release];
    
    userName = [[UITextField alloc] initWithFrame:CGRectMake(10, 2, 200, 30)];
    userName.font = [UIFont systemFontOfSize:18];
    userName.clearButtonMode = UITextFieldViewModeWhileEditing;
    userName.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    userName.placeholder = @"手机号";
    userName.keyboardType = UIKeyboardTypeNamePhonePad;
    userName.delegate = self;
    userName.textColor = [UIColor grayColor];
    [userNameBg addSubview:userName];
    [userName release];
    
    posY += userNameBg.frame.size.height;
    posY += 10;
    
    UIView *passwordBg = [[UIView alloc] initWithFrame:CGRectMake(50, posY - 60, 220, 34)];
    passwordBg.backgroundColor = [UIColor whiteColor];
    passwordBg.layer.cornerRadius = 5;
    passwordBg.layer.borderColor = [[[UIColor alloc] initWithRed:0.88 green:0.88 blue:0.88 alpha:1] autorelease].CGColor;
    passwordBg.layer.borderWidth = 1;
    passwordBg.clipsToBounds = YES;
    [bg addSubview:passwordBg];
    [passwordBg release];
    
    password = [[UITextField alloc] initWithFrame:CGRectMake(10, 2, 167, 30)];
    password.font = [UIFont systemFontOfSize:18];
    password.clearButtonMode = UITextFieldViewModeWhileEditing;
    password.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    password.placeholder = @"密码";
    password.secureTextEntry = YES;
    password.delegate = self;
    password.textColor = [UIColor grayColor];
    [passwordBg addSubview:password];
    [password release];
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(185, 0, 1, 34)];
    lineView.backgroundColor = [[[UIColor alloc] initWithRed:0.88 green:0.88 blue:0.88 alpha:1] autorelease];
    [passwordBg addSubview:lineView];
    [lineView release];
    
    UIButton *loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    loginBtn.frame = CGRectMake(191, 8, 24, 17.5);
    [loginBtn setImage:[UIImage imageNamed:@"login1.png"] forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(doLogin) forControlEvents:UIControlEventTouchUpInside];
    [passwordBg addSubview:loginBtn];
    posY += passwordBg.frame.size.height;
    
    // 登录界面修改
    
    
    
    UIButton *forgetBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    forgetBtn.frame = CGRectMake(20, posY - 60, 120, 40);
    [forgetBtn setTitle:@"忘记密码?" forState:UIControlStateNormal];
    [forgetBtn setBackgroundColor:[UIColor clearColor]];
    [forgetBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [forgetBtn setTitleColor:[UIColor colorWithRed:234/255.0 green:166/255.0 blue:31/255.0 alpha:1] forState:UIControlStateHighlighted];
    forgetBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [forgetBtn addTarget:self action:@selector(resetPassword) forControlEvents:UIControlEventTouchUpInside];
    [bg addSubview:forgetBtn];
    
    UIButton *registerBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    registerBtn.frame = CGRectMake(200, posY - 60, 120, 40);
    [registerBtn setTitle:@"注册" forState:UIControlStateNormal];
    [registerBtn setBackgroundColor:[UIColor clearColor]];
    [registerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [registerBtn setTitleColor:[UIColor colorWithRed:234/255.0 green:166/255.0 blue:31/255.0 alpha:1] forState:UIControlStateHighlighted];
    registerBtn.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [registerBtn addTarget:self action:@selector(doRegister) forControlEvents:UIControlEventTouchUpInside];
    [bg addSubview:registerBtn];
    
    posY += forgetBtn.frame.size.height;
    //posY += 5;
    
    posY += 20;
    
    
    
    
    
    
    
    
    //qq登录
    
    if ([QQApi isQQInstalled]) {
        
        
    UIButton * qqLoginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    qqLoginBtn.frame = CGRectMake(210, posY - 90, 70, 70);
    
    qqLoginBtn.backgroundColor=[UIColor blackColor];
    
    [qqLoginBtn setBackgroundColor:[UIColor clearColor]];
    [qqLoginBtn addTarget:self action:@selector(doLoginWithqq) forControlEvents:UIControlEventTouchUpInside];
 //   qqLoginBtn.backgroundColor=[UIColor blackColor];
    [bg addSubview:qqLoginBtn];
    
    UIImageView *qqLoginImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qqlogin1.png"]];
    qqLoginImgView.frame = CGRectMake(20, 21, 30, 30);
    [qqLoginBtn addSubview:qqLoginImgView];
    [qqLoginImgView release];
    
    UILabel *qqLoginText = [[UILabel alloc] initWithFrame: CGRectMake(10, 44, 80, 40)];
  //  qqLoginText.backgroundColor=[UIColor cyanColor];
    qqLoginText.font = [UIFont systemFontOfSize:14];
    qqLoginText.text = @"QQ登录";
    qqLoginText.textColor = [UIColor whiteColor];
    [qqLoginBtn addSubview:qqLoginText];
    [qqLoginText release];
    
    }
  
    
    //微博登陆增加处
    
    UIButton *weiboLoginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    weiboLoginBtn.frame = CGRectMake(30, posY - 90, 70, 70);
    [weiboLoginBtn setBackgroundColor:[UIColor clearColor]];
    [weiboLoginBtn addTarget:self action:@selector(doLoginWithweibo:) forControlEvents:UIControlEventTouchUpInside];
  //  weiboLoginBtn.backgroundColor=[UIColor blackColor];
    [bg addSubview:weiboLoginBtn];
    
    UIImageView *weiboLoginImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"sinaLogin.png"]];
    weiboLoginImgView.frame = CGRectMake(20, 21, 30, 30);
    [weiboLoginBtn addSubview:weiboLoginImgView];
    [weiboLoginImgView release];

    UILabel *sinaLoginText = [[UILabel alloc] initWithFrame: CGRectMake(8, 44, 80, 40)];
    //  qqLoginText.backgroundColor=[UIColor cyanColor];
    sinaLoginText.font = [UIFont systemFontOfSize:14];
    sinaLoginText.text = @"新浪登录";
    sinaLoginText.textColor = [UIColor whiteColor];
    [weiboLoginBtn addSubview:sinaLoginText];
    [sinaLoginText release];
    
////    //微信登陆
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]])
    {
    UIButton *WeixinBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    WeixinBtn.frame = CGRectMake(30+90, posY - 90, 70, 70);
    [WeixinBtn setBackgroundColor:[UIColor clearColor]];
        [WeixinBtn addTarget:self action:@selector(doweixin:) forControlEvents:UIControlEventTouchUpInside];
    [bg addSubview:WeixinBtn];
    
    UIImageView *weixinImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"wixinLogin.png"]];
    weixinImageView.frame = CGRectMake(20, 21, 30, 30);
    [WeixinBtn addSubview:weixinImageView];
    [weixinImageView release];
    
    UILabel *weixinText = [[UILabel alloc]initWithFrame:CGRectMake(8, 44, 80, 40)];
    weixinText.font = [UIFont systemFontOfSize:14];
    weixinText.text = @"微信登陆";
    weixinText.textColor = [UIColor whiteColor];
    [WeixinBtn addSubview:weixinText];
        [weixinText release];
    }
    
    
    
    
    
    
    
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(dismissKeyboard)];
    tap.cancelsTouchesInView = NO;
    [bg addGestureRecognizer:tap];
    [tap release];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];

}



#pragma mark weixin
#pragma  mark -  Actions
-(void)doweixin:(UIButton *)sender{
    SendAuthReq* req =[[SendAuthReq alloc ] init];
    req.scope = @"snsapi_userinfo,snsapi_base";
    req.state = @"Project" ;
    [WXApi sendReq:req];
}
-(void)getAccess_token:(NSNotification*)noti
{
    [LZLoginModel getWeiXiTokenWithCode:noti.userInfo[@"code"] AndAppKey:wxAppKey AndSecret:wxSecret CallBack:^(BOOL success, NSString *message, NSDictionary *info) {
        if (success ==YES) {
            self.access_token = [info objectForKey:@"access_token"];
            self.openid = [info objectForKey:@"openid"];
            [LZLoginModel getUserInfoWithToken:self.access_token AndOpenid:self.openid CallBack:^(BOOL success, NSString *message, NSDictionary *info) {
                if (success == YES) {
                    
                    //                [[NSUserDefaults standardUserDefaults] setObject:[[userInfo sourceData] objectForKey:@"unionid"] forKey:@"wechatLoginUID"];
                    //                [[NSUserDefaults standardUserDefaults] synchronize];
                    NSString * nickName =[info objectForKey:@"nickname"];
                    // 注册
                    UserTask *task = [[UserTask alloc] initRegister:nickName
                                                           password:@""
                                                           atSchool:NO
                                                         introducer:@""];
                    task.responseCallbackBlock = ^(bool successful, id userInfo) {
                        if (successful) {
                            // 登陆
                            UserTask *loginTask = [[UserTask alloc] initLogin:nickName password:@""];
                            
                            loginTask.logicCallbackBlock = ^(bool successful, id userInfo) {
                                if (successful) {
                                    
                                    [UI showAlert:@"登录成功"];
                                    [ctr popToRootViewControllerWithAnimation:ViewSwitchAnimationSwipeL2R];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLoginNotification
                                                                                        object:nil];
                                    
                                    
                                } else {
                                    // 登陆
                                    [UI showAlert:@"登录失败，请检查网络环境或者帐号密码"];
                                    
                                    
                                }
                            };
                            [TaskQueue addTaskToQueue:loginTask];
                            [loginTask release];
                        }
                        else{
                        }
                    };
                    [TaskQueue addTaskToQueue:task];
                    [task release];
                    
                    
                    
                    
                    
                }
            }];
        }
    }];
    
    
}


#pragma mark utility
- (void)dismissKeyboard {
    if ([userName isFirstResponder] || [password isFirstResponder]) {
        [userName resignFirstResponder];
        [password resignFirstResponder];
        bg.center = CGPointMake(160, screentContentHeight/2);
    }
}


#pragma mark ui event



- (void)doLogin {
    [self dismissKeyboard];
    
    if ([userName.text length] != 11) {
        [UI showAlert:@"错误的手机号"];
        return;
    }
    
    if ([password.text length] < 6) {
        [UI showAlert:@"密码至少为6位"];
        return;
    }
    
    UserTask *task = [[UserTask alloc] initLogin:userName.text password:password.text];
    task.logicCallbackBlock = ^(bool succeeded, id userInfo){
        if (succeeded) {
            [UI showAlert:@"登录成功"];
            
//            if (![[NSUserDefaults standardUserDefaults] valueForKey:@"login"]) {
//                [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"login"];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//                
//                [ctr popToRootViewControllerWithAnimation:NO];
//
//                ContactShareViewController *cCtr = [[ContactShareViewController alloc] init];
//                [ctr pushViewController:cCtr animation:ViewSwitchAnimationSwipeR2L];
//                [cCtr release];
//            } else {
            [ctr popToRootViewControllerWithAnimation:ViewSwitchAnimationSwipeL2R];
            [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLoginNotification
                                                    object:nil];
            
//            }
        } else {
            [UI showAlert:@"登录失败，请检查网络环境或者帐号密码"];
        }
    };
    [TaskQueue addTaskToQueue:task];
    [task release];
}

- (void)doRegister {
    [self dismissKeyboard];

    RegisterViewController *regVC = [[RegisterViewController alloc] init];
    [ctr pushViewController:regVC animation:ViewSwitchAnimationSwipeR2L];
    [regVC release];
}
- (void)doLoginWithqq {
    [self dismissKeyboard];
    
    if ([TencentOAuth iphoneQQInstalled]) {
        _tencentOauth = [[TencentOAuth alloc] initWithAppId:@"1101357992" andDelegate:self];
        _permissions = [NSArray arrayWithObjects:kOPEN_PERMISSION_GET_INFO,
                        kOPEN_PERMISSION_GET_USER_INFO,
                        kOPEN_PERMISSION_GET_SIMPLE_USER_INFO, nil];
        
        [_tencentOauth authorize:_permissions inSafari:NO];
        
        [_tencentOauth getUserInfo];
        [_tencentOauth accessToken];
        [_tencentOauth openId];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"由于您的手机缺少QQ客户端,无法完成授权登陆" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil];
        [alert show];
    }
    
}




- (void)resetPassword {
    [self dismissKeyboard];

    ResetPasswordViewController *restVC = [[ResetPasswordViewController alloc] init];
    [ctr pushViewController:restVC animation:ViewSwitchAnimationSwipeR2L];
    [restVC release];
}
//-------------weibo

- (void)doLoginWithweibo:(UIButton *)btn
{
    
    [WeiboSDK registerApp:@"2212006707"];
    
    
    WBAuthorizeRequest *request = [WBAuthorizeRequest request];
    request.redirectURI = @"http://www.children-sketchbook.com";
    request.scope = @"all";
    request.userInfo = @{@"SSO_From": @"baby",
                        };
    [WeiboSDK sendRequest:request];
    
}


#pragma mark uitextfield delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == userName) {
        bg.center = CGPointMake(160, largeScreen? 90: 55);
    } else {
        bg.center = CGPointMake(160, largeScreen? 90: 55);
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == userName) {
        [password becomeFirstResponder];
    } else {
        [self dismissKeyboard];
    }
    return YES;
}

- (void)tencentDidLogin {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.qq.com/user/get_user_info?oauth_consumer_key=1101357992&access_token=%@&openid=%@&format=json", _tencentOauth.accessToken, _tencentOauth.openId]];
    NSLog(@"%@", url);
    
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    // 获取信息
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
        id result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSString *nickName = (NSString *)result[@"nickname"];
        

        // 注册
        UserTask *task = [[UserTask alloc] initRegister:nickName
                                               password:@""
                                               atSchool:NO
                                             introducer:@""];
        task.logicCallbackBlock = ^(bool successful, id userInfo) {
            if (successful) {
                
                // 登陆
                UserTask *loginTask = [[UserTask alloc] initLogin:nickName password:@""];
                
                loginTask.logicCallbackBlock = ^(bool successful, id userInfo) {
                    if (successful) {
                        [UI showAlert:@"登录成功"];
                        [ctr popToRootViewControllerWithAnimation:ViewSwitchAnimationSwipeL2R];
                        [[NSNotificationCenter defaultCenter] postNotificationName:UserDidLoginNotification
                                                                            object:nil];
                    } else {
                        [UI showAlert:@"登录失败，请检查网络环境或者帐号密码"];
                    }
                };
                [TaskQueue addTaskToQueue:loginTask];
                [loginTask release];
                
            } else {
                
            }
        };
        [TaskQueue addTaskToQueue:task];
        [task release];
        
    }];
    
}

- (void)tencentDidNotLogin:(BOOL)cancelled {
//    [UI showAlert:@"登录失败，请检查网络环境或者帐号密码"];
}

- (void)tencentDidNotNetWork {
//    [UI showAlert:@"登录失败，请检查网络环境或者帐号密码"];
}

@end
