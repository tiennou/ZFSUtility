//
//  ZFSError.h
//  ZFS Utility
//
//  Created by Etienne on 29/07/2018.
//  Copyright © 2018 Etienne Samson. All rights reserved.
//

#import <ZFS/ESError.h>

FOUNDATION_EXPORT NSString * const ZFSErrorDomain;

typedef enum : NSUInteger {
	ZFSErrorParseError = 1,
} ZFSErrorCode;


@interface ZFSError : ESError

@end
