//
//  WelcomeVC.m
//  POPWelcomeVC
//
//  Created by Trung Pham Hieu on 2/10/16.
//  Copyright © 2016 popeveryday. All rights reserved.
//

#import "WelcomeVC.h"

@interface WelcomeVC ()

@end

@implementation WelcomeVC

- (void)viewDidLoad {
    
    self.logoImage = [UIImage imageNamed:@"logo"];
    self.logoIphone = [UIImage imageNamed:@"logoiphone"];
    self.segueID = @"main"; //segue to perform after welcome screen
    
    //for secure app that require passcode for using
    self.passcode = @"abc123"; //leave blank if not using passcode
    self.recoveryEmail = @"user@demo.com"; //passcode will be sent to this email
    self.emailAppName = @"MyAppName"; //your app name that is displayed on email
    self.emailContactWebsite = @"http://www.aucoz.com";
    self.emailSenderName = @"JokeHay";
    self.senderEmailAddress = @"admin@aucoz.com";

    //use custome email title and body
//    self.customEmailTitle = @"Email title here";
//    self.customEmailBody = @"Custom email body here";
    
    //for app using internet like social apps
    self.isRequireInternet = YES;
    
    //this must be the last line
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
