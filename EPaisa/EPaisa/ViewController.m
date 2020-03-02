//
//  ViewController.m
//  EPaisa
//
//  Created by subbu on 06/08/14.
//  Copyright (c) 2014 subbu. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "HomeViewController.h"

@interface ViewController () <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource>
{
    AppDelegate *appDelegate;
    UITextField *activeField;
    Reachability *internetReachability;
    BOOL isInternetReachable, isLanguageSelection, isBackgroundSelection;
}

@property(nonatomic,retain) IBOutlet UIButton *languageSelectionButton;
@property(nonatomic,retain) IBOutlet UIImageView *arrowImage;
@property(strong, nonatomic) IBOutlet UILabel *languageLabel;
@property(nonatomic,retain) IBOutlet UIButton *backgroundSelectionButton;
@property(nonatomic,retain) IBOutlet UIImageView *dropdownImage;
@property(strong, nonatomic) IBOutlet UILabel *bgLabel;


@property(nonatomic,retain)UITableView *tableView;
@property(nonatomic,retain)NSMutableArray *languageArray, *backgroundColorArray;
@property(nonatomic,retain)NSString *languageSelected, *backgroundSelected;


@property (weak, nonatomic) IBOutlet UIView *fieldsHoldingView;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UILabel *rememberMeLabel;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *bScrollView;

@property (weak, nonatomic) IBOutlet UISwitch *rememberUserSwitch;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loginActivityIndicator;

- (IBAction)rememberUserCilcked:(id)sender;
- (IBAction)loginClicked:(id)sender;
- (IBAction)languageButtonAction:(id)sender;
- (void)arrowSetter:(BOOL)direction;
- (IBAction)backgroundButtonAction:(id)sender;
- (void)hideKeyboard;



@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    self.navigationController.navigationBar.hidden = YES;

    
    _languageArray = [[NSMutableArray alloc]initWithObjects:[[LocalizationHelper defaultLocalizationHelper] languageSelectedStringForKey:@"English"],[[LocalizationHelper defaultLocalizationHelper] languageSelectedStringForKey:@"Spanish"],nil];
    
    _backgroundColorArray = [[NSMutableArray alloc]initWithObjects:[[LocalizationHelper defaultLocalizationHelper] languageSelectedStringForKey:@"blueColor"],[[LocalizationHelper defaultLocalizationHelper] languageSelectedStringForKey:@"grayColor"],nil];

    
    if(self.languageSelected == NULL)
        self.languageSelected = [[LocalizationHelper defaultLocalizationHelper] languageSelectedStringForKey:@"English"];
    
    self.languageLabel.text = [NSString stringWithFormat:@"Language: %@",self.languageSelected];
    
    //To check user's language preference settings
    if ([[NSUserDefaults standardUserDefaults]valueForKey:@"selectedLanguage"])
    {
        self.languageLabel.text = [NSString stringWithFormat:@"Language: %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"selectedLanguage"]];
    }
    
    [[LocalizationHelper defaultLocalizationHelper] selectedLanguageWithString:self.languageSelected];
    
    if(self.backgroundSelected == NULL)
        self.backgroundSelected = [[LocalizationHelper defaultLocalizationHelper] languageSelectedStringForKey:@"White"];
    
    self.bgLabel.text = [NSString stringWithFormat:@"BG Color: %@",self.backgroundSelected];
    
    //To check user's language preference settings
    if ([[NSUserDefaults standardUserDefaults]valueForKey:@"selectedBackgroundColor"])
    {
        self.bgLabel.text = [NSString stringWithFormat:@"BG Color: %@",[[NSUserDefaults standardUserDefaults]objectForKey:@"selectedBackgroundColor"]];
    }
    
    [[LocalizationHelper defaultLocalizationHelper] selectedLanguageWithString:self.backgroundSelected];


    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    self.userNameTextField.text = [appDelegate.keyChainAccess objectForKey:(__bridge id)kSecAttrAccount];
    if ([self.userNameTextField.text isEqualToString:@""] || (self.userNameTextField.text == nil)) {
        self.rememberUserSwitch.on = NO;
    }else{
        self.rememberUserSwitch.on = YES;
    }
    self.passwordTextField.text = @"";

    [self setTextToComponents];

}

/*****************************************************************************************
 Method Name:   setTextToComponents
 Description:   method for general Spanish - English Conversion
 Parameters:    -
 *****************************************************************************************/
