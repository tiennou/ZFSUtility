//
//  ZFSPool.m
//  ZFS Utility
//
//  Created by Etienne on 11/06/2015.
//  Copyright (c) 2015 Etienne Samson. All rights reserved.
//

#import "ZFSManager_Private.h"

#import "ZFSPool.h"
#import "ZFSDrive.h"
#import "ZFSDriveSet.h"

@interface ZFSPool ()
@property (readonly, assign) zpool_handle_t *zpool_handle;
@end

@implementation ZFSPool

- (instancetype)initWithHandle:(zpool_handle_t *)handle
{
	NSParameterAssert(handle != nil);

	self = [super init];
	if (!self) return nil;

	_zpool_handle = handle;

	return self;
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ %p name: \"%@\" guid: %@>", self.className, self, self.name, @(self.guid)];
}

- (NSString *)name
{
	return @(zpool_get_name(self.zpool_handle));
}

- (uint64_t)guid
{
	return zpool_get_prop_int(self.zpool_handle, ZPOOL_PROP_GUID, NULL);
}

- (uint64_t)size
{
	return zpool_get_prop_int(self.zpool_handle, ZPOOL_PROP_SIZE, NULL);
}

- (uint64_t)alloc
{
	return zpool_get_prop_int(self.zpool_handle, ZPOOL_PROP_ALLOCATED, NULL);
}

- (uint64_t)free
{
	return zpool_get_prop_int(self.zpool_handle, ZPOOL_PROP_FREE, NULL);
}

- (ZFSZPoolState)state
{
	return (ZFSZPoolState)zpool_get_state(self.zpool_handle);
}

- (BOOL)status:(ZFSZPoolStatus *)status message:(NSString **)message error:(NSError **)error;
{
	NSParameterAssert(status != NULL);

	char *msg;
	zpool_errata_t errata;

	*status = zpool_get_status(self.zpool_handle, &msg, &errata);

	if (message) *message = @(msg);

	return YES;
}

- (ZFSNVList *)configWithError:(NSError **)error
{
	nvlist_t *list = zpool_get_config(self.zpool_handle, NULL);
	if (list == NULL) {
		if (error) *error = [ZFSError errorWithZFSHandle:zpool_get_handle(self.zpool_handle)];
		return nil;
	}
	return [ZFSNVList listWithNVList:list];

}

- (ZFSDriveSet *)drives
{
	NSError *error;
	ZFSNVList *config = [self configWithError:&error];
	if (!config) {
		NSLog(@"error: %@", error);
		return nil;
	}

	ZFSNVList *vdevs = [config lookupListWithCString:ZPOOL_CONFIG_VDEV_TREE];
	NSLog(@"vdevs: %@", vdevs);

	NSArray <ZFSNVList *> *children = [vdevs lookupListArrayWithCString:ZPOOL_CONFIG_CHILDREN];
	for (ZFSNVList *child in children) {
		NSLog(@"child: %@", child);
	}

	NSArray <ZFSNVList *> *caches = [config lookupListWithCString:ZPOOL_CONFIG_L2CACHE];
	NSArray <ZFSNVList *> *spares = [config lookupListWithCString:ZPOOL_CONFIG_SPARES];

	return config;
}

@end

@implementation ZFSPool (ZFSLowLevel)

- (NSString *)_getProperty:(zpool_prop_t)property error:(NSError **)error
{
	char value[ZPOOL_MAXPROPLEN];
	zprop_source_t source;

	int res = zpool_get_prop(self.zpool_handle, property, (char *)&value, sizeof(value), &source, false);
	if (res != 0) {
		if (error) *error = [ZFSError errorWithZFSHandle:zpool_get_handle(self.zpool_handle)];
		return nil;
	}
	NSLog(@"zpool_prop_t: %s (%d) = %s \"%s\"", zpool_prop_to_name(property), property, value, zpool_prop_values(property));

	return @(value);
}


@end
