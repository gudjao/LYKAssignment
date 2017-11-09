//
//  MainViewController.m
//  LykAssignment
//
//  Created by Juston Paul Alcantara on 07/11/2017.
//  Copyright © 2017 Juston Paul Alcantara. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (instancetype)init {
    ASDisplayNode *node = [[ASDisplayNode alloc] init];
    node.backgroundColor = [UIColor flatWhiteColor];
    self = [super initWithNode:node];
    if(self) {
        // Config
        self.node.automaticallyManagesSubnodes = YES;
        
        // weak reference
        __weak typeof(self) weakSelf = self;
        
        // FB Login Button
        self.fbLoginButtonNode = [[ASDisplayNode alloc] initWithViewBlock:^UIView * _Nonnull{
            FBSDKLoginButton *fbLoginButton = [[FBSDKLoginButton alloc] initWithFrame:CGRectZero];
            fbLoginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
            fbLoginButton.delegate = weakSelf;
            fbLoginButton.loginBehavior = FBSDKLoginBehaviorNative;
            return fbLoginButton;
        }];
        
        /*
         self.googleButtonNode = [[ASDisplayNode alloc] initWithViewBlock:^UIView * _Nonnull{
         GIDSignInButton *googleSigninButton = [[GIDSignInButton alloc] initWithFrame:CGRectZero];
         [googleSigninButton setSelected:1];
         return googleSigninButton;
         }];
         */
        
        self.googleButtonNode = [[ASButtonNode alloc] init];
        [self.googleButtonNode setTitle:@"Login with Google"
                               withFont:[UIFont systemFontOfSize:14.0f]
                              withColor:[UIColor flatGrayColorDark]
                               forState:UIControlStateNormal];
        self.googleButtonNode.backgroundColor = [UIColor whiteColor];
        self.googleButtonNode.hitTestSlop = UIEdgeInsetsMake(-5, -10, -5, -10);
        self.googleButtonNode.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
        self.googleButtonNode.cornerRadius = 4.0f;
        [self.googleButtonNode addTarget:self
                                  action:@selector(googleSignIn:)
                        forControlEvents:ASControlNodeEventTouchUpInside];
        [self.googleButtonNode setImage:[UIImage as_imageNamed:@"google-icon"]
                               forState:UIControlStateNormal];
        
        self.continueButtonNode = [[ASButtonNode alloc] init];
        [self.continueButtonNode setTitle:@"Click here to continue..."
                                 withFont:[UIFont boldSystemFontOfSize:15.0f]
                                withColor:[UIColor flatNavyBlueColor]
                                 forState:UIControlStateNormal];
        self.continueButtonNode.hitTestSlop = UIEdgeInsetsMake(-5, -10, -5, -10);
        self.continueButtonNode.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10);
        self.continueButtonNode.cornerRadius = 4.0f;
        [self.continueButtonNode addTarget:self
                                    action:@selector(goListVC)
                          forControlEvents:ASControlNodeEventTouchUpInside];
        
        self.node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
            
            weakSelf.continueButtonNode.style.height = ASDimensionMake(48.0f);
            weakSelf.continueButtonNode.style.width = ASDimensionMake(240.0f);
            weakSelf.continueButtonNode.style.spacingAfter = 60.0f;
            
            weakSelf.fbLoginButtonNode.style.height = ASDimensionMake(48.0f);
            weakSelf.fbLoginButtonNode.style.width = ASDimensionMake(240.0f);
            
            weakSelf.googleButtonNode.style.height = ASDimensionMake(48.0f);
            weakSelf.googleButtonNode.style.width = ASDimensionMake(240.0f);
            
            ASStackLayoutSpec *stackButtons = [ASStackLayoutSpec
                                               stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical
                                               spacing:15.0f
                                               justifyContent:ASStackLayoutJustifyContentCenter
                                               alignItems:ASStackLayoutAlignItemsCenter
                                               children:@[weakSelf.continueButtonNode,
                                                          weakSelf.fbLoginButtonNode,
                                                          weakSelf.googleButtonNode]];
            
            return [ASCenterLayoutSpec centerLayoutSpecWithCenteringOptions:ASCenterLayoutSpecCenteringXY
                                                              sizingOptions:ASCenterLayoutSpecSizingOptionDefault
                                                                      child:stackButtons];
        };
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // ProgressHUD
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    
    // Google
    [GIDSignIn sharedInstance].scopes = @[@"https://www.googleapis.com/auth/contacts",
                                          @"https://www.googleapis.com/auth/contacts.readonly",
                                          @"https://www.googleapis.com/auth/plus.circles.read",
                                          @"https://www.googleapis.com/auth/plus.me",
                                          @"https://www.googleapis.com/auth/plus.profile.emails.read",
                                          @"https://www.googleapis.com/auth/plus.login"];
    
    [GIDSignIn sharedInstance].uiDelegate = self;
    [GIDSignIn sharedInstance].delegate = self;
    
    [[GIDSignIn sharedInstance] signInSilently];
    
    [self checkLogin];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    self.navigationController.navigationBar.hidden = YES;
}

