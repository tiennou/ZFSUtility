//
//  ESError.h
//  ESError
//
//  Created by Etienne on 11/07/13.
//  Copyright (c) 2013 Etienne. All rights reserved.
//

#import <Foundation/NSError.h>

NS_ASSUME_NONNULL_BEGIN

#ifdef NS_BLOCKS_AVAILABLE
typedef BOOL (^BErrorRecoveryBlock)(NSError *error);
#endif

@interface NSError (ESErrorExtensions)

/** Build an error with domain, code, description and failure reason */
+ (instancetype)es_errorWithDomain:(NSString *)domain code:(NSInteger)code description:(NSString *)desc failureReason:(NSString *)reason;

/** Build an error with domain, code, description, failure reason and underlying error */
+ (instancetype)es_errorWithDomain:(NSString *)domain code:(NSInteger)code description:(NSString *)desc failureReason:(NSString *)reason underlyingError:(nullable NSError *)error;

/**
 * Build an error with domain, code, description, failure reason, underlying error and additional user info.
 *
 * Note: the values used as description & failure reason will override anything set in the user info.
 */
+ (instancetype)es_errorWithDomain:(NSString *)domain code:(NSInteger)code description:(NSString *)desc failureReason:(NSString *)reason underlyingError:(nullable NSError *)error userInfo:(nullable NSDictionary *)userInfo;

@end

/**
 * An "lazier to use" NSError subclass.
 *
 * This subclass uses "inheritance" to describe domains, so you're supposed to
 * subclass it (at least once), and override +errorDomain. Then you can
 * use the subclass as you would use NSError, and the domain will automatically
 * be populated.
 *
 * Do note that the lazy part comes from not being able to specify the code that
 * will be used (the default is -1, but can be overriden too.
 */
@interface ESError : NSError

/**
 * Default error domain
 *
 * You're supposed to subclass ESError at least once for each of your domains,
 * and override this method.
 */
+ (NSString *)errorDomain;

/**
 * Default error code.
 *
 * Can be overriden by subclasses.
 */
+ (NSInteger)defaultCode;

/**
 * Helper for error creation.
 *
 * @see errorWithDescription:failureReason:underlyingError:userInfo:
 */
+ (NSError *)errorWithDescription:(NSString *)description failureReason:(NSString *)failureReason;

/**
 * Helper for error creation, with user info.
 *
 * @see errorWithDescription:failureReason:underlyingError:userInfo:
 */
+ (NSError *)errorWithDescription:(NSString *)description failureReason:(NSString *)failureReason userInfo:(nullable NSDictionary *)userInfo;

/**
 * Helper for error creation, with underlying error.
 *
 * @see errorWithDescription:failureReason:underlyingError:userInfo:
 */
+ (NSError *)errorWithDescription:(NSString *)description failureReason:(NSString *)failureReason underlyingError:(nullable NSError *)underError;

/**
 * Helper for error creation, with underlying error and user info.
 *
 * This uses a @p 0 error code and the @p errorDomain domain as defaults.
 *
 * @notes
 * The values set as @p description, @p failureReason and @p underlyingError are
 * used in priority over those in the @p userInfo dictionary (if any).
 *
 * @param description     A quick description of the error.
 * @param failureReason   A more verbose explanation.
 * @param underlyingError An error to set as the underlying error.
 * @param userInfo        A dictionary to use as the error userInfo.
 *
 * @return A newly initialized NSError instance.
 */
+ (NSError *)errorWithDescription:(NSString *)description failureReason:(NSString *)failureReason underlyingError:(nullable NSError *)underError userInfo:(nullable NSDictionary *)userInfo;

@end

/**
 * Easily handle NSError double-pointers.
 *
 * @param error           The error parameter to fill.
 * @param description     A quick description of the error.
 * @param failureReason   A more verbose explanation.
 * @param underlyingError An error to set as the underlying error.
 *
 * @return NO.
 */
BOOL ESReturnError(NSError **error, NSString *description, NSString *failureReason, NSError * __nullable underlyingError);

/**
 * Helper function for easily handling NSError double-pointers.
 *
 * @param error         The error parameter to fill.
 * @param description   A quick description of the error.
 * @param failureReason A more verbose explanation.
 * @param userInfo      A dictionary to use as the error userInfo.
 *
 * @return NO.
 */
BOOL ESReturnErrorWithUserInfo(NSError **error, NSString *description, NSString *failureReason, NSDictionary * _Nullable userInfo);

/**
 * Helper function for easily handling NSError double-pointers.
 *
 * @param error   The error parameter to fill.
 * @param builder A block responsible to create a valid NSError object.
 *
 * @return NO.
 */
BOOL ESReturnErrorWithBuilder(NSError **error, NSError * (^errorBuilder)(void));


NS_ASSUME_NONNULL_END