-(void) setTextToComponents
{
    [self.userNameLabel setText:[[LocalizationHelper defaultLocalizationHelper] languageSelectedStringForKey:@"User Name"]];
    [self.passwordLabel setText:[[LocalizationHelper defaultLocalizationHelper] languageSelectedStringForKey:@"Password"]];
    [self.rememberMeLabel setText:[[LocalizationHelper defaultLocalizationHelper] languageSelectedStringForKey:@"Remember User Name"]];


    
    [self.userNameTextField setPlaceholder:[[LocalizationHelper defaultLocalizationHelper] languageSelectedStringForKey:@"Enter your User Name"]];
    [self.passwordTextField setPlaceholder:[[LocalizationHelper defaultLocalizationHelper] languageSelectedStringForKey:@"Enter your Password"]];
    
    
    [self.loginButton setTitle:[[LocalizationHelper defaultLocalizationHelper] languageSelectedStringForKey:@"Login"] forState:UIControlStateNormal];
    
    //Buffer Variable to update language selection label
    NSString *str = [NSString stringWithFormat:@"Language: %@",self.languageSelected];
    
    [self.languageLabel setText:[[LocalizationHelper defaultLocalizationHelper] languageSelectedStringForKey:str]];
    
    _languageArray = [[NSMutableArray alloc]initWithObjects:[[LocalizationHelper defaultLocalizationHelper] languageSelectedStringForKey:@"English"],[[LocalizationHelper defaultLocalizationHelper] languageSelectedStringForKey:@"Spanish"],nil];
    
    
}



-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

#pragma mark UITextField methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    activeField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    activeField = nil;
}

#pragma mark KeyBoard methods

