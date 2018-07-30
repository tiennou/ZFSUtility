//
//  ZFSManager.m
//  ZFS Utility
//
//  Created by Etienne on 11/06/2015.
//  Copyright (c) 2015 Etienne Samson. All rights reserved.
//

#ifdef DA_SUPPORT
#import <DiskArbitration/DiskArbitration.h>
#endif

#import <libzfs.h>

#import "ZFSManager_Private.h"
#import "ZFSError.h"

#import "ZFSManager.h"
#import "ZFSPool.h"
#import "ZFSDataset.h"

#ifdef DA_SUPPORT
static void ZFSManagerDiskAppearedCallback(DADiskRef disk, void *context)
{
	ZFSManager *manager = (__bridge ZFSManager *)context;

	NSDictionary *diskDict = (__bridge_transfer NSDictionary *)DADiskCopyDescription(disk);

	NSLog(@"%@", diskDict);

	dispatch_sync(dispatch_get_main_queue(), ^{
		[manager refresh:NULL];
	});
}

static void ZFSManagerDiskDisappearedCallback(DADiskRef disk, void *context)
{
	ZFSManager *manager = (__bridge ZFSManager *)context;

	NSDictionary *diskDict = (__bridge_transfer NSDictionary *)DADiskCopyDescription(disk);

	NSLog(@"%@", diskDict);

	dispatch_sync(dispatch_get_main_queue(), ^{
		[manager refresh:NULL];
	});
}
#endif

@interface ZFSManager ()
#ifdef DA_SUPPORT
@property (assign) DASessionRef daSession;
@property (retain) dispatch_queue_t daQueue;
#endif
@property (assign, readonly) libzfs_handle_t *zfs_handle;
@property (copy) NSMutableSet <ZFSPool *> *poolSet;
@property (copy) NSMutableSet <ZFSDataset *> *datasetSet;
@end

typedef int (^ZFSPoolIterator)(ZFSPool *pool, NSError *error);
typedef int (^ZFSDatasetIterator)(ZFSDataset *dataset, NSError *error);

@interface ZFSManager (ZFSLowLevel)

- (BOOL)enumeratePools:(NSError **)error block:(ZFSPoolIterator)iterator;
- (BOOL)enumerateDatasets:(NSError **)error block:(ZFSDatasetIterator)iterator;

@end

@implementation ZFSManager

+ (NSSet *)keyPathsForValuesAffectingPools
{
	return [NSSet setWithArray:@[@"poolsByGUID"]];
}

+ (NSSet *)keyPathsForValuesAffectingDatasets
{
	return [NSSet setWithArray:@[@"datasetsByName"]];
}

+ (instancetype)sharedInstance
{
	static dispatch_once_t onceToken;
	static ZFSManager *sharedManager;
	dispatch_once(&onceToken, ^{
		sharedManager = [[[self class] alloc] init];
	});
	return sharedManager;
}

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;

	_zfs_handle = libzfs_init();
	if (!_zfs_handle) {
//		libzfs_error_init(errno);
		return nil;
	}

	_poolSet = [NSMutableSet set];
	_datasetSet = [NSMutableSet set];

#ifdef DA_SUPPORT
	[self registerDiskArbitration];
#endif

    [self refresh:NULL];

    return self;
}

- (void)dealloc
{
	libzfs_fini(_zfs_handle);
#ifdef DA_SUPPORT
	DAUnregisterCallback(_daSession, ZFSManagerDiskAppearedCallback, (__bridge void *)self);
	DAUnregisterCallback(_daSession, ZFSManagerDiskDisappearedCallback, (__bridge void *)self);
#endif

}

#ifdef DA_SUPPORT
- (void)registerDiskArbitration
{
	char *label = NULL;
	asprintf(&label, "ZFSManager %p", self);
	_daQueue = dispatch_queue_create(label, DISPATCH_QUEUE_CONCURRENT);

	_daSession = DASessionCreate(NULL);
	DASessionSetDispatchQueue(_daSession, _daQueue);

	CFDictionaryRef matchingDict = (__bridge CFDictionaryRef)@{(__bridge NSString *)kDADiskDescriptionVolumeKindKey: @"zfs",};

	DARegisterDiskAppearedCallback(_daSession, matchingDict, ZFSManagerDiskAppearedCallback, (__bridge void *)self);
	DARegisterDiskDisappearedCallback(_daSession, matchingDict, ZFSManagerDiskDisappearedCallback, (__bridge void *)self);
}
#endif

- (NSArray *)pools
{
    return [_poolSet allObjects];
}

- (NSArray *)datasets
{
	return [_datasetSet allObjects];
}


