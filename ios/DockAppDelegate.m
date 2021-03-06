#import "DockAppDelegate.h"

#import "DockBackupManager.h"
#import "DockBuildSheetRenderer.h"
#import "DockConstants.h"
#import "DockCoreDataManager.h"
#import "DockDataLoader.h"
#import "DockDataFileLoader.h"
#import "DockSet+Addons.h"
#import "DockSquad+Addons.h"
#import "DockSquadImporteriOS.h"
#import "DockSquadsListController.h"
#import "DockShip+Addons.h"
#import "DockTopMenuViewController.h"
#import "DockUpgrade+Addons.h"

@interface DockAppDelegate ()

@property (atomic, strong) DockCoreDataManager* coreDataManager;
@property (atomic, strong) NSManagedObjectContext* managedObjectContext;
@property (atomic, strong) NSOperationQueue* loaderQueue;
@property (nonatomic, strong) DockSquadImporteriOS* squadImporter;

-(NSURL*)applicationDocumentsDirectory;
-(void)saveContext;

@end

@implementation DockAppDelegate

#pragma mark - Application lifecycle

-(NSString*)pathToDataFile
{
    NSString* appData = [[self applicationDocumentsDirectory] path];
    NSString* xmlFile = [appData stringByAppendingPathComponent: @"Data.xml"];
    NSFileManager* fm = [NSFileManager defaultManager];
    BOOL isDirectory;
    if ([fm fileExistsAtPath: xmlFile isDirectory: &isDirectory]) {
        return xmlFile;
    }
    
    return [[NSBundle mainBundle] pathForResource: @"Data" ofType: @"xml"];
}

-(NSString*)loadDataFromPath:(NSString*)filePath version:(NSString*)currentVersion error:(NSError**)error
{
    DockDataFileLoader* loader = [[DockDataFileLoader alloc] initWithContext: self.managedObjectContext version: currentVersion];
    if ([loader loadData: filePath force: NO error: error]) {
        return loader.dataVersion;
    }
    return nil;
}

-(void)loadAppData
{
    id finishLoadBlock = ^() {
        NSError* error;
        _managedObjectContext = [_coreDataManager createContext: NSMainQueueConcurrencyType error: &error];
        UINavigationController* navigationController = (UINavigationController*)self.window.rootViewController;
        id controller = [navigationController topViewController];
        DockTopMenuViewController* topMenuViewController = (DockTopMenuViewController*)controller;
        topMenuViewController.managedObjectContext = self.managedObjectContext;
    };

    id loadBlock = ^() {
        NSError* error;
        NSManagedObjectContext* moc = [_coreDataManager createContext: 1 error: &error];
        DockDataLoader* loader = [[DockDataLoader alloc] initWithContext: moc];
        [loader loadData: &error];
        [loader cleanupDatabase];
        [DockSquad assignUUIDs: moc];
        [[NSOperationQueue mainQueue] addOperationWithBlock: finishLoadBlock];
    };

    _coreDataManager = [[DockCoreDataManager alloc] initWithStore: [self storeURL] model: [self modelURL]];
    [_loaderQueue addOperationWithBlock: loadBlock];
}

-(DockSquad*)importSquad:(NSURL*)url
{
    NSError* error;
    DockSquad* newSquad = nil;
    NSString* contents = [NSString stringWithContentsOfURL: url encoding: NSUTF8StringEncoding error: &error];
    if (contents != nil) {
        NSString* extension = [url pathExtension];
        if ([extension isEqualToString: kSpaceDockSquadFileExtension]) {
            newSquad = [DockSquad importOneSquadFromString: contents context: _managedObjectContext];
        } else {
            NSString* name = [[[url path] lastPathComponent] stringByDeletingPathExtension];
            newSquad = [DockSquad import: name data: contents context: _managedObjectContext];
        }
    }
    return newSquad;
}

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _loaderQueue = [[NSOperationQueue alloc] init];

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* appDefs = @{
        kPlayerNameKey: @"",
        kPlayerEmailKey: @"",
        kEventFactionKey: @"",
        kEventNameKey: @"",
        kBlindBuyKey: @""
    };

    [defaults registerDefaults: appDefs];

    [self loadAppData];

    return YES;
}

