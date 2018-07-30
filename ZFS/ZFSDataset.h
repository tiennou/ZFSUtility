//
//  ZFSDataset.h
//  ZFS Utility
//
//  Created by Etienne on 12/05/2016.
//  Copyright © 2016 Etienne Samson. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ZFSPool;

typedef NS_ENUM(NSUInteger, ZFSDatasetType) {
	ZFSDatasetTypeFilesystem = (1 << 0),
	ZFSDatasetTypeSnapshot = (1 << 1),
	ZFSDatasetTypeVolume = (1 << 2),
	ZFSDatasetTypePool = (1 << 3),
	ZFSDatasetTypeBookmark = (1 << 4),
};
extern NSString *ZFSDatasetStringFromType(ZFSDatasetType type);

@interface ZFSDataset : NSObject

@property (readonly, retain) ZFSPool *pool;

@property (readonly, retain) NSString *name;
@property (readonly, retain) NSString *fullName;

@property (readonly, assign) NSUInteger used;
@property (readonly, assign) NSUInteger available;
@property (readonly, assign) NSUInteger refer;
@property (readonly, retain) NSString *path;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
