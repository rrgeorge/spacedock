#import "DockSquadsListController.h"

#import "DockConstants.h"
#import "DockEditValueController.h"
#import "DockSquad+Addons.h"
#import "DockSquadDetailController.h"
#import "DockSquadListCell.h"

#import <MessageUI/MessageUI.h>

@interface DockSquadsListController ()<MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate>
@property (nonatomic, strong) NSFetchedResultsController* fetchedResultsController;
@property (nonatomic, strong) UIDocumentInteractionController* shareController;
@end

@implementation DockSquadsListController

-(id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle: style];

    if (self) {
        // Custom initialization
    }

    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    NSError* error;

    if (![[self fetchedResultsController] performFetch: &error]) {
        /*
           Replace this implementation with code to handle the error appropriately.

           abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    [self.tableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_targetSquad != nil) {
        [self selectSquad: _targetSquad];
        [self performSegueWithIdentifier: @"ShowSelectedSquad" sender: nil];
    }
    _targetSquad = nil;
}

-(void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Fetched Results Controller

-(NSFetchedResultsController*)fetchedResultsController
{

    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }

    // Create and configure a fetch request with the Book entity.
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Squad" inManagedObjectContext: self.managedObjectContext];
    [fetchRequest setEntity: entity];

    // Create the sort descriptors array.
    NSSortDescriptor* nameDescriptor = [[NSSortDescriptor alloc] initWithKey: @"name" ascending: YES selector: @selector(localizedCaseInsensitiveCompare:)];
    NSArray* sortDescriptors = @[nameDescriptor];
    [fetchRequest setSortDescriptors: sortDescriptors];

    // Create and initialize the fetch results controller.
    _fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest: fetchRequest managedObjectContext: self.managedObjectContext sectionNameKeyPath: nil cacheName: @"Squads"];
    _fetchedResultsController.delegate = self;

    return _fetchedResultsController;
}

-(void)controllerWillChangeContent:(NSFetchedResultsController*)controller
{

    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [self.tableView beginUpdates];
}

-(void)controller:(NSFetchedResultsController*)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath*)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath*)newIndexPath
{

    UITableView* tableView = self.tableView;

    switch (type) {

    case NSFetchedResultsChangeInsert:
        [tableView insertRowsAtIndexPaths: @[newIndexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
        break;

    case NSFetchedResultsChangeDelete:
        [tableView deleteRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
        break;

    case NSFetchedResultsChangeUpdate:
        [self configureCell: [tableView cellForRowAtIndexPath: indexPath] atIndexPath: indexPath];
        break;

    case NSFetchedResultsChangeMove:
        [tableView deleteRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
        [tableView insertRowsAtIndexPaths: @[newIndexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
        break;
    }
}

-(void)controller:(NSFetchedResultsController*)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {

    case NSFetchedResultsChangeInsert:
        [self.tableView insertSections: [NSIndexSet indexSetWithIndex: sectionIndex] withRowAnimation: UITableViewRowAnimationAutomatic];
        break;

    case NSFetchedResultsChangeDelete:
        [self.tableView deleteSections: [NSIndexSet indexSetWithIndex: sectionIndex] withRowAnimation: UITableViewRowAnimationAutomatic];
        break;
    case NSFetchedResultsChangeMove:
            NSLog(@"A table item was moved");
            break;
    case NSFetchedResultsChangeUpdate:
            NSLog(@"A table item was updated");
            break;
    }
}

-(void)controllerDidChangeContent:(NSFetchedResultsController*)controller
{

    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [self.tableView endUpdates];
}

#pragma mark - Table view data source

-(BOOL)tableView:(UITableView*)tableView canMoveRowAtIndexPath:(NSIndexPath*)indexPath
{

    // The table view should not be re-orderable.
    return NO;
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex: section];
    NSInteger rowCount = [sectionInfo numberOfObjects];
    return rowCount;
}

-(void)configureCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    DockSquadListCell* squadCell = (DockSquadListCell*)cell;
    DockSquad* squad = [self.fetchedResultsController objectAtIndexPath: indexPath];
    squadCell.cost.text = [NSString stringWithFormat: @"%d", [squad cost]];
    squadCell.details.text = [squad shipsDescription];
    squadCell.title.text = squad.name;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* CellIdentifier = @"squad";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier: CellIdentifier forIndexPath: indexPath];

    [self configureCell: cell atIndexPath: indexPath];

    return cell;
}

-(void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {

        // Delete the managed object.
        NSManagedObjectContext* context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject: [self.fetchedResultsController objectAtIndexPath: indexPath]];

        NSError* error;

        if (![context save: &error]) {
            /*
               Replace this implementation with code to handle the error appropriately.

               abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    } else if (editingStyle == UITableViewCellEditingStyleInsert)   {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender
{
    NSString* identifier = [segue identifier];
    id destination = [segue destinationViewController];

    if ([identifier isEqualToString: @"ShowSelectedSquad"]) {

        NSIndexPath* indexPath = [self.tableView indexPathForSelectedRow];
        DockSquad* selectedSquad = (DockSquad*)[[self fetchedResultsController] objectAtIndexPath: indexPath];

        // Pass the selected book to the new view controller.
        DockSquadDetailController* squadViewController = (DockSquadDetailController*)destination;
        squadViewController.squad = selectedSquad;
    } else if ([identifier isEqualToString: @"NameNewSquad"]) {
        DockEditValueController* editValue = (DockEditValueController*)destination;
        editValue.valueName = @"Name";
        editValue.initialValue = @"";
        editValue.onSave = ^(NSString* newValue) {
            DockSquad* newSquad = [DockSquad squad: _managedObjectContext];
            newSquad.name = newValue;
        };
    }
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller didEndSendingToApplication:(NSString *)application
{
    NSURL* url = _shareController.URL;
    [[NSFileManager defaultManager] removeItemAtURL: url error: nil];
    _shareController = nil;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    switch(buttonIndex) {
    case 0:
        [self sendViaEmail];
        break;
    case 1:
        [self openInOtherApp];
        break;
    }
}

-(IBAction)share:(id)sender
{
    UIActionSheet* sheet = [[UIActionSheet alloc] initWithTitle: nil
                                                       delegate: self
                                              cancelButtonTitle: @"Cancel"
                                         destructiveButtonTitle: nil
                                              otherButtonTitles: @"Send a Copy", @"Open in Another App", nil];
    [sheet showFromBarButtonItem: _shareItem animated: YES];
}

-(void)openInOtherApp
{
    NSString* tempSquads = NSTemporaryDirectory();
    tempSquads = [tempSquads stringByAppendingPathComponent: @"all_squads.spacedocksquads"];
    [DockSquad saveSquadsToDisk: tempSquads context: self.managedObjectContext];
    NSURL* url = [[NSURL alloc] initFileURLWithPath: tempSquads];
    _shareController = [UIDocumentInteractionController interactionControllerWithURL: url];
    _shareController.delegate = self;
    bool didShow = [_shareController presentOpenInMenuFromRect:self.view.bounds inView:self.view animated:YES];
    if (!didShow)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Couldn't Share"
                                                        message:@"This squad list could not be shared."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
}


-(void)sendViaEmail
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController* picker = [[MFMailComposeViewController alloc] init];
        picker.mailComposeDelegate = self;

        [picker setSubject: @"Space Dock All Squads"];

        // Fill out the email body text
        NSString* textFormat = @"Attached are squads for use with Space Dock on Mac or iOS.";
        [picker setMessageBody: textFormat isHTML: NO];

        NSError* error;
        NSData* jsonData = [DockSquad allSquadsAsJSON: self.managedObjectContext error: &error];
        [picker addAttachmentData: jsonData mimeType: @"text/x-spacedock" fileName: [kSpaceDockAllSquadsName stringByAppendingPathExtension: kSpaceDockSquadListFileExtension]];

        [self presentViewController: picker animated: YES completion: NULL];
    } else {
        UIAlertView* view = [[UIAlertView alloc] initWithTitle: @"Can't Send All Squads"
                                                       message: @"This device is not configured to send mail."
                                                      delegate: nil
                                             cancelButtonTitle: @""
                                             otherButtonTitles: @"",
                             nil];
        [view show];
    }
}

-(void)mailComposeController:(MFMailComposeViewController*)controller
         didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    if (error != nil) {
        UIAlertView* view = [[UIAlertView alloc] initWithTitle: @"Can't send Squad"
                                                       message: error.localizedDescription
                                                      delegate: nil
                                             cancelButtonTitle: @""
                                             otherButtonTitles: @"",
                             nil];
        [view show];
    }

    [self dismissViewControllerAnimated: YES completion: NULL];
}

-(void)messageComposeViewController:(MFMessageComposeViewController*)controller
                didFinishWithResult:(MessageComposeResult)result
{
    [self dismissViewControllerAnimated: YES completion: NULL];
}

-(void)selectSquad:(DockSquad*)squad
{
    NSIndexPath* indexPath = [self.fetchedResultsController indexPathForObject: squad];
    [self.tableView selectRowAtIndexPath: indexPath animated: YES scrollPosition: UITableViewScrollPositionMiddle];
}

@end
