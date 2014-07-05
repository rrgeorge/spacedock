//
//  DockSetItem.h
//  Space Dock
//
//  Created by Rob Tsuk on 7/5/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DockSet, DockTag;

@interface DockSetItem : NSManagedObject

@property (nonatomic, retain) NSNumber * cost;
@property (nonatomic, retain) NSString * externalId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * unique;
@property (nonatomic, retain) NSSet *sets;
@property (nonatomic, retain) NSSet *tags;
@end

@interface DockSetItem (CoreDataGeneratedAccessors)

- (void)addSetsObject:(DockSet *)value;
- (void)removeSetsObject:(DockSet *)value;
- (void)addSets:(NSSet *)values;
- (void)removeSets:(NSSet *)values;

- (void)addTagsObject:(DockTag *)value;
- (void)removeTagsObject:(DockTag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
