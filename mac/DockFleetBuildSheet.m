#import "DockFleetBuildSheet.h"

#import "DockCaptain+Addons.h"
#import "DockEquippedShip+Addons.h"
#import "DockEquippedUpgrade+Addons.h"
#import "DockUpgrade+Addons.h"
#import "DockResource+Addons.h"
#import "DockSquad+Addons.h"

@interface DockFleetBuildSheetShip : NSObject <NSTableViewDataSource>
@property (nonatomic, strong) NSArray* topLevelObjects;
@property (nonatomic, strong) IBOutlet NSView* gridContainer;
@property (nonatomic, strong) IBOutlet NSTableView* shipGrid;
@property (nonatomic, strong) IBOutlet NSTextField* totalSP;
@property (nonatomic, strong) DockEquippedShip* equippedShip;
@property (nonatomic, strong) NSMutableArray* upgrades;
@end

const int kExtraRows = 3;

@implementation DockFleetBuildSheetShip

-(void)setEquippedShip:(DockEquippedShip *)equippedShip
{
    if (_equippedShip != equippedShip) {
        _equippedShip = equippedShip;

        if (_equippedShip) {
            NSArray* equippedUpgrades = equippedShip.sortedUpgrades;
            _upgrades = [[NSMutableArray alloc] initWithCapacity: equippedUpgrades.count];

            for (DockEquippedUpgrade* upgrade in equippedUpgrades) {
                if (![upgrade isPlaceholder] && ![upgrade.upgrade isCaptain]) {
                    [_upgrades addObject: upgrade];
                }
            }
        } else {
            _upgrades = nil;
        }
        [_totalSP setIntValue: _equippedShip.cost];
    }
    [_shipGrid reloadData];
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if (_upgrades) {
        return _upgrades.count + kExtraRows;
    }
    return 0;
}

NSAttributedString* headerText(NSString* string)
{
    NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setAlignment:NSCenterTextAlignment];
    NSDictionary* attributes = @{
                                 NSFontAttributeName: [NSFont userFontOfSize: 7],
                                 NSParagraphStyleAttributeName: paragraphStyle
                                 };
    return [[NSAttributedString alloc] initWithString: string attributes: attributes];
}

-(id)handleHeader:(NSString*)identifier
{
    if ([identifier isEqualToString: @"type"]) {
        return headerText(@"Type");
    }

    if ([identifier isEqualToString: @"faction"]) {
        return headerText(@"Faction");
    }

    if ([identifier isEqualToString: @"sp"]) {
        return headerText(@"SP");
    }
    
    return headerText(@"Card Title");
}

-(id)handleShip:(NSString*)identifier
{
    if ([identifier isEqualToString: @"type"]) {
        return @"Ship";
    }

    if ([identifier isEqualToString: @"faction"]) {
        return [_equippedShip factionCode];
    }

    if ([identifier isEqualToString: @"sp"]) {
        return [NSNumber numberWithInt: [_equippedShip baseCost]];
    }
    
    return [_equippedShip descriptiveTitle];
}

-(id)handleCaptain:(NSString*)identifier
{
    if ([identifier isEqualToString: @"type"]) {
        return @"Cap";
    }

    DockEquippedUpgrade* equippedCaptain = [_equippedShip equippedCaptain];
    DockCaptain* captain = (DockCaptain*)[equippedCaptain upgrade];

    if ([identifier isEqualToString: @"faction"]) {
        return [captain factionCode];
    }

    if ([identifier isEqualToString: @"sp"]) {
        return [NSNumber numberWithInt: equippedCaptain.cost];
    }
    

    return captain.title;
}

-(id)handleUpgrade:(NSString*)identifier index:(long)index
{
    if (index < _upgrades.count) {
        DockEquippedUpgrade* equippedUpgrade = _upgrades[index];
        if ([identifier isEqualToString: @"type"]) {
            return equippedUpgrade.upgrade.typeCode;
        }
        if ([identifier isEqualToString: @"faction"]) {
            return equippedUpgrade.upgrade.factionCode;
        }

        if ([identifier isEqualToString: @"sp"]) {
            return [NSNumber numberWithInt: [equippedUpgrade cost]];
        }
        
        return equippedUpgrade.upgrade.title;
    }

    return nil;
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    switch (row) {
        case 0:
            return [self handleHeader: tableColumn.identifier];
            
        case 1:
            return [self handleShip: tableColumn.identifier];
            
        case 2:
            return [self handleCaptain: tableColumn.identifier];
            
        default:
            return [self handleUpgrade: tableColumn.identifier index: row - kExtraRows];
    }
    return nil;
}

