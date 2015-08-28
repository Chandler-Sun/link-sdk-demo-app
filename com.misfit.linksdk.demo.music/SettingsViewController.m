//
//  SettingsViewController.m
//  MFLButtonSDKDemo
//
//  Created by ASeign on 7/30/15.
//  Copyright (c) 2015 Misfit. All rights reserved.
//

#import "SettingsViewController.h"
#import <MisfitLinkSDK/MisfitLinkSDK.h>

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    //Check the button status
    self.swMisfitLinkButtonStatus.on = [MFLSession sharedInstance].enabled;
}

- (IBAction)onMisfitLinkStatusChanged:(UISwitch *)sender {
    BOOL isGoingToEnableMisfitLink = sender.on;
    if(isGoingToEnableMisfitLink){
        [[MFLSession sharedInstance] enableWithAppId:@"100"
                                           appSecret:@"C53ROcGYlXunwTUUpLitLQRnlR8PSgIF"
                                          completion:^(NSDictionary *commandMappingDict, NSDictionary *supportedCommands, MFLError *error) {
                                              if (error)
                                              {
                                                  //reset the status
                                                  sender.on = [MFLSession sharedInstance].enabled;
                                                  //TODO: handle error.
                                                  return;
                                              }
                                              sender.on = [MFLSession sharedInstance].enabled;
                                              //Show how to use the button.
            
        }];
        
        
    }
    else{
        [[MFLSession sharedInstance] disable];
        
    }
}


@end
