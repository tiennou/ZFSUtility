//
//  ZFSDriveSet.h
//  ZFS Utility
//
//  Created by Etienne on 11/06/2015.
//  Copyright (c) 2015 Etienne Samson. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ZFSDriveSetType) {
    ZFSDriveSetTypeStriped,
    ZFSDriveSetTypeMirror,
    ZFSDriveSetTypeRAIDZ1,
    ZFSDriveSetTypeRAIDZ2,
    ZFSDriveSetTypeRAIDZ3,
};

@interface ZFSDriveSet : NSObject

//@property (readonly, copy) NSDictionary *properties;

+ (instancetype)driveSetWithDrives:(NSArray *)drives type:(ZFSDriveSetType)type;

@end