@end

@interface DockFleetBuildSheet () <NSTableViewDataSource> {
    NSMutableArray* _shipDataList;
    NSNumber* _squadTotalCost;
    NSString* _date;
    NSDictionary* _dataForResource;
    NSMutableArray* _buildShips;
}
@property (strong, nonatomic) IBOutlet NSWindow* mainWindow;
@property (strong, nonatomic) IBOutlet NSWindow* fleetBuildDetails;
@property (strong, nonatomic) IBOutlet NSBox* sheetBox;
@property (strong, nonatomic) IBOutlet NSView* box1;
@property (strong, nonatomic) IBOutlet NSView* box2;
@property (strong, nonatomic) IBOutlet NSView* box3;
@property (strong, nonatomic) IBOutlet NSView* box4;
@property (strong, nonatomic) IBOutlet NSTextField* resourceTitleField;
@property (strong, nonatomic) IBOutlet NSTextField* resourceCostField;
@property (strong, nonatomic) IBOutlet NSTextField* nameField;
@property (strong, nonatomic) DockSquad* targetSquad;
@end

@implementation DockFleetBuildSheet


-(void)awakeFromNib
{
    self.eventDate = [NSDate date];
    _buildShips = [[NSMutableArray alloc] init];
    NSArray* views = @[_box1, _box2, _box3, _box4];
    NSBundle* mainBundle = [NSBundle mainBundle];
    for (int i = 0; i < 4; ++i) {
        DockFleetBuildSheetShip* ship = [[DockFleetBuildSheetShip alloc] init];
        NSArray* a;
        [mainBundle loadNibNamed: @"ShipGrid" owner: ship topLevelObjects: &a];
        ship.topLevelObjects = a;
        NSView* view = views[i];
        [ship.gridContainer setFrameSize: view.frame.size];
        [view addSubview: ship.gridContainer];
        [_buildShips addObject: ship];
    }
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    self.name = [defaults stringForKey: @"name"];
    self.eventName = [defaults stringForKey: @"eventName"];
    self.email = [defaults stringForKey: @"email"];
    self.faction = [defaults stringForKey: @"faction"];
}

-(void)print
{
    NSOrderedSet* equippedShips = _targetSquad.equippedShips;
    for (int i = 0; i < 4; ++i) {
        DockEquippedShip* equippedShip = nil;
        if (i < equippedShips.count) {
            equippedShip = equippedShips[i];
        }
        DockFleetBuildSheetShip* buildSheetShip = _buildShips[i];
        buildSheetShip.equippedShip = equippedShip;
    }
    
    [_resourceTitleField setStringValue: [self resourceTile]];
    [_resourceCostField setStringValue: [self resourceCost]];

    NSPrintInfo* info = [NSPrintInfo sharedPrintInfo];
    info.leftMargin = 0;
    info.rightMargin = 0;
    info.topMargin = 0;
    info.bottomMargin = 0;
    NSMutableDictionary* dict = [info dictionary];
    dict[NSPrintHorizontalPagination] = [NSNumber numberWithInt: NSFitPagination];
    dict[NSPrintVerticalPagination] = [NSNumber numberWithInt: NSFitPagination];
    dict[NSPrintHorizontallyCentered] = [NSNumber numberWithBool: YES];
    dict[NSPrintVerticallyCentered] = [NSNumber numberWithBool: YES];
    NSRect r = [info imageablePageBounds];
    [_sheetBox setFrameSize: r.size];
    [[NSPrintOperation printOperationWithView: _sheetBox] runOperation];
}

-(NSString*)shipCost:(int)index
{
    NSOrderedSet* equippedShips = _targetSquad.equippedShips;
    if (index < equippedShips.count) {
        DockEquippedShip* equippedShip = equippedShips[index];
        int cost = equippedShip.cost;
        if (cost == 0) {
            return @"";
        }
        return [NSString stringWithFormat: @"%d", equippedShip.cost];
    }
    return @"";
}