- (NSArray <ZFSPool *>*)_loadPools:(NSError **)error
{
	__block NSMutableArray <ZFSPool *> *pools = [NSMutableArray array];
	[self enumeratePools:error block:^int(ZFSPool *pool, NSError *error) {
		if (pool) {
			[pools addObject:pool];
		} else {
			NSLog(@"%@", error);
		}
		return 0;
	}];
	return pools;
}

- (NSArray <ZFSDataset *> *)_loadDatasets:(NSError **)error
{
	NSMutableArray <ZFSDataset *> *datasets = [NSMutableArray array];
	[self enumerateDatasets:error block:^int(ZFSDataset *dataset, NSError *error) {
		if (dataset) {
			[datasets addObject:dataset];
		} else {
			NSLog(@"%@", error);
		}
		return 0;
	}];
	return datasets;
}

- (BOOL)refresh:(NSError **)error
{
	// Refresh zpools
	NSArray <ZFSPool *>*pools = [self _loadPools:error];
	if (!pools) return NO;

	// Keep track of which pools we've seen
	NSMutableSet *stalePools = [NSMutableSet set];

    for (ZFSPool *pool in pools) {
		[_poolSet addObject:pool];
		[stalePools removeObject:pool];
    }

	for (ZFSPool *stalePool in stalePools) {
		[_poolSet removeObject:stalePool];
	}

	NSLog(@"loaded pools: %@", _poolSet);

	NSArray *datasets = [self _loadDatasets:error];
	if (!datasets) return NO;

	NSLog(@"loaded datasets: %@", datasets);

#if 0
	// Refresh filesystems
	table = [ZFSCLIParser parseTable:@"zfs list" arguments:@[@"-Hp"] headers:@[@"name", @"used", @"available", @"refer", @"path"] error:error];
	if (!table) return NO;

	// Keep track of which datasets we've seen
	NSMutableSet *staleDatasets = [NSMutableSet setWithArray:[_datasetsByName allValues]];
	for (NSMutableDictionary *dataset in table) {
		[self refreshDataset:dataset];
	}

	[self willChangeValueForKey:@"datasetsWithName" withSetMutation:NSKeyValueMinusSetMutation usingObjects:staleDatasets];
	for (ZFSDataset *staleDataset in staleDatasets) {
		[_datasetsByName removeObjectForKey:staleDataset.name];
	}
	[self didChangeValueForKey:@"datasetsWithName" withSetMutation:NSKeyValueMinusSetMutation usingObjects:staleDatasets];
#endif

    return YES;
}

@end

@implementation ZFSManager (ZFSLowLevel)

struct zpool_iterator_data {
	ZFSManager *manager __unsafe_unretained;
	ZFSPoolIterator iterator __unsafe_unretained;
};

static int zpool_iterator(zpool_handle_t *pool_handle, void *payload)
{
	struct zpool_iterator_data *data = payload;

	ZFSPool *pool = [[ZFSPool alloc] initWithHandle:pool_handle];
	if (!pool) {
		NSError *error = [ZFSError errorWithDescription:@"Failed to allocate pool object" failureReason:@""];
		data->iterator(nil, error);
	} else {
		data->iterator(pool, nil);
	}

	return 0;
}

- (BOOL)enumeratePools:(NSError **)error block:(ZFSPoolIterator)iterator
{
	struct zpool_iterator_data data = {.manager = self, .iterator = iterator };

	int err = zpool_iter(self.zfs_handle, zpool_iterator, &data);
	if (err != 0 && error) {
		*error = [ZFSError errorWithZFSHandle:self.zfs_handle];
	}

	return (err == 0);
}

struct zfs_iterator_data {
	ZFSManager *manager __unsafe_unretained;
	ZFSDatasetIterator iterator __unsafe_unretained;
};

static int zfs_iterator(zfs_handle_t *zfs_handle, void *payload)
{
	struct zfs_iterator_data *data = payload;

	ZFSDataset *dataset = [[ZFSDataset alloc] initWithHandle:zfs_handle];
	if (!dataset) {
		NSError *error = [ZFSError errorWithDescription:@"Failed to allocate dataset object" failureReason:@""];
		data->iterator(nil, error);
	} else {
		data->iterator(dataset, nil);
	}

	return 0;
}

- (BOOL)enumerateDatasets:(NSError **)error block:(ZFSDatasetIterator)iterator
{
	struct zfs_iterator_data data = {.manager = self, .iterator = iterator };

	int err = zfs_iter_root(self.zfs_handle, zfs_iterator, &data);
	if (err != 0 && error) {
		*error = [ZFSError errorWithZFSHandle:self.zfs_handle];
	}

	return (err == 0);
}

@end
