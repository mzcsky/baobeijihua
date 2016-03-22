//
//  AppDelegate.m
//  baby
//
//  Created by zhang da on 14-2-3.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "WelcomeViewController.h"
#import "SplashViewController.h"
#import "LanuchViewController.h"
#import "ZCConfigManager.h"
#import "MobClick.h"
#import <ShareSDK/ShareSDK.h>
#import "ShareManager.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "WeiboSDK.h"
#import "AccountViewController.h"

#import "UIColor+Application.h"
#import "Macro.h"


#import "RMStoreViewController.h"
#import "RMPurchasesViewController.h"
#import "RMStoreLocalReceiptVerificator.h"
#import "NSURLConnection+BlocksKit.h"
#import "WXApi.h"

#import "APService.h"
#import "UserTask.h"
#import "TaskQueue.h"

#import "HomeViewController.h"

//------------
#import "LessonViewController.h"
#import "UserViewController.h"
//--------
AppDelegate *delegate;
NavigationControl *ctr;

#define USER_DEFAULT_SAVE [[NSUserDefaults standardUserDefaults] synchronize]
#define SPLASH_VER [[NSUserDefaults standardUserDefaults] valueForKey:@"SPLASH_VER"]
#define SPLASH_VER_WRITE(ver) [[NSUserDefaults standardUserDefaults] setValue:ver forKey:@"SPLASH_VER"]


@interface AppDelegate ()<WeiboSDKDelegate,WXApiDelegate>

@property (strong, nonatomic) NSDictionary *userInfoDict;
@property (strong, nonatomic) NSMutableArray *msgLists;
@property (strong, nonatomic) NSString * idString;
@end

@implementation AppDelegate {
    RMStoreLocalReceiptVerificator  *_receiptVerificator;
    RootViewController              *_rootVC;
}

- (void)dealloc {
    self.window = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kJPFNetworkDidReceiveMessageNotification object:nil];
    
    [super dealloc];
}

- (void)didReceiveWeiboRequest:(WBBaseResponse *) response
{
    if ([response isKindOfClass:WBAuthorizeResponse.class])
    {
        
    }
    
}
- (void)didReceiveWeiboResponse:(WBBaseResponse *)response
{
    
    if ([response isKindOfClass:[WBAuthorizeResponse class]]) {
        if (response.statusCode == 0) {
            NSLog(@"self.wbId : %@",[(WBAuthorizeResponse *)response userID]);
            [self dologinWeiBo:[(WBAuthorizeResponse *) response accessToken] UserId:[(WBAuthorizeResponse *)response userID]];
        }
    }
    NSLog(@"%@",response.userInfo);
}

-(void)dologinWeiBo:(NSString *)token UserId:(NSString *)userId
{
   
    UserTask *task = [[UserTask alloc] initRegister:userId
                                           password:@"111111"
                                           atSchool:NO
                                         introducer:@""];
    task.logicCallbackBlock = ^(bool successful, id userInfo) {
        if (successful) {
            
          
            UserTask *loginTask = [[UserTask alloc] initLogin:userId password:@"111111"];
            
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
            
            UserTask *loginTask = [[UserTask alloc] initLogin:userId password:@"111111"];
            
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
        }
    };
            [TaskQueue addTaskToQueue:task];
            [task release];
}

