//
//  ZFSNVList.h
//  ZFS Utility
//
//  Created by Etienne on 29/07/2018.
//  Copyright © 2018 Etienne Samson. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <sys/nvpair.h>

// Private
@interface ZFSNVList : NSObject <NSCopying>

@property (readonly,getter=isEmpty) BOOL empty;

+ (instancetype)listWithNVList:(nvlist_t *)list;
- (instancetype)initWithNVList:(nvlist_t *)list owned:(BOOL)owned NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

- (ZFSNVList *)lookupListWithCString:(const char *)name;
- (NSArray <ZFSNVList *> *)lookupListArrayWithCString:(const char *)name;

@end

@interface ZFSNVList (NSDictionaryInterface)
- (NSEnumerator<NSString *> *)keyEnumerator;
- (id)objectForKeyedSubscript:(NSString *)name;
- (NSArray <NSString *> *)allKeys;
@end
