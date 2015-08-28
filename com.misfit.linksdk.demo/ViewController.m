//
//  ViewController.m
//  com.misfit.linksdk.demo
//
//  Created by ASeign on 8/14/15.
//  Copyright (c) 2015 Misfit. All rights reserved.
//

#import "ViewController.h"
#import "const.h"
#import <MisfitLinkSDK/MisfitLinkSDK.h>

@interface ViewController ()

@property (strong, nonatomic) IBOutlet UISwitch *stateOfLinkButton;
@property (strong, nonatomic) IBOutlet UITextView *logTextView;
@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logButtonEvent:) name:kButtonEventNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    self.stateOfLinkButton.on = [MFLSession sharedInstance].enabled;
}

- (void)logButtonEvent:(NSNotification*)notification {
    
    NSDictionary* userInfo = notification.userInfo;
    NSString *command = [userInfo objectForKey:@"command_name"];
    
    [self sendMessage:command];
}

- (void)sendMessage:(NSString*)theMsg {
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = [NSDate date];
    localNotification.alertBody = [NSString stringWithFormat:@"Flash Link Event: %@",theMsg];
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    if ([NSThread isMainThread] == NO)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString* newString = [NSString stringWithFormat:@"%@\n%@ %@",self.logTextView.text,theMsg,[NSDate date]];
            [self.logTextView setText:newString];
        });
        return;
    }
    NSString* newString = [NSString stringWithFormat:@"%@\n%@ %@",self.logTextView.text,theMsg,[NSDate date]];
    [self.logTextView setText:newString];
}

- (IBAction)onLinkStateChanged:(UISwitch *)sender {
    BOOL isGoingToEnableMisfitLink = sender.on;
    if(isGoingToEnableMisfitLink){
        //启用Button，需要安装Misfit Link
        [[MFLSession sharedInstance] enableWithAppId:@"101"
                                           appSecret:@"kb51t9NRPFnL2YBBTuGNib1OBKTgAYEc"
                                          completion:^(NSDictionary *commandMappingDict, NSDictionary *supportedCommands, MFLError *error) {
                                              if (error)
                                              {
                                                  //reset the status
                                                  sender.on = [MFLSession sharedInstance].enabled;
                                                  //TODO: handle error.
                                                  return;
                                              }
                                              sender.on = [MFLSession sharedInstance].enabled;
                                              [self.logTextView setText:@"已启用成功！"];
                                              
                                          }];
    }
    else{
        [[MFLSession sharedInstance] disable];
    }
}

@end
