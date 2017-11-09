//
//  MainViewController.h
//  LykAssignment
//
//  Created by Juston Paul Alcantara on 07/11/2017.
//  Copyright © 2017 Juston Paul Alcantara. All rights reserved.
//

#import <AsyncDisplayKit/AsyncDisplayKit.h>
#import <ChameleonFramework/Chameleon.h>
#import <SVProgressHUD/SVProgressHUD.h>

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

#import <GoogleSignIn/GoogleSignIn.h>
#import <GTLRGmail.h>

#import "ListViewController.h"

@interface MainViewController : ASViewController <FBSDKLoginButtonDelegate, GIDSignInDelegate, GIDSignInUIDelegate>

@property (strong, nonatomic) ASButtonNode *continueButtonNode;

@property (strong, nonatomic) ASDisplayNode *fbLoginButtonNode;
@property (strong, nonatomic) ASButtonNode *googleButtonNode;
//@property (strong, nonatomic) ASDisplayNode *googleButtonNode;

@end
