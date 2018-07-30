//
//  ESError.m
//  ESError
//
//  Created by Etienne on 11/07/13.
//  Copyright (c) 2013 Etienne. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ESError.h"

@implementation NSError (ESErrorExtensions)

+ (instancetype)es_errorWithDomain:(NSString *)domain code:(NSInteger)code description:(NSString *)desc failureReason:(NSString *)reason
{
	return [self es_errorWithDomain:domain code:code description:desc failureReason:reason underlyingError:nil userInfo:nil];
}

+ (instancetype)es_errorWithDomain:(NSString *)domain code:(NSInteger)code description:(NSString *)desc failureReason:(NSString *)reason underlyingError:(nullable NSError *)error
{
	return [self es_errorWithDomain:domain code:code description:desc failureReason:reason underlyingError:nil userInfo:nil];
}

+ (instancetype)es_errorWithDomain:(NSString *)domain code:(NSInteger)code description:(NSString *)desc failureReason:(NSString *)reason underlyingError:(nullable NSError *)error userInfo:(nullable NSDictionary *)userInfo
{
	NSParameterAssert(domain != nil);
	NSParameterAssert(desc != nil);
	NSParameterAssert(reason != nil);

	NSMutableDictionary *errorInfo = userInfo ? [userInfo mutableCopy] : [NSMutableDictionary dictionary];

	[errorInfo addEntriesFromDictionary:@{
										  NSLocalizedDescriptionKey: desc,
										  NSLocalizedFailureReasonErrorKey: reason,
										  }];

	if (error) {
		[errorInfo addEntriesFromDictionary:@{ NSUnderlyingErrorKey: error }];
	}

	return [self errorWithDomain:domain code:code userInfo:errorInfo];
}

@end

@implementation ESError

+ (NSString *)errorDomain
{
	NSAssert(NO, @"You must override -errorDomain in your subclass");
	return nil;
}

+ (NSInteger)defaultCode
{
	return -1;
}

+ (NSError *)errorWithDescription:(NSString *)description failureReason:(NSString *)failureReason
{
	return [self es_errorWithDomain:self.errorDomain code:self.defaultCode description:description failureReason:failureReason];
}

+ (NSError *)errorWithDescription:(NSString *)description failureReason:(NSString *)failureReason userInfo:(nullable NSDictionary *)userInfo
{
	return [self es_errorWithDomain:self.errorDomain code:self.defaultCode description:description failureReason:failureReason underlyingError:nil userInfo:userInfo];
}

+ (NSError *)errorWithDescription:(NSString *)description failureReason:(NSString *)failureReason underlyingError:(nullable NSError *)underError
{
	return [self es_errorWithDomain:self.errorDomain code:self.defaultCode description:description failureReason:failureReason underlyingError:underError];
}

+ (NSError *)errorWithDescription:(NSString *)description failureReason:(NSString *)failureReason underlyingError:(nullable NSError *)underError userInfo:(nullable NSDictionary *)userInfo
{
	return [self es_errorWithDomain:self.errorDomain code:self.defaultCode description:description failureReason:failureReason underlyingError:underError userInfo:userInfo];
}

@end
