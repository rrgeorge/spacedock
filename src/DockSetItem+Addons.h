#import "DockSetItem.h"

@interface DockSetItem (Addons)
-(NSString*)anySetExternalId;
-(NSString*)factionCode;
-(NSString*)setName;
-(NSComparisonResult)compareForSet:(id)object;
-(NSString*)itemDescription;

-(BOOL)isFaction:(NSString*)faction;
-(BOOL)matchesFaction:(DockSetItem*)other;
-(NSString*)anyFaction;
-(void)addFaction:(NSString*)faction;

-(NSSet*)tagsOfType:(NSString*)tagType;
-(void)removeAllTagsOfType:(NSString*)type;

-(NSString*)special;

@end
