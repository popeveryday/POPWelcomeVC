//
//  POPWelcomeVC.h
//  Pods
//
//  Created by Trung Pham Hieu on 4/4/16.
//
//

#import <UIKit/UIKit.h>

@import MessageUI;

@interface POPWelcomeVC : UIViewController

@property (nonatomic) NSString* passcode; //required
@property (nonatomic) NSString* recoveryEmail; //required
@property (nonatomic) UIImage* logoImage; //required
@property (nonatomic) UIImage* logoIphone;
@property (nonatomic) NSString* segueID; //required
@property (nonatomic) NSString* senderEmailAddress; //required

@property (nonatomic) NSString* customEmailTitle;
@property (nonatomic) NSString* emailAppName; //required

@property (nonatomic) NSString* customEmailBody;
@property (nonatomic) NSString* emailContactWebsite; //required
@property (nonatomic) NSString* emailSenderName; //required

@property (nonatomic) BOOL isUsingTouchId;
@property (nonatomic) NSData* touchDataState;
@property (nonatomic) void (^touchDataStateChangedBlock)(BOOL beforeInputPasscode);


@property (nonatomic) BOOL isRequireInternet;

-(void) reloadWelcomeScreen;
-(void) forwardToMainView;

+(void)checkEmailExist:(NSString*)email appName:(NSString*)appName sender:(NSString*)sender senderEmail:(NSString*)senderEmail fromViewController:(UIViewController*)vc completeBlock:(void (^)(BOOL result)) completeBlock;

@end
