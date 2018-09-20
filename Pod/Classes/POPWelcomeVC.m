//
//  POPWelcomeVC.m
//  Pods
//
//  Created by Trung Pham Hieu on 4/4/16.
//
//

#import "POPWelcomeVC.h"
#import <POPLib/POPLib.h>
#import <LocalAuthentication/LocalAuthentication.h>

@interface POPWelcomeVC ()<UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

@end

@implementation POPWelcomeVC
{
    UIImageView* logoView;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self checkRequireProperties];
}

-(void)checkRequireProperties
{
    NSDictionary* requireProperties = @{@"logoImage": self.logoImage == nil ? @"" : self.logoImage,
                                        @"segueID": self.segueID == nil ? @"" : self.segueID,
                                        @"senderEmailAddress": self.senderEmailAddress == nil ? @"" : self.senderEmailAddress,
                                        @"customEmailTitle": @{ @"data":self.senderEmailAddress == nil ? @"" : self.senderEmailAddress, @"relate": @{@"emailAppName": self.emailAppName == nil ? @"" : self.emailAppName} },
                                        @"customEmailBody": @{ @"data":self.customEmailBody == nil ? @"" : self.customEmailBody, @"relate": @{@"emailContactWebsite": self.emailContactWebsite == nil ? @"" : self.emailContactWebsite, @"emailSenderName": self.emailSenderName == nil ? @"" : self.emailSenderName} },
                                        };
    
    NSString* requireFieldsStr = @"";
    for (NSString* key in requireProperties.allKeys)
    {
        id value = [requireProperties objectForKey:key];
        
        if ([value isKindOfClass:[NSDictionary class]])
        {
            if (![StringLib isValid:[value objectForKey:@"data"]]) {
                
                NSDictionary* dic = (NSDictionary*)[value objectForKey:@"relate"];
                for (NSString* subkey in dic.allKeys) {
                    id subvalue = [dic objectForKey:subkey];
                    if (([subvalue isKindOfClass:[UIImage class]] && subvalue == nil) || (![subvalue isKindOfClass:[UIImage class]] && ![StringLib isValid:subvalue]))
                    {
                        requireFieldsStr = [requireFieldsStr stringByAppendingFormat:@"%@ is Required\n", subkey];
                    }
                }
            }
        }
        else
        {
            if (([value isKindOfClass:[UIImage class]] && value == nil) || (![value isKindOfClass:[UIImage class]] && ![StringLib isValid:value]))
            {
                requireFieldsStr = [requireFieldsStr stringByAppendingFormat:@"%@ is Required\n", key];
            }
        }
    }
    
    if ([StringLib isValid: self.passcode] && ![StringLib isValid:self.recoveryEmail]) {
        requireFieldsStr = [requireFieldsStr stringByAppendingFormat:@"%@ is Required\n", @"recoveryEmail"];
    }
    
    if ([StringLib isValid:requireFieldsStr]) {
        [ViewLib alertWithTitle:@"Properties Required" message:requireFieldsStr];
    }else{
        [self reloadWelcomeScreen];
    }
    
    
}



-(void) reloadWelcomeScreen
{
    [self.navigationController setNavigationBarHidden:YES];
    
    if (!logoView) {
        
        logoView = ImageViewWithImage( (self.logoIphone != nil && !(GC_Device_IsIpad)) ? self.logoIphone : self.logoImage );
        
        if(!(GC_Device_IsIpad) && self.logoIphone == nil)
        {
            logoView.frame = CGRectMake(0, 0, logoView.frame.size.width/2, logoView.frame.size.height/2);
        }
        
        logoView.center = self.view.center;
        
        [logoView setAutoresizingMask: UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin ];
        [self.view addSubview:logoView];
    }
    
    logoView.alpha = 0;
    
    [UIView animateWithDuration:0.5 delay:0.2 options:UIViewAnimationOptionCurveEaseIn animations:^(void){
        self->logoView.alpha = 1;
    } completion:^(BOOL finish)
     {
         if (self.isRequireInternet && ![NetLib isInternetAvailable]) {
             [ViewLib alertWithTitle:LocalizedText(@"Connection Error",nil) message:LocalizedText(@"Unable to connect with the server.\nCheck your internet connnection and try again.",nil) fromViewController:self callback:^(NSString *buttonTitle, NSString *alertTitle) {
                 [self reloadWelcomeScreen];
             } cancelButtonTitle:LocalizedText(@"Try again",nil) otherButtonTitles:nil];
             
             return;
         }
         
         if ([StringLib isValid:self.passcode])
         {
             if(self.isUsingTouchId)
             {
                 [self showTouchIdInput];
                 return;
             }
             
             [self requirePasscode];
         }
         else
         {
             [self forwardToMainView];
         }
     }];
}