- (void)keyboardWasShown:(NSNotification *)notification
{
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    _bScrollView.contentInset = contentInsets;
    _bScrollView.scrollIndicatorInsets = contentInsets;
    CGRect aRect = _bScrollView.frame;
    aRect.size.height -= keyboardSize.height;
    if (!CGRectContainsPoint(aRect, activeField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, CGRectGetMaxY(activeField.frame));
        [_bScrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void) keyboardWillHide:(NSNotification *)notification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    _bScrollView.contentInset = contentInsets;
    _bScrollView.scrollIndicatorInsets = contentInsets;
}

- (IBAction)loginClicked:(id)sender {
    if ([self.userNameTextField.text isEqualToString:@""]||self.userNameTextField.text == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"UserName field is Empty." message:@"Enter a valid User Name" delegate:nil cancelButtonTitle:@"Ok"otherButtonTitles:nil, nil];
        [alert show];
    }
    else if ([self.passwordTextField.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password field Empty!" message:@"Enter a valid Password" delegate:nil cancelButtonTitle:@"Ok"otherButtonTitles:nil, nil];
        [alert show];

    }
    else {
        internetReachability = [Reachability reachabilityForInternetConnection];
        [internetReachability startNotifier];
        [self internetReachabilityChanged];
        if (isInternetReachable) {
//            [NSThread detachNewThreadSelector:@selector(startAnimating) toTarget:_loginActivityIndicator withObject:_loginActivityIndicator];
            [_loginActivityIndicator startAnimating];

            [self.userNameTextField resignFirstResponder];
            [self.passwordTextField resignFirstResponder];
            if (([self.userNameTextField.text isEqualToString:@"admin@epaisa.com"]) && ([self.passwordTextField.text isEqualToString:@"123123"]))
            {
                NSLog(@"\n Login Success");
               [self performSegueWithIdentifier:@"HomeSegue" sender:self];
                [_loginActivityIndicator stopAnimating];
            }
            else
            {
                [_loginActivityIndicator stopAnimating];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login failed!" message:@"Wrong User Name/Password" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                [alert show];
                self.passwordTextField.text = @"";
            }
        }
    }
}

- (IBAction)rememberUserCilcked:(id)sender {
    UISwitch *localRememberSwitch = sender;
    if (localRememberSwitch.on == YES) {
        if (self.userNameTextField.text) {
            [appDelegate.keyChainAccess setObject:self.userNameTextField.text forKey:(__bridge id)kSecAttrAccount];
        }
        if ([self.userNameTextField.text isEqualToString:@""]||self.userNameTextField.text == nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"User Name field is Empty." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            localRememberSwitch.on = NO;
        }
    }
    else{
        if (self.userNameTextField.text) {
            [appDelegate.keyChainAccess setObject:@"" forKey:(__bridge id)kSecAttrAccount];
        }
        [self viewWillAppear:YES];
    }
}

#pragma mark -- Reachability changed notification

- (void)internetReachabilityChanged{
    NetworkStatus currentStatus = [internetReachability currentReachabilityStatus];
    if ((currentStatus == ReachableViaWiFi) || (currentStatus == ReachableViaWWAN)) {
        isInternetReachable = YES;
    }
    else if(currentStatus == NotReachable){
        isInternetReachable = NO;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Unable to connect !" message:@"Please check your Internet connectivity" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"HomeSegue"])
    {
        
    }
}


#pragma mark Button Click Methods
/*****************************************************************************************
 Method Name:   languageButtonAction
 Description:   Called when the Language Button is Clicked
 Parameters:    1. Calling object
 *****************************************************************************************/
- (IBAction)languageButtonAction:(id)sender
{
    [self hideKeyboard];
    isBackgroundSelection = NO;
	isLanguageSelection = YES;
    [self arrowSetter:YES];
    [self.tableView removeFromSuperview];
	CGRect frame3 = CGRectMake(36,310,253,122);
	[self reloadTableView:(CGRect)frame3];
	[self.view addSubview:self.tableView];
	[self.tableView reloadData];

}
-(void)reloadTableView:(CGRect)frame
{
	
	self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.backgroundColor = [UIColor colorWithRed:0.972 green:0.968 blue:0.951 alpha:1.0];
	self.tableView.rowHeight = 45;
	[self.tableView setSectionHeaderHeight:0];
	[self.tableView setSectionFooterHeight:0];
	self.tableView.hidden = NO;
	
}
/*****************************************************************************************
 Method Name:   backgroundButtonAction
 Description:   Called when the Background Button is Clicked
 Parameters:    1. Calling object
 *****************************************************************************************/
- (IBAction)backgroundButtonAction:(id)sender
{
    [self hideKeyboard];
    isBackgroundSelection = YES;
	isLanguageSelection = NO;
    [self arrowSetter:YES];
    [self.tableView removeFromSuperview];
	CGRect frame3 = CGRectMake(36,365,253,122);
	[self reloadTableView:(CGRect)frame3];
	[self.view addSubview:self.tableView];
	[self.tableView reloadData];
    
}

# pragma mark
# pragma mark TableView Delegate Methods
/*****************************************************************************************
 Method Name:   numberOfSectionsInTableView
 Description:   TableView Delegate for Section count
 Parameters:    1. tableView
 *****************************************************************************************/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/*****************************************************************************************
 Method Name:   numberOfRowsInSection
 Description:   TableView Delegate for Row count
 Parameters:    1. tableView
 2. section
 *****************************************************************************************/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(isLanguageSelection == YES)
	{
		
		return [_languageArray count];
	}
	else if(isBackgroundSelection == YES)
	{
		return [_backgroundColorArray count];
	}
	
	return 1;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 30;
}


/*****************************************************************************************
 Method Name:   cellForRowAtIndexPath
 Description:   TableView Delegate for loading cell contents
 Parameters:    1. tableView
 2. indexPath
 *****************************************************************************************/
- (UITableViewCell *)tableView:(UITableView *)ptableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [ptableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell=[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
    }
    if(isLanguageSelection == YES)
	
        cell.textLabel.text =[_languageArray objectAtIndex:indexPath.row];
    else if(isBackgroundSelection == YES)
        cell.textLabel.text =[_backgroundColorArray objectAtIndex:indexPath.row];

    
    cell.textLabel.textColor = [UIColor blackColor];
    
    return cell;
}

/*****************************************************************************************
 Method Name:   didSelectRowAtIndexPath
 Description:   TableView Delegate for actions after selecting row
 Parameters:    1. tableView
 2. indexPath
 *****************************************************************************************/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [self.tableView removeFromSuperview];
    
    [self arrowSetter:NO];
    if (isLanguageSelection)
    {
        self.languageSelected = [[LocalizationHelper defaultLocalizationHelper] languageSelectedStringForKey:[self.languageArray objectAtIndex:indexPath.row]];
    
        self.languageLabel.text = [NSString stringWithFormat:@"Language: %@",self.languageSelected];
    
        [[LocalizationHelper defaultLocalizationHelper] selectedLanguageWithString:self.languageSelected];
        
        [[NSUserDefaults standardUserDefaults] setValue:self.languageSelected forKey:@"selectedLanguage"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else if(isBackgroundSelection == YES){
       
         self.backgroundSelected = [[LocalizationHelper defaultLocalizationHelper] languageSelectedStringForKey:[self.backgroundColorArray objectAtIndex:indexPath.row]];
        self.bgLabel.text = [NSString stringWithFormat:@"BG Color: %@",self.backgroundSelected];
        [[LocalizationHelper defaultLocalizationHelper] selectedLanguageWithString:self.backgroundSelected];
        
        [[NSUserDefaults standardUserDefaults] setValue:self.backgroundSelected forKey:@"selectedBackgroundColor"];
        
        [[NSUserDefaults standardUserDefaults] synchronize];

        
    }
    
    [self setTextToComponents];
    
}

/*****************************************************************************************
 Method Name:   hideKeyboard
 Description:   Method to dismiss keyboard on touch event
 Parameters:    -
 *****************************************************************************************/
-(void)hideKeyboard{
    [self touchesEnded:nil withEvent:nil];
}

/*****************************************************************************************
 Method Name:   touchesEnded
 Description:   Detects touches on the screen to remove the keyboard
 Parameters:    1. touches(NSSet)
 2. event(UIEvent)
 *****************************************************************************************/
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.userNameTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    //hide keyboard on touch of screen
}

/*****************************************************************************************
 Method Name:   arrowSetter
 Description:   Method to set language dropdown arrow => parameters "Yes" for arrow up
 and "No" for arrow down
 Parameters:    1. direction
 *****************************************************************************************/
-(void)arrowSetter:(BOOL)direction{
    NSString *imagePath;
    if(direction == YES)
        imagePath = [[NSBundle mainBundle] pathForResource:@"arrow_up_blue_round" ofType:@"png"];
    else
        imagePath = [[NSBundle mainBundle] pathForResource:@"arrow_down_blue_round" ofType:@"png"];
    if(isLanguageSelection == YES)
        [self.arrowImage setImage:[UIImage imageWithContentsOfFile:imagePath]];
    else if(isBackgroundSelection == YES)
        [self.dropdownImage setImage:[UIImage imageWithContentsOfFile:imagePath]];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