#pragma mark - 重写handleOpenURL和openURL
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{

    NSString *urlString = [url absoluteString];
    if ([urlString rangeOfString:@"wb2212006707"].length > 0) {
        return [WeiboSDK handleOpenURL:url delegate:self];
    }else{
        return ([TencentOAuth HandleOpenURL:url] || [WXApi handleOpenURL:url delegate:self]);
    }

}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    NSString *urlString = [url absoluteString];
    if ([urlString rangeOfString:@"wb2212006707"].length > 0) {
        return [WeiboSDK handleOpenURL:url delegate:self];
    }else{
        return ([TencentOAuth HandleOpenURL:url] || [WXApi handleOpenURL:url delegate:self]);
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    application.applicationIconBadgeNumber = 0;

    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];

    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];
    
    //----------tongzhi
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getUserId:) name:@"userInformation" object:nil];
    [self configWeiXin];
    [WeiboSDK enableDebugMode:YES];
    [WeiboSDK registerApp:@"2212006707"];
      delegate = self;
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    self.window.backgroundColor = [Shared bbYellow];
    
    LanuchViewController *lanuchVC = [[LanuchViewController alloc] init];
    
    self.window.rootViewController = lanuchVC;
    
    [self.window makeKeyAndVisible];
    
    [Shared init];
    
    [ShareManager me];
    
    
    lanuchVC.afterLanuchView = ^()
    {   
        
        if (iOSNotSupport)
        {
            [UI showAlert:@"iOS版本过低，无法保证软件正常运行，请及时升级"];
        }
        
        ctr = [[NavigationControl alloc] initWithHolder:self.window];
        
        // 用户已经登陆, 进入首页
        
        RootViewController *rootVC;
        
        rootVC = [[RootViewController alloc] initWithFrame:CGRectMake(0, 20, kScreenWidth, kScreenHeight - 20)];
        
        [ctr pushViewController:rootVC animation:ViewSwitchAnimationNone];
        
        [rootVC release];
        
        //https://itunes.apple.com/cn/app/id873922966
        NSString *urlStr = @"https://itunes.apple.com/lookup?id=873922966";
        NSURL *url = [NSURL URLWithString:urlStr];
        NSURLRequest *req = [NSURLRequest requestWithURL:url];
        [NSURLConnection connectionWithRequest:req delegate:self];
        
//        if (![[ZCConfigManager me] getSession]) {
//            // 用户没有登陆
//            WelcomeViewController *welVC = [[WelcomeViewController alloc] init];
//            [ctr pushViewController:welVC animation:ViewSwitchAnimationNone];
//            [welVC release];
//        }
        
        
        
        
        
        
        // 引导页
        NSString *version = [ZCConfigManager getCurrentVersion];
        
        if (![SPLASH_VER isEqualToString:version]) {
            SplashViewController *sCtr = [[SplashViewController alloc] init];
           [ctr pushViewController:sCtr animation:ViewSwitchAnimationNone];
            [sCtr release];
            
            SPLASH_VER_WRITE(version);
            USER_DEFAULT_SAVE;
        }
    };
    
    
    [MobClick startWithAppkey:UMENGKEY reportPolicy:(ReportPolicy)REALTIME channelId:nil];
    


    
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [APService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                       UIUserNotificationTypeSound |
                                                       UIUserNotificationTypeAlert)
                                           categories:nil];
    } else {
        //categories 必须为nil
        [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                       UIRemoteNotificationTypeSound |
                                                       UIRemoteNotificationTypeAlert)
                                           categories:nil];
    }
#else
    //categories 必须为nil
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                                   UIRemoteNotificationTypeSound |
                                                   UIRemoteNotificationTypeAlert)
                                       categories:nil];
#endif
    // Required
    [APService setupWithOption:launchOptions];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                      selector:@selector(networkDidRegister:)
                          name:kJPFNetworkDidRegisterNotification
                        object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                      selector:@selector(networkDidLogin:)
                          name:kJPFNetworkDidLoginNotification
                        object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMessageNotification:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
    
    
    
    
   // [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
   // [[UIApplication sharedApplication] setStatusBarHidden:TRUE];
    
  //  [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];

    return YES;
}

// 内置更新
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    NSError *error;
    id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    NSDictionary *appInfo = (NSDictionary *)json;
    
    NSString *version = [[[appInfo objectForKey:@"results"]objectAtIndex:0]objectForKey:@"version"];
    NSString *version1 = [ZCConfigManager getCurrentVersion];
    
    if ([self updateFlagWithAPPversion:version1 AndSerVersion:version]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"升级提示" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alertView show];
    }

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [[UIApplication sharedApplication]openURL:[NSURL URLWithString:@"https://itunes.apple.com/cn/app/id873922966"]];
    }
}





- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
    //UIStatusBarStyleDefault = 0 黑色文字，浅色背景时使用
    //UIStatusBarStyleLightContent = 1 白色文字，深色背景时使用
}

- (BOOL)prefersStatusBarHidden
{
    return YES; //返回NO表示要显示，返回YES将hiden
    
}

#pragma mark - 处理接收到的推送消息
- (void)didReceiveMessageNotification:(NSNotification *)notification
{
    NSLog(@"1010100101010101010");
}

- (void)networkDidRegister:(NSNotification *)notification
{
    NSLog(@"注册");

}

- (void)networkDidLogin:(NSNotification *)notification
{
    NSLog(@"登录");
}
- (void)configureStore
{
   
    _receiptVerificator = [[RMStoreLocalReceiptVerificator alloc] init];
    [RMStore defaultStore].receiptVerificator = _receiptVerificator;
}



- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)addLocalNotification
{

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [self addLocalNotification];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {

    
  //  NSLog(@"%ld",(long)application.applicationIconBadgeNumber);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"BagedNumber" object:[NSNumber numberWithInteger:application.applicationIconBadgeNumber] userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[AccountViewController class],@"viewControllers", nil]];
    
    [APService resetBadge];
    [APService setBadge:0];
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [APService setBadge:0];
    [application setApplicationIconBadgeNumber:0];
     [APService resetBadge];
    [APService setBadge:0];
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
    //application.applicationIconBadgeNumber +=[(NSNumber *)[[_userInfoDict objectForKey:@"aps"] objectForKey:@"badge"] intValue];
}

-(void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
   

    [APService registerDeviceToken:deviceToken];
}

//注册消息推送失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    NSLog(@"Register Remote Notifications error:{%@}",[error localizedDescription]);
}

