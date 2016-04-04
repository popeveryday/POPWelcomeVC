//
//  POPWelcomeVC.m
//  Pods
//
//  Created by Trung Pham Hieu on 4/4/16.
//
//

#import "POPWelcomeVC.h"

@interface POPWelcomeVC ()<UIAlertViewDelegate, MFMailComposeViewControllerDelegate>

@end

@implementation POPWelcomeVC
{
    UIImageView* logoView;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary* requireProperties = @{
                                        @"logoImage": self.logoImage == nil ? @"" : self.logoImage,
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
        [CommonLib alertWithTitle:@"Properties Required" message:requireFieldsStr];
    }else{
        [self reloadWelcomeScreen];
    }
}

-(void) reloadWelcomeScreen{
    [self.navigationController setNavigationBarHidden:YES];
    
    if (!logoView) {
        
        logoView = ImageViewWithImage( (self.logoIphone != nil && !GC_Device_IsIpad) ? self.logoIphone : self.logoImage );
        
        if(!GC_Device_IsIpad && self.logoIphone == nil)
        {
            logoView.frame = CGRectMake(0, 0, logoView.frame.size.width/2, logoView.frame.size.height/2);
        }
        
        logoView.center = self.view.center;
        
        [logoView setAutoresizingMask: UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin ];
        [self.view addSubview:logoView];
    }
    
    logoView.alpha = 0;
    
    [UIView animateWithDuration:0.5 delay:0.2 options:UIViewAnimationOptionCurveEaseIn animations:^(void){
        logoView.alpha = 1;
    } completion:^(BOOL finish)
     {
         if (self.isRequireInternet && ![NetLib isInternetAvailable]) {
             [CommonLib alertWithTitle:LocalizedText(@"Connection Error",nil) message:LocalizedText(@"Unable to connect with the server.\nCheck your internet connnection and try again.",nil) container:self cancelButtonTitle:LocalizedText(@"Try again",nil) otherButtonTitles:nil];
             return;
         }
         
         if ([StringLib isValid:self.passcode]) {
             [CommonLib alertSecureInputBoxWithTitle: LocalizedText(@"Passcode Required",nil) message: LocalizedText(@"Enter Passcode to Login",nil) container:self cancelButtonTitle: LocalizedText(@"Forgot Passcode",nil) otherButtonTitles: LocalizedText(@"OK",nil),nil];
         }else{
             [self forwardToMainView];
         }
     }];
}

-(void) forwardToMainView
{
    [self performSegueWithIdentifier:self.segueID sender:self];
}

-(void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    NSString* title = [alertView buttonTitleAtIndex:buttonIndex];
    
    if ([alertView.title isEqualToString: LocalizedText(@"Connection Error",nil)] && [title isEqualToString:LocalizedText(@"Try again",nil)])
    {
        [self reloadWelcomeScreen];
        return;
    }
    
    if ([alertView.title isEqualToString: LocalizedText(@"Passcode Required",nil)]) {
        if ([title isEqualToString: LocalizedText(@"OK",nil)]) {
            NSString* pass = [alertView textFieldAtIndex:0].text;
            
            if ([pass isEqualToString:self.passcode]) {
                [self forwardToMainView];
            }else{
                [CommonLib alertSecureInputBoxWithTitle: LocalizedText(@"Passcode Required",nil) message: LocalizedText(@"Enter Passcode to Login",nil) container:self cancelButtonTitle: LocalizedText(@"Forgot Passcode",nil) otherButtonTitles:LocalizedText(@"OK",nil),nil];
            }
        }
        
        if ([title isEqualToString: LocalizedText(@"Forgot Passcode",nil)])
        {
            if (![CommonLib alertInternetConnectionStatus]) {
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
            
            NSString* url = [NSString stringWithFormat:@"http://services.poptato.com/mailhelper/?from=%@&to=%@&sub=%@&message=%@", self.senderEmailAddress, self.recoveryEmail, title, content];
            
            ReturnSet* rs = [NetLib downloadFileToPath:[FileLib getTempPath:@"sendMail.txt"] url:url];
            
            if (!rs.result) {
                [CommonLib alertWithTitle:LocalizedText(@"Send Email Error",nil) message: LocalizedText(@"Recovery email cannot be sent. Please try again later.",nil) container:self cancelButtonTitle: LocalizedText(@"OK",nil) otherButtonTitles:nil];
                return;
            }
            
            [CommonLib alertWithTitle: LocalizedText(@"Send Email Completed",nil) message:[NSString stringWithFormat: LocalizedText(@"Recovery email has been sent to %@. Please check your email.",nil), self.recoveryEmail] container:self cancelButtonTitle: LocalizedText(@"OK",nil) otherButtonTitles:nil];
        }
    }else{
        [CommonLib alertSecureInputBoxWithTitle: LocalizedText(@"Passcode Required",nil) message: LocalizedText(@"Enter Passcode to Login",nil) container:self cancelButtonTitle: LocalizedText(@"Forgot Passcode",nil) otherButtonTitles: LocalizedText(@"OK",nil),nil];
    }
}

-(void) viewWillDisappear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO];
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

