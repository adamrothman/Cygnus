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
  CYSignUpState_Login = 0,
  CYSignUpState_CreateAccount = 1,
} CYSignUpState;


UIWindow *_window = nil;

@interface CYLogInViewController () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameFieldField;
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
    [self.lastNameFieldField fadeIn];
    [self.emailTextField fadeIn];
    
    [self.logInButton setTitle:@"Sign Up" forState:UIControlStateNormal];
    [self.createAccountButton setTitle:@"Go Back" forState:UIControlStateNormal];
    self.currentState = CYSignUpState_CreateAccount;
    
  } else {
    [self.firstNameTextField fadeOut];
    [self.lastNameFieldField fadeOut];
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
      [self.lastNameFieldField becomeFirstResponder];
      return YES;
    } else {
      return NO;
    }
  } else if (textField == self.lastNameFieldField)  {
    if ([textField.text length]) {
      [self.emailTextField becomeFirstResponder];
      return YES;
    } else {
      return NO;
    }
  } else if (textField == self.emailTextField)  {
    if ([textField.text length]) {
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
    } else if (![self.lastNameFieldField.text length]) {
      [self.lastNameFieldField becomeFirstResponder];
      return;
    } else if (![self.emailTextField.text length]) {
      [self.emailTextField becomeFirstResponder];
      return;
    } 
  }

  self.HUDActivityView = [[SSHUDView alloc] initWithTitle:nil loading:YES];
  [self.HUDActivityView show];
  
  if (self.currentState == CYSignUpState_Login) {
    //attempt login on CYUser
  } else {
    // atempt acount creation CYUser
    
    CYUser *newUser = [CYUser init];
    
  }

}

- (void)releaseFirstResponders
{
  [self.usernameTextField resignFirstResponder];
  [self.passwordTextField resignFirstResponder];
  [self.firstNameTextField resignFirstResponder];
  [self.lastNameFieldField resignFirstResponder];
  [self.emailTextField resignFirstResponder];
}


#pragma mark - VC Lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.currentState = CYSignUpState_Login;
  
  self.usernameTextField.delegate = self;
  self.passwordTextField.delegate = self;
  self.firstNameTextField.delegate = self;
  self.lastNameFieldField.delegate = self;
  self.emailTextField.delegate = self;

  [self.firstNameTextField hide];
  [self.lastNameFieldField hide];
  [self.emailTextField hide];
  
  UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                        action:@selector(releaseFirstResponders)];
  [self.view addGestureRecognizer:tgr];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

+ (void)present
{
  UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
  UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"CYLogInViewController"];
  
  _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  _window.rootViewController = vc;
  _window.windowLevel = UIWindowLevelAlert;
  [_window makeKeyAndVisible];
  
}

@end