//处理收到的消息推送
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    NSLog(@"推送的消息是--%@",userInfo);
    
    [APService handleRemoteNotification:userInfo];
    
    application.applicationIconBadgeNumber +=[(NSNumber *)[[userInfo objectForKey:@"aps"] objectForKey:@"badge"] intValue];
    
    NSLog(@"极光提示显示数目 是 %ld",(long)application.applicationIconBadgeNumber);
    
    
    

}
- (void)tagsAliasCallback:(int)iResCode tags:(NSSet*)tags alias:(NSString*)alias
{
    NSLog(@"alias is  %@",alias);
}
-(void)showCommentView:(NSString *)url from:(UIViewController *)fromController
{
    NSLog(@"95535");

}
- (void)getUserId:(NSNotification *)userId
{
    NSLog(@"%@",[userId object]  );
    
    self.idString=[userId object];
    
    [APService setAlias:[userId object] callbackSelector:@selector(tagsAliasCallback:tags:alias:) object:[userId object]];
    


}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
       [[NSUserDefaults standardUserDefaults] setObject:[(NSDictionary *)[userInfo objectForKey:@"aps"] objectForKey:@"badge"]  forKey:@"badge"];
    
    NSLog(@"userInfo from appdelegate  = %@",userInfo);

    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"badge"] > 0)
    {

        UIViewController *rootVC = (UIViewController *)[[UIApplication sharedApplication].delegate window].rootViewController;
        
        if ([rootVC isKindOfClass:[LanuchViewController class]]) {
      
        }
        
        
        
        if (_msgLists == nil) {
            _msgLists = [[NSMutableArray alloc]init];
            [_msgLists addObject:[(NSDictionary *)[userInfo objectForKey:@"aps"] objectForKey:@"alert"]];
        }
        
    }
    [APService handleRemoteNotification:userInfo];

    _userInfoDict = userInfo;

    
    completionHandler(UIBackgroundFetchResultNewData);


}

- (void)application:(UIApplication *)app didReceiveLocalNotification:(UILocalNotification *)notif {
    app.applicationIconBadgeNumber = 10;
//    app.applicationIconBadgeNumber +=[(NSNumber *)[[userInfo objectForKey:@"aps"] objectForKey:@"badge"] intValue];

}
-(BOOL)updateFlagWithAPPversion:(NSString *)appVersion AndSerVersion:(NSString*)serVersion{
    
    NSArray * SerVersionArray = [serVersion componentsSeparatedByString:@"."];
    NSArray * AppVersionArray = [appVersion componentsSeparatedByString:@"."];
    
    if ([AppVersionArray[0] integerValue]>=[SerVersionArray[0] integerValue]) {
        if([AppVersionArray[0] integerValue] == [SerVersionArray[0] integerValue]){
            if ([AppVersionArray[1] integerValue]>=[SerVersionArray[1] integerValue]) {
                if([AppVersionArray[1] integerValue]==[SerVersionArray[1] integerValue]){
                    if([AppVersionArray[2] integerValue]>=[SerVersionArray[2] integerValue]){
                        //不升级
                        return NO;
                    }else{
                        //升级
                        return YES;
                    }
                }else{
                    //不升级
                    return NO;
                }
            }else{
                //升级
                return YES;
            }
        }else{
            //不升级
            return NO;
        }
    }else{
        //升级
        return YES;
    }
    
}
#pragma mark - 微信相关
-(void)configWeiXin{
    [WXApi registerApp:wxAppKey withDescription:@"weixin"];
}

-(void)onResp:(BaseReq *)resp
{    if([resp isKindOfClass:[SendMessageToWXResp class]])
{
    NSLog(@"分享回调");
}else{
    
    /*
     ErrCode ERR_OK = 0(用户同意)
     ERR_AUTH_DENIED = -4（用户拒绝授权）
     ERR_USER_CANCEL = -2（用户取消）
     code    用户换取access_token的code，仅在ErrCode为0时有效
     state   第三方程序发送时用来标识其请求的唯一性的标志，由第三方程序调用sendReq时传入，由微信终端回传，state字符串长度不能超过1K
     lang    微信客户端当前语言
     country 微信用户当前国家信息
     */
    SendAuthResp *aresp = (SendAuthResp *)resp;
    
    if (aresp.errCode == 0) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WexinLogin" object:nil userInfo:@{@"code":aresp.code}];
    }
}
}





@end
