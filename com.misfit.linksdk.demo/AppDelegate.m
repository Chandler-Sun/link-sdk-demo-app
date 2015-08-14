//
//  AppDelegate.m
//  com.misfit.linksdk.demo
//
//  Created by ASeign on 8/14/15.
//  Copyright (c) 2015 Misfit. All rights reserved.
//

#import "AppDelegate.h"
#import "const.h"
#import <MisfitLinkSDK/MisfitLinkSDK.h>

//实现MFLGestureCommandDelegate
@interface AppDelegate ()<MFLGestureCommandDelegate>

@end

@implementation AppDelegate

#pragma mark - MFLGestureCommandDelegate

- (void) performActionByCommand:(MFLCommand *)command completion:(void (^)(MFLActionResultType result))completion
{
    //demo用
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter postNotificationName:kButtonEventNotification object:nil
                                    userInfo:@{
                                               @"command_name":command.name,
                                               @"command_desc":command.description
                                               }];
    completion(MFLActionResultTypeSuccess);
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //设置gestureCommandDelegate用于处理按钮事件
    [MFLSession sharedInstance].gestureCommandDelegate = self;
    
    
    //demo用
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]){
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil]];
    }
    
    return YES;
}

#pragma mark - methods that need to be overrided

- (void)applicationDidBecomeActive:(UIApplication *)application {
    //使SDK能处理applicationDidBecomeActive时间
    [[MFLSession sharedInstance] handleDidBecomeActive];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    BOOL handled = NO;
    //SDK处理openURL
    if ([[MFLSession sharedInstance] canHandleOpenUrl:url])
    {
        handled = [[MFLSession sharedInstance] handleOpenURL:url];
    }
    return handled;
}


@end
