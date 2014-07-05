#import "DockSetItem+Addons.h"

#import "DockConstants.h"
#import "DockSet+Addons.h"
#import "DockShip+Addons.h"
#import "DockTag+Addons.h"
#import "DockUtils.h"

@implementation DockSetItem (Addons)

-(NSString*)anySetExternalId
{
    DockSet* set = [self.sets anyObject];
    return set.externalId;
}

-(NSString*)factionCode
{
    return factionCode(self);
}

-(NSString*)setName
{
    NSSet* sets = self.sets;
    NSInteger setsCount = sets.count;
    if (setsCount == 0) {
        return @"";
    } else if (setsCount == 1) {
        return [[sets anyObject] productName];
    }
    
    NSMutableArray* allSetNames = [[NSMutableArray alloc] initWithCapacity: setsCount];
    for (DockSet* set in sets) {
        [allSetNames addObject: set.productName];
    }
    return [allSetNames componentsJoinedByString: @", "];
}

-(NSString*)itemDescription
{
    return [self description];
}

-(NSString*)sortStringForSet
{
    @try {
        return [self valueForKey: @"faction"];
    } @catch (NSException *exception) {
    } @finally {
    }
    return @"";
}

-(NSComparisonResult)compareForSet:(id)object
{
    return [[self sortStringForSet] compare: [object sortStringForSet]];
}

-(BOOL)isFaction:(NSString*)faction
{
    DockTag* factionTag = [DockTag factionTag: faction context: self.managedObjectContext];
    return [self.tags containsObject: factionTag];
}

-(NSSet*)tagsOfType:(NSString*)tagType
{
    id test = ^(id obj, BOOL *stop) {
        DockTag* tag = obj;
        return [tag isType: tagType];
    };
    return [self.tags objectsPassingTest: test];
}

-(void)removeAllTagsOfType:(NSString*)type
{
    NSSet* allTags = [self tagsOfType: type];
    [self removeTags: allTags];
}

-(BOOL)matchesFaction:(DockSetItem*)other
{
    NSSet* myFactions = [self tagsOfType: kFactionTagType];
    NSSet* othersFactions = [other tagsOfType: kFactionTagType];
    return [myFactions intersectsSet: othersFactions];
}

-(NSString*)anyFaction
{
    NSSet* factions = [self tagsOfType: kFactionTagType];
    return [[factions anyObject] value];
}

-(NSString*)faction
{
    return self.anyFaction;
}

-(void)addFaction:(NSString*)faction
{
    if (![self isFaction: faction]) {
        DockTag* factionTag = [DockTag factionTag: faction context: self.managedObjectContext];
        [self addTagsObject: factionTag];
    }
}

-(NSString*)special
{
    NSSet* factions = [self tagsOfType: kSpecialTagType];
    return [[factions anyObject] value];
}

@end
