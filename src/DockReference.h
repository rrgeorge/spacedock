//
//  DockReference.h
//  Space Dock
//
//  Created by Rob Tsuk on 7/5/14.
//  Copyright (c) 2014 Rob Tsuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "DockSetItem.h"


@interface DockReference : DockSetItem

@property (nonatomic, retain) NSString * ability;
@property (nonatomic, retain) NSString * type;

@end
