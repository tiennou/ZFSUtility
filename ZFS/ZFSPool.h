//
//  ZFSPool.h
//  ZFS Utility
//
//  Created by Etienne on 11/06/2015.
//  Copyright (c) 2015 Etienne Samson. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ZFSZPoolState) {
	ZFSZPoolStateActive = 0,
	ZFSZPoolStateExported,
	ZFSZPoolStateDestroyed,
	ZFSZPoolStateSpare,
	ZFSZPoolStateL2Cache,
	ZFSZPoolStateUninitialized,
	ZFSZPoolStateUnavail,
	ZFSZPoolStatePotentiallyActive,
};

typedef int ZFSZPoolStatus;

typedef NS_ENUM(NSInteger, ZFSZPoolProperty) {
	ZFSZPoolPropertyInval = -1,
	ZFSZPoolPropertyName,
	ZFSZPoolPropertySize,
	ZFSZPoolPropertyCapacity,
	ZFSZPoolPropertyAltRoot,
	ZFSZPoolPropertyHealth,
	ZFSZPoolPropertyGUID,
	ZFSZPoolPropertyVersion,
	ZFSZPoolPropertyBootFS,
	ZFSZPoolPropertyDelegation,
	ZFSZPoolPropertyAutoReplace,
	ZFSZPoolPropertyCacheFile,
	ZFSZPoolPropertyFailureMode,
	ZFSZPoolPropertyListSnaps,
	ZFSZPoolPropertyAutoExpand,
	ZFSZPoolPropertyDedupDitto,
	ZFSZPoolPropertyDedupRatio,
	ZFSZPoolPropertyFree,
	ZFSZPoolPropertyAllocated,
	ZFSZPoolPropertyReadOnly,
	ZFSZPoolPropertyAshift,
	ZFSZPoolPropertyComment,
	ZFSZPoolPropertyExpandSize,
	ZFSZPoolPropertyFreeing,
	ZFSZPoolPropertyFragmentation,
	ZFSZPoolPropertyLeaked,
	ZFSZPoolPropertyMaxBlockSize,
	ZFSZPoolPropertyTName,
	ZFSZPoolPropertyBootSize,
	ZFSZPoolPropertyCheckpoint,
	ZFSZPoolPropertiesCount
};


@class ZFSDrive, ZFSDriveSet;

@interface ZFSPool : NSObject

@property (readonly, assign) uint64_t guid;
@property (readonly, copy)   NSString *name;
@property (readonly, assign) uint64_t size;
@property (readonly, assign) uint64_t alloc;
@property (readonly, assign) uint64_t free;
@property (readonly, assign) ZFSZPoolStatus status;

@property (copy) NSDictionary *properties;
@property (readonly, retain) ZFSDriveSet *drives;

- (instancetype)init NS_UNAVAILABLE;

//+ (instancetype)createPoolWithName:(NSString *)name driveSet:(NSArray *)driveSet properties:(NSDictionary *)properties error:(NSError **)error;

- (BOOL)addDriveSet:(ZFSDriveSet *)driveSet force:(BOOL)force error:(NSError **)error;
- (BOOL)removeDrive:(ZFSDrive *)drive;

- (BOOL)attachDrive:(ZFSDrive *)drive mirroringDrive:(ZFSDrive *)mirror error:(NSError **)error;
- (BOOL)detachDrive:(ZFSDrive *)drive;

- (BOOL)replaceDrive:(ZFSDrive *)drive withDrive:(ZFSDrive *)replacementDrive error:(NSError **)error;

- (BOOL)destroyPool:(NSError *)error;

- (BOOL)clearErrors:(NSError **)error;

- (BOOL)exportPool:(NSError **)error;
- (BOOL)scrubPool:(NSError **)error;
- (BOOL)splitPool:(NSError **)error;

@end
