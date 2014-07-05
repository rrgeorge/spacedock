//
//  DockUpgrade.h
//  Space Dock
//
//  Created by Rob Tsuk on 7/5/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DockSetItem.h"

@class DockEquippedUpgrade;

@interface DockUpgrade : DockSetItem

@property (nonatomic, retain) NSString * ability;
@property (nonatomic, retain) NSNumber * placeholder;
@property (nonatomic, retain) NSSet *equippedUpgrades;
@end

@interface DockUpgrade (CoreDataGeneratedAccessors)

- (void)addEquippedUpgradesObject:(DockEquippedUpgrade *)value;
- (void)removeEquippedUpgradesObject:(DockEquippedUpgrade *)value;
- (void)addEquippedUpgrades:(NSSet *)values;
- (void)removeEquippedUpgrades:(NSSet *)values;

@end
