#import "DockTag.h"

@interface DockTag (Addons)
+(DockTag*)factionTag:(NSString*)faction context:(NSManagedObjectContext*)context;
+(DockTag*)upgradeTypeTag:(NSString*)upgradeType context:(NSManagedObjectContext*)context;
-(BOOL)isType:(NSString*)type;
@end
