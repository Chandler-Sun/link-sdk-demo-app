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
    
    //Check the button status
    self.swMisfitLinkButtonStatus.on = [MFLSession sharedInstance].enabled;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)onMisfitLinkStatusChanged:(UISwitch *)sender {
    BOOL isGoingToEnableMisfitLink = sender.on;
    if(isGoingToEnableMisfitLink){
        [[MFLSession sharedInstance] enableWithAppId:@"misfittest"
                                           appSecret:@"OHhJPAcTeLKmb8nZHd59u9sdyi8no3EU"
                                          completion:^(NSDictionary *commandMappingDict, NSArray *supportedCommands, MFLError *error) {
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
