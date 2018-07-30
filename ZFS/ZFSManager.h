//
//  ZFSManager.h
//  ZFSManager
//
//  Created by Etienne on 13/05/2016.
//  Copyright © 2016 Etienne Samson. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class ZFSPool;
@class ZFSDataset;

@interface ZFSManager : NSObject

+ (instancetype)sharedInstance;

@property (readonly, copy) NSArray <ZFSPool *> *pools;
@property (readonly, copy) NSArray <ZFSDataset *> *datasets;

- (BOOL)refresh:(NSError **)error;

@end

NS_ASSUME_NONNULL_END