#pragma mark - Login checker

- (void)checkLogin {
    
    BOOL goodTogo = 0;
    
    if([[GIDSignIn sharedInstance] currentUser]) {
        NSLog(@"Google user: %@", [[GIDSignIn sharedInstance] currentUser].userID);
        
        [OneSignal sendTags:@{ @"lykKeyGoogle" : [[GIDSignIn sharedInstance] currentUser].userID }
                  onSuccess:^(NSDictionary *result) {
                      NSLog(@"Success google push notification!");
                  } onFailure:^(NSError *error) {
                      NSLog(@"Error - %@", error.localizedDescription);
                  }];
        goodTogo = 1;
    }
    
    if([FBSDKAccessToken currentAccessToken]) {
        [OneSignal sendTags:@{ @"lykKeyFacebook" : [FBSDKAccessToken currentAccessToken].userID }
                  onSuccess:^(NSDictionary *result) {
                      NSLog(@"Success facebook push notification!");
                  } onFailure:^(NSError *error) {
                      NSLog(@"Error - %@", error.localizedDescription);
                  }];
        goodTogo = 1;
    }
    
    if(goodTogo) {
        [self.continueButtonNode setTitle:@"Click here to continue..."
                                 withFont:[UIFont boldSystemFontOfSize:15.0f]
                                withColor:[UIColor flatNavyBlueColor]
                                 forState:UIControlStateNormal];
        self.continueButtonNode.enabled = 1;
    } else {
        [self.continueButtonNode setTitle:@"Please login with Facebook or Google..."
                                 withFont:[UIFont boldSystemFontOfSize:15.0f]
                                withColor:[UIColor flatGrayColorDark]
                                 forState:UIControlStateNormal];
        self.continueButtonNode.enabled = 0;
    }
    
    [self.node setNeedsLayout];
}

#pragma mark - FBSDKLoginButtonDelegate

- (void)loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
              error:(NSError *)error {
    [self checkLogin];
    
    if(error) {
        return;
    }
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    [self checkLogin];
}

#pragma mark - GIDSignInDelegate

- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    [self checkLogin];
    
    if(error) {
        return;
    }
    
    [self.googleButtonNode setTitle:@"Logout Google"
                           withFont:[UIFont systemFontOfSize:14.0f]
                          withColor:[UIColor flatGrayColorDark]
                           forState:UIControlStateNormal];
    
    [self.node setNeedsLayout];
    [SVProgressHUD dismiss];
}

- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    [self checkLogin];
    
    if(error) {
        return;
    }
    
    [self.googleButtonNode setTitle:@"Login with Google"
                           withFont:[UIFont systemFontOfSize:14.0f]
                          withColor:[UIColor flatGrayColorDark]
                           forState:UIControlStateNormal];
    
    [SVProgressHUD dismiss];
}

#pragma mark - GIDSignInUIDelegate

- (void)googleSignIn:(ASButtonNode *)button {
    [SVProgressHUD show];
    if ([GIDSignIn sharedInstance].currentUser) {
        [[GIDSignIn sharedInstance] disconnect];
    } else {
        [[GIDSignIn sharedInstance] signIn];
    }
}

// pressed the Sign In button
- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error {
    [SVProgressHUD dismiss];
}

// Present a view that prompts the user to sign in with Google
- (void)signIn:(GIDSignIn *)signIn
presentViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

// Dismiss the "Sign in with Google" view
- (void)signIn:(GIDSignIn *)signIn
dismissViewController:(UIViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:^{
        [self checkLogin];
    }];
}

#pragma mark - Push to list vc

- (void)goListVC {
    ListViewController *listVC = [[ListViewController alloc] init];
    [self.navigationController pushViewController:listVC
                                         animated:YES];
}

#pragma mark - Memory Warning

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
