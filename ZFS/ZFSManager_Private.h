//
//  ZFSManager_Private.h
//  ZFS Utility
//
//  Created by Etienne on 11/06/2015.
//  Copyright (c) 2015 Etienne Samson. All rights reserved.
//

#import "ZFSPool.h"
#import "ZFSDataset.h"
#import "ZFSError.h"
#import "ZFSNVList.h"

#import <libzfs.h>

@interface ZFSPool ()

- (instancetype)initWithHandle:(zpool_handle_t *)handle NS_DESIGNATED_INITIALIZER;

@end

@interface ZFSDataset ()

- (instancetype)initWithHandle:(zfs_handle_t *)handle NS_DESIGNATED_INITIALIZER;

@end

@interface ZFSError ()

+ (instancetype)errorWithZFSHandle:(libzfs_handle_t *)handle;

@end
