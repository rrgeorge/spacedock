#import "DockSquad.h"

@class DockEquippedShip;
@class DockEquippedUpgrade;
@class DockUpgrade;
@class DockCaptain;
@class DockShip;

@interface DockSquad (Addons)
@property (nonatomic, readonly) int cost;
+(NSArray*)allSquads:(NSManagedObjectContext*)context;
+(NSSet*)allNames:(NSManagedObjectContext*)context;
+(DockSquad*)import:(NSString*)name data:(NSString*)datFormatString context:(NSManagedObjectContext*)context;
-(void)addEquippedShip:(DockEquippedShip*)ship;
-(void)removeEquippedShip:(DockEquippedShip*)ship;
-(void)squadCompositionChanged;
-(NSString*)asTextFormat;
-(NSString*)asPlainTextFormat;
-(NSString*)asDataFormat;
-(DockEquippedShip*)containsShip:(DockShip*)theShip;
-(DockEquippedUpgrade*)containsUpgrade:(DockUpgrade*)theUpgrade;
-(DockEquippedUpgrade*)containsUpgradeWithName:(NSString*)theName;
-(DockSquad*)duplicate;
-(BOOL)canAddCaptain:(DockCaptain*)captain toShip:(DockEquippedShip*)targetShip error:(NSError**)error;
-(DockEquippedUpgrade*)addCaptain:(DockCaptain*)captain toShip:(DockEquippedShip*)targetShip error:(NSError**)error;
-(BOOL)canAddUpgrade:(DockUpgrade*)upgrade toShip:(DockEquippedShip*)targetShip error:(NSError**)error;
@end
