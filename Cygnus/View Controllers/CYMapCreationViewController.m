//
//  CYMapCreationViewController.m
//  Cygnus
//
//  Created by Juan-Carlos Foust on 11/14/12.
//  Copyright (c) 2012 Cygnus. All rights reserved.
//

#import "CYMapCreationViewController.h"

@interface CYMapCreationViewController ()

@end

@implementation CYMapCreationViewController

- (IBAction)cancel:(id)sender {
  [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


+ (QRootElement *)rootElement
{
  QRootElement *root = [[QRootElement alloc] init];
  root.title = @"Create";
  root.controllerName = @"CYMapCreationViewController";
  root.grouped = YES;
  
  //Will load from JSON similar to point schema (eventually). But for now.
  
  /* Title */
  QEntryElement *mapTitleElement = [[QEntryElement alloc] initWithTitle:nil Value:nil Placeholder:@"Map Title"];
  mapTitleElement.key = @"title";
  QSection *titleSection = [[QSection alloc] init];
  [titleSection addElement:mapTitleElement];
  
  /* Description (Summary) */
  QMultilineElement *mapSummary = [QMultilineElement new];
  mapSummary.title = @"Description";
  mapSummary.key = @"summary";
  QSection *descriptionSection = [[QSection alloc] init];
  [descriptionSection addElement:mapSummary];
  
  QSection *schemaSection = [[QSection alloc] initWithTitle:@"Map item requirements (demo)"];
  [schemaSection addElement:[[QLabelElement alloc] initWithTitle:@"Name" Value:@"Text"]];
  [schemaSection addElement:[[QLabelElement alloc] initWithTitle:@"Description" Value:@"Text"]];
  QPickerElement *requiredFieldCount = [[QPickerElement alloc]
                                        initWithTitle:@"Number of fields"
                                        items:@[[@"1 2 3 4 5" componentsSeparatedByString:@" "]]
                                        value:@"1"];
  [schemaSection addElement:requiredFieldCount];
  
  QSection *demoPinSection = [[QSection alloc] initWithTitle:@"Example field specification"];
  [demoPinSection addElement:[[QEntryElement alloc] initWithTitle:nil Value:nil Placeholder:@"Field name"]];
  [demoPinSection addElement:[[QRadioElement alloc] initWithDict:[NSDictionary dictionaryWithObjectsAndKeys:@"QElementClass", @"Text", @"QElementClass", @"YES/NO", @"QElementClass", @"Paragraph", @"QElementClass", @"Number", @"QElementClass", @"Date",@"QElementClass", @"URL",@"QElementClass", @"Number",@"QElementClass", @"Radio with options", nil] selected:0 title:@"With Dict"]];
  
  
  QSection *createSection = [[QSection alloc] init];
  QButtonElement *createButton = [[QButtonElement alloc] initWithTitle:@"Create Map"];
  createButton.onSelected = ^{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    [root fetchValueIntoObject:dict];
    
    //Create new CYMap object from values
    //  (store item requirements in nstring property
    //   which can be read to JSON and parsed by the JSON dialogue builder)
    
    //Add current user as owner (need to set ability to delete if owner on map detail)
    //Upload new CYMap object to parse
    //Add new CYMap object to local full map list (help on CYMap class?)
    //Add new CYMap object to current user's maps (ie auto follow it)
    
    //dismiss CYMapCreationViewController
    
    //For now read out values
    NSString *msg = @"Values:";
    for (NSString *aKey in dict){
      msg = [msg stringByAppendingFormat:@"\n- %@: %@", aKey, [dict valueForKey:aKey]];
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hello"
                                                    message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
  };
  
  [root addSection:titleSection];
  [root addSection:descriptionSection];
  [root addSection:schemaSection];
  [root addSection:createSection];
  return root;

}
@end