-(void) showTouchIdInput
{
    LAContext *myContext = [[LAContext alloc] init];
    NSError *authError = nil;
    NSString *myLocalizedReasonString = @"Touch ID to show Touch ID working in a custom app";
    
    if ([myContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&authError]) {
        [myContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                  localizedReason:myLocalizedReasonString
                            reply:^(BOOL success, NSError *error) {
                                if (success) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [self forwardToMainView];
                                    });
                                } else {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        [self requirePasscode];
                                    });
                                }
                            }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self requirePasscode];
        });
    }
}

-(void) requirePasscode
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:LocalizedText(@"Passcode Required",nil) message:LocalizedText(@"Enter Passcode to Login",nil) preferredStyle:UIAlertControllerStyleAlert];
    
    
    [alert addAction:[UIAlertAction actionWithTitle:LocalizedText(@"Forgot Passcode",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self forgotPassword];
    }]];
    
    [alert addTextFieldWithConfigurationHandler:nil];
    
    [alert addAction:[UIAlertAction actionWithTitle:LocalizedText(@"OK",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString* pass = ((UITextField*)alert.textFields.firstObject).text;
        
        if ([pass isEqualToString:self.passcode]) {
            [self forwardToMainView];
        }else{
            [self requirePasscode];
        }
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void) forwardToMainView
{
    [self performSegueWithIdentifier:self.segueID sender:self];
}

-(void) viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)forgotPassword{
    if (![ViewLib alertNetworkConnectionStatusFromViewController:self])
    {
        return;
    }
    
    NSString* title = [StringLib isValid:self.customEmailTitle] ? self.customEmailTitle : LocalizedText(@"[APPNAME] Password Recovery",nil);
    title = [title stringByReplacingOccurrencesOfString:@"[APPNAME]" withString:self.emailAppName];
    title = [NetLib uRLEncoding: title];
    
    NSString* content = [StringLib isValid:self.customEmailBody] ? self.customEmailBody : LocalizedText(@"Hello user!\nThis is your old password: [PASS]\nIf you need help or have any questions, please visit [WEBSITE]\n\nSincerely,\n[SENDER].\n-------------------------\nPlease do not reply to this message. Mail sent to this address cannot be answered.",nil);
    content = [content stringByReplacingOccurrencesOfString:@"[PASS]" withString:self.passcode];
    content = [content stringByReplacingOccurrencesOfString:@"[WEBSITE]" withString:[[self.emailContactWebsite lowercaseString] stringByReplacingOccurrencesOfString:@"http://" withString:@""]];
    content = [content stringByReplacingOccurrencesOfString:@"[SENDER]" withString:self.emailSenderName];
    content = [NetLib uRLEncoding:content];
    
    NSString* url = [NSString stringWithFormat:@"http://mhr.chuaphuocan.com/?from=%@&to=%@&sub=%@&message=%@", self.senderEmailAddress, self.recoveryEmail, title, content];
    
    [ViewLib showLoadingWithTitle:@"Connecting to Server" detailText:@"Please wait" uiview:self.view container:nil];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        ReturnSet* rs = [NetLib downloadFileToPath:[FileLib getTempPath:@"sendMail.txt"] url:url];
        
        [ViewLib hideLoading:self.view];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!rs.result) {
                [ViewLib alertWithTitle:LocalizedText(@"Send Email Error",nil) message: LocalizedText(@"Recovery email cannot be sent. Please try again later.",nil)];
                return;
            }
            
            [ViewLib alertWithTitle: LocalizedText(@"Send Email Completed",nil) message:[NSString stringWithFormat: LocalizedText(@"Recovery email has been sent to %@. Please check your email.",nil), self.recoveryEmail] ];
        });
    });
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

