//
//  DockTag.h
//  Space Dock
//
//  Created by Rob Tsuk on 7/5/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class DockSetItem;

@interface DockTag : NSManagedObject

@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSSet *taggedItems;
@end

@interface DockTag (CoreDataGeneratedAccessors)

- (void)addTaggedItemsObject:(DockSetItem *)value;
- (void)removeTaggedItemsObject:(DockSetItem *)value;
- (void)addTaggedItems:(NSSet *)values;
- (void)removeTaggedItems:(NSSet *)values;

@end
