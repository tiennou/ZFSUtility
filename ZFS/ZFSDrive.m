//
//  ZFSDrive.m
//  ZFS Utility
//
//  Created by Etienne on 11/06/2015.
//  Copyright (c) 2015 Etienne Samson. All rights reserved.
//

#import "ZFSDrive.h"

@interface ZFSDrive () {
    @public
    ZFSDriveType _type;
}
@end

@implementation ZFSDrive

- (instancetype)initWithDriveType:(ZFSDriveType)driveType
{
    NSParameterAssert(driveType >= ZFSDriveTypeDisk && driveType <= ZFSDriveTypeCache);

    self = [super init];
    if (!self) return nil;

    _type = driveType;

    return self;
}

- (ZFSDriveType)type
{
    return _type;
}

@end

@interface ZFSDiskDrive () {
    NSString *_identifier;
}

@end

@implementation ZFSDiskDrive

+ (instancetype)diskDriveWithIdentifier:(NSString *)identifier
{
    return [self diskDriveWithIdentifier:identifier type:ZFSDriveTypeDisk];
}

+ (instancetype)diskDriveWithIdentifier:(NSString *)identifier type:(ZFSDriveType)driveType
{
    return [[self alloc] initWithIdentifier:identifier type:driveType];
}

- (instancetype)initWithIdentifier:(NSString *)identifier type:(ZFSDriveType)driveType
{
    NSParameterAssert(identifier != nil);

    self = [super initWithDriveType:driveType];
    if (!self) return nil;

    _type = driveType;
    _identifier = [identifier copy];

    return self;
}

@end

@interface ZFSFileDrive () {
    NSURL *_url;
}

@end

@implementation ZFSFileDrive

+ (instancetype)fileDriveWithURL:(NSURL *)URL
{
    return [[self alloc] initWithURL:URL];
}

- (instancetype)initWithURL:(NSURL *)URL
{
    self = [super initWithDriveType:ZFSDriveTypeFile];
    if (!self) return nil;

    _url = [URL copy];

    return self;
}

@end
