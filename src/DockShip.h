//
//  DockShip.h
//  Space Dock
//
//  Created by Rob Tsuk on 7/5/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DockSetItem.h"

@class DockEquippedShip, DockShipClassDetails;

@interface DockShip : DockSetItem

@property (nonatomic, retain) NSString * ability;
@property (nonatomic, retain) NSNumber * agility;
@property (nonatomic, retain) NSNumber * attack;
@property (nonatomic, retain) NSNumber * battleStations;
@property (nonatomic, retain) NSNumber * borg;
@property (nonatomic, retain) NSNumber * captainLimit;
@property (nonatomic, retain) NSNumber * cloak;
@property (nonatomic, retain) NSNumber * crew;
@property (nonatomic, retain) NSNumber * evasiveManeuvers;
@property (nonatomic, retain) NSNumber * has360Arc;
@property (nonatomic, retain) NSNumber * hull;
@property (nonatomic, retain) NSNumber * regenerate;
@property (nonatomic, retain) NSNumber * scan;
@property (nonatomic, retain) NSNumber * sensorEcho;
@property (nonatomic, retain) NSNumber * shield;
@property (nonatomic, retain) NSString * shipClass;
@property (nonatomic, retain) NSNumber * targetLock;
@property (nonatomic, retain) NSNumber * tech;
@property (nonatomic, retain) NSNumber * weapon;
@property (nonatomic, retain) NSSet *equippedShips;
@property (nonatomic, retain) DockShipClassDetails *shipClassDetails;
@end

@interface DockShip (CoreDataGeneratedAccessors)

- (void)addEquippedShipsObject:(DockEquippedShip *)value;
- (void)removeEquippedShipsObject:(DockEquippedShip *)value;
- (void)addEquippedShips:(NSSet *)values;
- (void)removeEquippedShips:(NSSet *)values;

@end
