//
//  ZFSDriveSet.m
//  ZFS Utility
//
//  Created by Etienne on 11/06/2015.
//  Copyright (c) 2015 Etienne Samson. All rights reserved.
//

#import "ZFSDriveSet.h"

@interface ZFSDriveSet () {
    ZFSDriveSetType _type;
    NSMutableArray *_drives;
}
@end

@implementation ZFSDriveSet

+ (instancetype)driveSetWithDrives:(NSArray *)drives type:(ZFSDriveSetType)setType
{
    return [[self alloc] initWithDrives:drives type:setType];
}

- (instancetype)initWithDrives:(NSArray *)drives type:(ZFSDriveSetType)setType
{
    self = [super init];
    if (!self) return nil;

    _type = setType;
    _drives = [NSMutableArray array];

    return self;
}

@end
