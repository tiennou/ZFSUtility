//
//  ZFSDrive.h
//  ZFS Utility
//
//  Created by Etienne on 11/06/2015.
//  Copyright (c) 2015 Etienne Samson. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ZFSDriveType) {
    ZFSDriveTypeDisk,
    ZFSDriveTypeFile,
    ZFSDriveTypeSpare,
    ZFSDriveTypeLog,
    ZFSDriveTypeCache,
};

@interface ZFSDrive : NSObject

@property (readonly, assign) ZFSDriveType type;

- (BOOL)takeOnline:(BOOL)expand error:(NSError *)error;
- (BOOL)takeOffline:(BOOL)untilReboot error:(NSError *)error;

@end

@interface ZFSDiskDrive : ZFSDrive

+ (instancetype)diskDriveWithIdentifier:(NSString *)identifier type:(ZFSDriveType)driveType;
+ (instancetype)diskDriveWithIdentifier:(NSString *)identifier;

@end

@interface ZFSFileDrive : ZFSDrive

+ (instancetype)fileDriveWithURL:(NSURL *)URL;

@end
