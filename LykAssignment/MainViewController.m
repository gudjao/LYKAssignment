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
        
        self.googleButtonNode = [[ASDisplayNode alloc] initWithViewBlock:^UIView * _Nonnull{
            GIDSignInButton *googleSigninButton = [[GIDSignInButton alloc] initWithFrame:CGRectZero];
            return googleSigninButton;
        }];
        
        self.node.layoutSpecBlock = ^ASLayoutSpec * _Nonnull(__kindof ASDisplayNode * _Nonnull node, ASSizeRange constrainedSize) {
            
            weakSelf.fbLoginButtonNode.style.height = ASDimensionMake(40.0f);
            weakSelf.fbLoginButtonNode.style.maxWidth = ASDimensionMake(280.0f);
            
            weakSelf.googleButtonNode.style.height = ASDimensionMake(40.0f);
            weakSelf.googleButtonNode.style.maxWidth = ASDimensionMake(280.0f);
            
            ASStackLayoutSpec *stackButtons = [ASStackLayoutSpec
                                               stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical
                                               spacing:15.0f
                                               justifyContent:ASStackLayoutJustifyContentCenter
                                               alignItems:ASStackLayoutAlignItemsCenter
                                               children:@[weakSelf.fbLoginButtonNode,
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
    
    // Google
    GIDSignIn *signIn = [GIDSignIn sharedInstance];
    NSLog(@"Current scopes: %@", signIn.scopes);
    signIn.scopes = @[@"https://www.googleapis.com/auth/contacts",
                      @"https://www.googleapis.com/auth/contacts.readonly",
                      @"https://www.googleapis.com/auth/plus.circles.read",
                      @"https://www.googleapis.com/auth/plus.me",
                      @"https://www.googleapis.com/auth/plus.profile.emails.read",
                      @"https://www.googleapis.com/auth/plus.login"];
    
    signIn.uiDelegate = self;
    signIn.delegate = self;
    
    // Facebook
    if ([FBSDKAccessToken currentAccessToken]) {
        //[self goListVC];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    self.navigationController.navigationBar.hidden = YES;
}

#pragma mark - FBSDKLoginButtonDelegate

- (void)loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
              error:(NSError *)error {
    if(error) {
        return;
    }
    
    [self goListVC];
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton {
    
}

#pragma mark - GIDSignInDelegate

- (void)signIn:(GIDSignIn *)signIn
didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    if(error) {
        return;
    }
    
    [self goListVC];
}

- (void)signIn:(GIDSignIn *)signIn
didDisconnectWithUser:(GIDGoogleUser *)user
     withError:(NSError *)error {
    
}

#pragma mark - GIDSignInUIDelegate

// pressed the Sign In button
- (void)signInWillDispatch:(GIDSignIn *)signIn error:(NSError *)error {
    
}

// Present a view that prompts the user to sign in with Google
- (void)signIn:(GIDSignIn *)signIn
presentViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

// Dismiss the "Sign in with Google" view
- (void)signIn:(GIDSignIn *)signIn
dismissViewController:(UIViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
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