-(BOOL)importOneSquad:(NSURL*)url
{
    DockSquad* newSquad = [self importSquad: url];
    if (newSquad != nil) {
        UINavigationController* navigationController = (UINavigationController*)self.window.rootViewController;
        for (UIViewController* controller in navigationController.viewControllers) {
            if ([controller isKindOfClass: [DockTopMenuViewController class]]) {
                [navigationController popToViewController: controller animated: NO];
                DockTopMenuViewController* topMenuViewController = (DockTopMenuViewController*)controller;
                [topMenuViewController showSquad: newSquad];
                break;
            }
        }
    }
    return newSquad != nil;
}

-(BOOL)importSquadList:(NSURL*)url
{
    _squadImporter = [[DockSquadImporteriOS alloc] initWithPath: [url path] context: _managedObjectContext];
    [_squadImporter examineImport: nil];
#if 0
    UINavigationController* navigationController = (UINavigationController*)self.window.rootViewController;
    for (UIViewController* controller in navigationController.viewControllers) {
        if ([controller isKindOfClass: [DockSquadsListController class]]) {
            [navigationController popToViewController: controller animated: NO];
            break;
        }
    }
#endif
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSString* extension = [[[url path] pathExtension] lowercaseString];
    if ([extension isEqualToString: @"spacedock"]) {
        return [self importOneSquad: url];
    }
    if ([extension isEqualToString: @"spacedocksquads"]) {
        return [self importSquadList: url];
    }
    return NO;
}

-(void)cleanupSavedSquads
{
    NSString* targetDirectory = [[self applicationDocumentsDirectory] path];
    NSFileManager* fm = [NSFileManager defaultManager];
    NSArray* files = [fm contentsOfDirectoryAtPath: targetDirectory error: nil];
    for (NSString* oneFileName in files) {
        NSString* extension = [oneFileName pathExtension];
        if ([extension isEqualToString: @"json"]) {
            NSString* oneTargetPath = [targetDirectory stringByAppendingPathComponent: oneFileName];
            [fm removeItemAtPath: oneTargetPath error: nil];
        }
    }
}

-(void)applicationWillTerminate:(UIApplication*)application
{
    [self saveContext];
}

-(void)applicationWillResignActive:(UIApplication*)application
{
    [self saveContext];
}

-(void)applicationDidEnterBackground:(UIApplication*)application
{
    [self saveContext];
}

-(void)saveSquadsToDisk
{
    NSString* targetDirectory = [[self applicationDocumentsDirectory] path];
    for (DockSquad* squad in [DockSquad allSquads: _managedObjectContext]) {
        NSString* targetPath = [targetDirectory stringByAppendingPathComponent: [NSString stringWithFormat: @"%@_%@", squad.name, squad.uuid]];
        targetPath = [targetPath stringByAppendingPathExtension: @"json"];
        [squad checkAndUpdateFileAtPath: targetPath];
    }
}

-(void)saveContext
{
    NSError* error;
    
    [self cleanupSavedSquads];

    if (_managedObjectContext != nil) {
        
        DockBackupManager* backupManager = [DockBackupManager sharedBackupManager];
        if (backupManager.squadHasChanged) {
            [backupManager backupNow: self.managedObjectContext error: nil];
        }
        
        if ([_managedObjectContext hasChanges]) {
            BOOL contextSaved = [_managedObjectContext save: &error];
            
            if (!contextSaved) {
                /*
                 Replace this implementation with code to handle the error appropriately.
                 
                 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 */
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            }
        }
    }
    
}

#pragma mark - Core Data stack

static NSString* kSpaceDockFileName = @"SpaceDock2.CDBStore";

-(NSURL*)storeURL
{
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent: kSpaceDockFileName];
}

-(NSURL*)modelURL
{
    return [[NSBundle mainBundle] URLForResource: @"Space_Dock" withExtension: @"momd"];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
}

#pragma mark - Application's documents directory

// Returns the URL to the application's Documents directory.
-(NSURL*)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory: NSDocumentDirectory inDomains: NSUserDomainMask] lastObject];
}

-(NSURL*)updatedDataURL
{
    return [[self applicationDocumentsDirectory] URLByAppendingPathComponent: @"Data.xml"];
}

@end
