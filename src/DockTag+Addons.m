#import "DockTag+Addons.h"

#import "DockConstants.h"

@implementation DockTag (Addons)

#pragma warning NYI

+(DockTag*)tagWithType:(NSString*)type value:(NSString*)value context:(NSManagedObjectContext*)context
{
    NSEntityDescription* entity = [NSEntityDescription entityForName: @"Tag"
                                              inManagedObjectContext: context];
    DockTag* tag = [[DockTag alloc] initWithEntity: entity
                                     insertIntoManagedObjectContext: context];
    tag.type = type;
    tag.value = value;
    return tag;
}

+(DockTag*)factionTag:(NSString*)faction context:(NSManagedObjectContext*)context
{
    return [DockTag tagWithType: kFactionTagType value: faction context: context];
}

+(DockTag*)upgradeTypeTag:(NSString*)upgradeType context:(NSManagedObjectContext*)context
{
    return [DockTag tagWithType: kUpgradeTypeTagType value: upgradeType context: context];
}

-(BOOL)isType:(NSString*)type
{
    return [self.type isEqualToString: type];
}

@end
