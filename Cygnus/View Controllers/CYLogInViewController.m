//
//  CYLogInViewController.m
//  Cygnus
//
//  Created by Juan-Carlos Foust on 10/28/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYLogInViewController.h"
#import <SSToolkit/SSHUDView.h>
#import <SSToolkit/SSCategories.h>

#import "CYUser.h"

typedef enum
{
  CYSignUpState_Login,
  CYSignUpState_CreateAccount
} CYSignUpState;


@interface CYLogInViewController () <UITextFieldDelegate>

@property (strong, nonatomic)        UIWindow *window;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *logInButton;
@property (weak, nonatomic) IBOutlet UIButton *createAccountButton;
@property (strong, nonatomic)        SSHUDView *HUDActivityView;
@property (nonatomic)                CYSignUpState currentState;


@end

@implementation CYLogInViewController

- (IBAction)switchState {
  if (self.currentState == CYSignUpState_Login) {
    [self.firstNameTextField fadeIn];
    [self.lastNameTextField fadeIn];
    [self.emailTextField fadeIn];
    
    [self.logInButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    [self.createAccountButton setTitle:@"Go Back" forState:UIControlStateNormal];
    self.currentState = CYSignUpState_CreateAccount;
    
  } else {
    [self.firstNameTextField fadeOut];
    [self.lastNameTextField fadeOut];
    [self.emailTextField fadeOut];
    
    [self.logInButton setTitle:@"Log In" forState:UIControlStateNormal];
    [self.createAccountButton setTitle:@"Create Account" forState:UIControlStateNormal];
    self.currentState = CYSignUpState_Login;
  }

}

#pragma mark - UITextFieldDelegate


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
  if (textField == self.usernameTextField) {
    if ([textField.text length]) {
      [self.passwordTextField becomeFirstResponder];
      return YES;
    } else {
      return NO;
    }
  } else if (textField == self.passwordTextField)  {
    if ([textField.text length]) {
      if (self.currentState == CYSignUpState_Login) {
        [self releaseFirstResponders];
        [self userDidAttemptLogIn];
      } else {
        [self.firstNameTextField becomeFirstResponder];
      }
      return YES;
    } else {
      return NO;
    }
  } else if (textField == self.firstNameTextField)  {
    if ([textField.text length]) {
      [self.lastNameTextField becomeFirstResponder];
      return YES;
    } else {
      return NO;
    }
  } else if (textField == self.lastNameTextField)  {
    if ([textField.text length]) {
      [self.emailTextField becomeFirstResponder];
      return YES;
    } else {
      return NO;
    }
  } else if (textField == self.emailTextField)  {
    if ([textField.text length]) {
      [self releaseFirstResponders];
      [self userDidAttemptLogIn];
      return YES;
    } else {
      return NO;
    }
  } else {
    return YES;
  }
}

#pragma mark - Actions

- (IBAction)userDidAttemptLogIn {
  
  if (![self.usernameTextField.text length]) {
    [self.usernameTextField becomeFirstResponder];
    return;
  } else if (![self.passwordTextField.text length]) {
    [self.passwordTextField becomeFirstResponder];
    return;
  }
  
  if (self.currentState == CYSignUpState_CreateAccount) {
    if (![self.firstNameTextField.text length]) {
      [self.firstNameTextField becomeFirstResponder];
      return;
    } else if (![self.lastNameTextField.text length]) {
      [self.lastNameTextField becomeFirstResponder];
      return;
    } else if (![self.emailTextField.text length]) {
      [self.emailTextField becomeFirstResponder];
      return;
    } 
  }

  self.HUDActivityView = [[SSHUDView alloc] initWithTitle:nil loading:YES];
  [self.HUDActivityView show];
  
  if (self.currentState == CYSignUpState_Login) {
    [CYUser logInWithUsernameInBackground:self.usernameTextField.text
                                 password:self.passwordTextField.text
                                    block:^(BOOL succeeded, NSError *error) {
                                      if (succeeded) {
                                        [self.HUDActivityView completeAndDismissWithTitle:nil];
                                        [self dismiss];
                                      } else {
                                        [self.HUDActivityView failAndDismissWithTitle:nil];
                                      }
    }];
    
  } else {
    CYUser *newUser = [CYUser userWithUsername:self.usernameTextField.text password:self.passwordTextField.text];
    newUser.firstName = self.firstNameTextField.text;
    newUser.lastName = self.lastNameTextField.text;
    newUser.email = self.emailTextField.text;
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
      if (succeeded) {
        [self.HUDActivityView completeAndDismissWithTitle:nil];
        [self dismiss];
      } else {
        [self.HUDActivityView failAndDismissWithTitle:nil];
      }
    }];
  }
}

- (void)releaseFirstResponders
{
  [self.usernameTextField resignFirstResponder];
  [self.passwordTextField resignFirstResponder];
  [self.firstNameTextField resignFirstResponder];
  [self.lastNameTextField resignFirstResponder];
  [self.emailTextField resignFirstResponder];
}


#pragma mark - VC Lifecycle

- (void)dismiss
{
  __block UIWindow *window = _window;
  [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationCurveEaseIn animations:^() {
    window.alpha = 0.0;
  } completion:^(BOOL finished) {
    window.hidden = YES;
    window = nil;
  }];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.currentState = CYSignUpState_Login;
  
  self.usernameTextField.delegate = self;
  self.passwordTextField.delegate = self;
  self.firstNameTextField.delegate = self;
  self.lastNameTextField.delegate = self;
  self.emailTextField.delegate = self;

  [self.firstNameTextField hide];
  [self.lastNameTextField hide];
  [self.emailTextField hide];
  
  UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(releaseFirstResponders)];
  [self.view addGestureRecognizer:tgr];
}

- (void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [self.window makeKeyWindow];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (void)present
{
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
  CYLogInViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"CYLogInViewController"];
  
  vc.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  vc.window.rootViewController = vc;
  vc.window.windowLevel = UIWindowLevelAlert;
  [vc.window makeKeyAndVisible];
  
}

@end
