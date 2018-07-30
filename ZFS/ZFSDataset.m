//
//  ZFSDataset.m
//  ZFS Utility
//
//  Created by Etienne on 12/05/2016.
//  Copyright © 2016 Etienne Samson. All rights reserved.
//

#import "ZFSDataset.h"

#import "ZFSManager_Private.h"

NSString *ZFSDatasetStringFromType(ZFSDatasetType type)
{
	char *types[] = {
		NULL,
		"Filesystem",
		"Snapshot",
		"Volume",
		"Pool",
		"Bookmark",
	};
	return @(types[type]);
}

@interface ZFSDataset ()

@property (readonly, assign) zfs_handle_t *zfs_handle;

@end

@implementation ZFSDataset

- (instancetype)initWithHandle:(zfs_handle_t *)handle
{
	NSParameterAssert(handle != nil);

	self = [super init];
	if (!self) return nil;

	_zfs_handle = handle;

	return self;
}

- (void)dealloc
{
	zfs_close(_zfs_handle);
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ %p fullname: \"%@\" type: \"%@\">", self.className, self, self.fullName, ZFSDatasetStringFromType(self.type)];
}

- (ZFSDatasetType)type
{
	return (ZFSDatasetType)zfs_get_type(self.zfs_handle);
}

- (NSString *)fullName
{
	return @(zfs_get_name(self.zfs_handle));
}

- (ZFSPool *)pool
{
	return nil;
}

- (NSString *)name
{
	NSString *name = self.fullName;
	NSRange slash = [name rangeOfString:@"/"];
	if (slash.location != NSNotFound) {
		name = [name substringFromIndex:(slash.location + 1)];
	}
	return name;
}

@end

@implementation ZFSDataset (ZFSLowLevel)

- (BOOL)_getProperty:(zfs_prop_t)property error:(NSError **)error
{
//	zfs_prop_get(self.zfs_handle, <#zfs_prop_t#>, <#char *#>, <#size_t#>, <#zprop_source_t *#>, <#char *#>, <#size_t#>, <#boolean_t#>)
	return NO;
}

@end
