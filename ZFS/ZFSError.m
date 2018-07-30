//
//  ZFSError.m
//  ZFS Utility
//
//  Created by Etienne on 29/07/2018.
//  Copyright © 2018 Etienne Samson. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ZFSError.h"

#import <libzfs.h>

NSString * const ZFSErrorDomain = @"ZFSErrorDomain";
NSString * const libZFSErrorDomain = @"libZFSErrorDomain";

@implementation ZFSError
+ (NSString *)errorDomain
{
	return ZFSErrorDomain;
}

+ (instancetype)errorWithZFSHandle:(libzfs_handle_t *)handle
{

	return [self es_errorWithDomain:libZFSErrorDomain
							   code:libzfs_errno(handle)
						description:@(libzfs_error_action(handle))
					  failureReason:@(libzfs_error_description(handle))];
}

@end