-(NSString*)resourceCost
{
    DockResource* res = _targetSquad.resource;
    if (res) {
        return [NSString stringWithFormat: @"%@", res.cost];
    }
    return @"";
}

-(NSString*)resourceTile
{
    DockResource* res = _targetSquad.resource;
    if (res) {
        return res.title;
    }
    return @"";
}

-(id)beforeValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString* identifier = tableColumn.identifier;
    if (row == 0) {
        NSDictionary* labels = @{
            @"round" : @"Battle Round",
            @"name" : @"Opponent's Name",
            @"initials" : @"Opponent's\nInitials\n(Verify Build)"
        };
        return headerText(labels[identifier]);
    }
    
    if ([identifier isEqualToString: @"round"]) {
        return [NSString stringWithFormat: @"%ld", (long)row];
    }
    return @"";
}

-(id)endValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if (row == 0) {
        NSDictionary* labels = @{
            @"result" : @"Your Result\n(W-L-B)",
            @"fp" : @"Your\nFleet Points",
            @"cfp" : @"Cumulative\nFleet Points",
            @"initials" : @"Opponent's\nInitials\n(Verify Results)"
        };
        return headerText(labels[tableColumn.identifier]);
    }
    return @"";
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString* identifier = tableView.identifier;
    
    if ([identifier isEqualToString: @"before"]) {
        return [self beforeValueForTableColumn: tableColumn row:row];
    }

    if ([identifier isEqualToString: @"end"]) {
        return [self endValueForTableColumn: tableColumn row:row];
    }

    NSString* columnIdentifier = tableColumn.identifier;
    int index = [columnIdentifier intValue];
    switch(index) {
    case 0:
    case 1:
    case 2:
    case 3:
        return [self shipCost: index];
    case 4:
        return [self resourceCost];
        
    }
    return [NSNumber numberWithInt: _targetSquad.cost];
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    NSString* identifier = tableView.identifier;
    if ([identifier isEqualToString: @"before"] || [identifier isEqualToString: @"end"]) {
        return 4;
    }
    return 1;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    if (row == 0) {
        return tableView.rowHeight*2;
    }
    return tableView.rowHeight;
}

-(void)sheetDidEnd:(NSWindow*)sheet returnCode:(NSInteger)returnCode contextInfo:(void*)contextInfo
{
    [_fleetBuildDetails orderOut: nil];
}

-(void)show:(DockSquad*)targetSquad
{
    _targetSquad = targetSquad;
    [NSApp beginSheet: _fleetBuildDetails modalForWindow: _mainWindow modalDelegate: self didEndSelector: @selector(sheetDidEnd:returnCode:contextInfo:) contextInfo: nil];
}

-(IBAction)cancel:(id)sender
{
    [NSApp endSheet: _fleetBuildDetails];
}

-(IBAction)print:(id)sender
{
    [NSApp endSheet: _fleetBuildDetails];
    [self print];
}

-(void)setEventDate:(NSDate *)eventDate
{
    _eventDate = eventDate;
    [self willChangeValueForKey: @"eventDateString"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    _eventDateString = [dateFormatter stringFromDate: eventDate];
    [self didChangeValueForKey: @"eventDateString"];
}

-(void)setEventName:(NSString *)eventName
{
    [self willChangeValueForKey: @"eventName"];
    _eventName = eventName;
    [[NSUserDefaults standardUserDefaults] setObject: _eventName forKey: @"eventName"];
    [self didChangeValueForKey: @"eventName"];
}

-(void)setFaction:(NSString *)faction
{
    [self willChangeValueForKey: @"faction"];
    _faction = faction;
    [[NSUserDefaults standardUserDefaults] setObject: _faction forKey: @"faction"];
    [self didChangeValueForKey: @"faction"];
}

-(void)setEmail:(NSString *)email
{
    [self willChangeValueForKey: @"email"];
    _email = email;
    [[NSUserDefaults standardUserDefaults] setObject: _email forKey: @"email"];
    [self didChangeValueForKey: @"email"];
}

-(void)setName:(NSString *)name
{
    [self willChangeValueForKey: @"name"];
    _name = name;
    [[NSUserDefaults standardUserDefaults] setObject: _name forKey: @"name"];
    [self didChangeValueForKey: @"name"];
}

@end