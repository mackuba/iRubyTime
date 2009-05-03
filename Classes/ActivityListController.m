// -------------------------------------------------------
// ActivityListController.m
//
// Copyright (c) 2009 Jakub Suder <jakub.suder@gmail.com>
// Licensed under MIT license
// -------------------------------------------------------

#import "ActivityListController.h"
#import "RubyTimeAppDelegate.h"
#import "RubyTimeConnector.h"
#import "LoginDialogController.h"
#import "Utils.h"
#import "Activity.h"
#import "ActivityCell.h"

#define ACTIVITY_CELL_TYPE @"activityCell"

@interface ActivityListController ()
- (void) startLoading;
- (void) stopLoading;
@end

@implementation ActivityListController

@synthesize currentCell;
OnDeallocRelease(loginController, connector, activities);

- (void) awakeFromNib {
  activities = [[NSMutableArray alloc] initWithCapacity: 20];
  connector = [[RubyTimeConnector alloc] init];
}

- (void)viewDidLoad {
  [super viewDidLoad];

  // prepare "loading" spinner
  spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleWhite];
  spinner.frame = CGRectMake(0, 0, 36, 20);
  spinner.contentMode = UIViewContentModeCenter;
  
  // prepare buttons for toolbar
  loadingButton = [[UIBarButtonItem alloc] initWithCustomView: spinner];
  reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemRefresh
                                                               target: self
                                                               action: @selector(refreshClicked)];
  addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd
                                                            target: nil
                                                            action: nil];
  self.navigationItem.leftBarButtonItem = reloadButton;
  self.navigationItem.rightBarButtonItem = addButton;
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/

- (void) viewDidAppear: (BOOL) animated {
  [super viewDidAppear: animated];
  if (!connector.loggedIn) {
    loginController = [[LoginDialogController alloc] initWithNibName: @"LoginDialog"
                                                              bundle: [NSBundle mainBundle]
                                                           connector: connector
                                                      mainController: self];
    [self presentModalViewController: loginController animated: YES];
  }
}

- (void) loginSuccessful {
  if (loginController) {
    [loginController dismissModalViewControllerAnimated: YES];
    [loginController release];
    loginController = nil;
    //[self saveLoginAndPassword];
    connector.delegate = self;
  }
  [self startLoading];
  [connector getActivities];
}

/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

- (void) addActivity: (Activity *) activity {
  [self.tableView beginUpdates];
  // TODO: mass add
  [activities insertObject: activity atIndex: 0];
  NSIndexPath *row = [NSIndexPath indexPathForRow: 0 inSection: 0];
  [self.tableView insertRowsAtIndexPaths: RTArray(row) withRowAnimation: UITableViewRowAnimationTop];
  [self.tableView endUpdates];
}

- (void) scrollTextViewToTop {
  [self.tableView setContentOffset: CGPointZero animated: YES];
}

- (void) refreshClicked {
  [self startLoading];
  [connector getActivities];
}

- (void) startLoading {
  [spinner startAnimating];
  self.navigationItem.leftBarButtonItem = loadingButton;
}

- (void) stopLoading {
  self.navigationItem.leftBarButtonItem = reloadButton;
  [spinner stopAnimating];
}

// -------------------------------------------------------------------------------------------
#pragma mark Table view delegate / data source

- (NSInteger) tableView: (UITableView *) table numberOfRowsInSection: (NSInteger) section {
  return activities.count;
}

- (UITableViewCell *) tableView: (UITableView *) table cellForRowAtIndexPath: (NSIndexPath *) path {
  Activity *activity = [activities objectAtIndex: path.row];
  ActivityCell *cell = (ActivityCell *) [table dequeueReusableCellWithIdentifier: ACTIVITY_CELL_TYPE];
  if (!cell) {
    [[NSBundle mainBundle] loadNibNamed: @"ActivityCell" owner: self options: nil];
    cell = currentCell;
  }
  [cell displayActivity: activity];
  return cell;
}

- (CGFloat) tableView: (UITableView *) table heightForRowAtIndexPath: (NSIndexPath *) path {
  return 69;
}

- (void) tableView: (UITableView *) tableView didSelectRowAtIndexPath: (NSIndexPath *) indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

// -------------------------------------------------------------------------------------------
#pragma mark RubyTimeConnector delegate callbacks

- (void) activitiesReceived: (NSArray *) receivedActivities {
  if (receivedActivities.count > 0) {
    [self scrollTextViewToTop];
  }
  for (Activity *activity in [receivedActivities reverseObjectEnumerator]) {
    [self addActivity: activity];
  }
  // TODO: save activities to a file
  [self stopLoading];
}

@end

