//
//  DockResource.h
//  Space Dock
//
//  Created by Rob Tsuk on 7/5/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DockSetItem.h"

@class DockSquad;

@interface DockResource : DockSetItem

@property (nonatomic, retain) NSString * ability;
@property (nonatomic, retain) NSSet *squad;
@end

@interface DockResource (CoreDataGeneratedAccessors)

- (void)addSquadObject:(DockSquad *)value;
- (void)removeSquadObject:(DockSquad *)value;
- (void)addSquad:(NSSet *)values;
- (void)removeSquad:(NSSet *)values;

@end
