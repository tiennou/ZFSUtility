//
//  ZFSNVList.m
//  ZFS Utility
//
//  Created by Etienne on 29/07/2018.
//  Copyright © 2018 Etienne Samson. All rights reserved.
//

#import "ZFSNVList.h"

static const struct nv_data_type_info {
	data_type_t type;
	const char *name;
} nv_data_type_info[] = {
	{ DATA_TYPE_UNKNOWN, "unknown" },
	{ DATA_TYPE_BOOLEAN, "boolean" },
	{ DATA_TYPE_BYTE, "byte" },
	{ DATA_TYPE_INT16, "int16" },
	{ DATA_TYPE_UINT16, "uint16" },
	{ DATA_TYPE_INT32, "int32" },
	{ DATA_TYPE_UINT32, "uint32" },
	{ DATA_TYPE_INT64, "int64" },
	{ DATA_TYPE_UINT64, "uint64" },
	{ DATA_TYPE_STRING, "string" },
	{ DATA_TYPE_BYTE_ARRAY, "byte_array" },
	{ DATA_TYPE_INT16_ARRAY, "int16_array" },
	{ DATA_TYPE_UINT16_ARRAY, "uint16_array" },
	{ DATA_TYPE_INT32_ARRAY, "int32_array" },
	{ DATA_TYPE_UINT32_ARRAY, "uint32_array" },
	{ DATA_TYPE_INT64_ARRAY, "int64_array" },
	{ DATA_TYPE_UINT64_ARRAY, "uint64_array" },
	{ DATA_TYPE_STRING_ARRAY, "string_array" },
	{ DATA_TYPE_HRTIME, "hrtime" },
	{ DATA_TYPE_NVLIST, "nvlist" },
	{ DATA_TYPE_NVLIST_ARRAY, "nvlist_array" },
	{ DATA_TYPE_BOOLEAN_VALUE, "boolean_value" },
	{ DATA_TYPE_INT8, "int8" },
	{ DATA_TYPE_UINT8, "uint8" },
	{ DATA_TYPE_BOOLEAN_ARRAY, "boolean_array" },
	{ DATA_TYPE_INT8_ARRAY, "int8_array" },
	{ DATA_TYPE_UINT8_ARRAY, "uint8_array" },
	{ DATA_TYPE_DOUBLE, "double" },
};

static NSString *ZFSNVPairStringFromDataType(data_type_t type)
{
	for (size_t idx = 0; idx <= sizeof(nv_data_type_info) / sizeof(*nv_data_type_info); idx++) {
		struct nv_data_type_info info = nv_data_type_info[idx];
		if (info.type == type) return @(info.name);
	}

	return @"";
}

@interface ZFSNVListEnumerator : NSEnumerator {
	nvlist_t *_list;
	nvpair_t *_pair;
}

@end

@implementation ZFSNVListEnumerator

- (instancetype)initWithNVList:(nvlist_t *)list
{
	NSParameterAssert(list != nil);

	self = [super init];
	if (!self) return nil;

	_list = list;
	_pair = NULL;

	return self;
}

- (void)dealloc
{
	nvlist_free(_list);
}

- (id)nextObject
{
	_pair = nvlist_next_nvpair(_list, _pair);
	if (!_pair) return nil;

	return @(nvpair_name(_pair));
}

@end

@interface ZFSNVList ()

@property (readonly, assign) nvlist_t *nv_list;
@property (readonly, assign) BOOL owned;

@end

@implementation ZFSNVList

+ (instancetype)listWithNVList:(nvlist_t *)list
{
	return [[self alloc] initWithNVList:list owned:YES];
}

- (instancetype)initWithNVList:(nvlist_t *)list owned:(BOOL)owned
{
	self = [super init];
	if (!self) return nil;

	_nv_list = list;
	_owned = owned;

	return self;
}

- (void)dealloc
{
	if (_owned)
		nvlist_free(_nv_list);
}

- (id)copyWithZone:(NSZone *)zone
{
	return [[[self class] alloc] initWithNVList:fnvlist_dup(self.nv_list) owned:YES];
}

- (size_t)size
{
	size_t size;

	int res = nvlist_size(self.nv_list, &size, NV_ENCODE_NATIVE);
	if (res != 0) return 0;

	return size;
}

- (BOOL)isEmpty
{
	return (BOOL)nvlist_empty(self.nv_list);
}

- (id)_objectForNVPair:(nvpair_t *)pair
{
	data_type_t type = nvpair_type(pair);
	const char *name = nvpair_name(pair);

	id value = nil;
	switch (type) {
		case DATA_TYPE_UNKNOWN:
			break;

		case DATA_TYPE_BOOLEAN: {
			boolean_t b = nvlist_lookup_boolean(self.nv_list, name);
			value = [NSNumber numberWithBool:(BOOL)b];
			break;
		}

		case DATA_TYPE_BOOLEAN_VALUE: {
			boolean_t b = fnvlist_lookup_boolean_value(self.nv_list, name);
			value = [NSNumber numberWithBool:(BOOL)b];
			break;
		}

		case DATA_TYPE_BYTE: {
			uchar_t num = fnvlist_lookup_byte(self.nv_list, name);
			value = [NSNumber numberWithChar:num];
			break;
		}

		case DATA_TYPE_INT8: {
			int8_t num = fnvlist_lookup_int8(self.nv_list, name);
			value = [NSNumber numberWithChar:num];
			break;
		}

		case DATA_TYPE_UINT8: {
			uint8 num = fnvlist_lookup_uint8(self.nv_list, name);
			value = [NSNumber numberWithChar:num];
			break;
		}

		case DATA_TYPE_INT16: {
			int16_t num = fnvlist_lookup_int16(self.nv_list, name);
			value = [NSNumber numberWithShort:num];
			break;
		}

		case DATA_TYPE_UINT16: {
			uint16_t num = fnvlist_lookup_uint16(self.nv_list, name);
			value = [NSNumber numberWithUnsignedShort:num];
			break;
		}

		case DATA_TYPE_INT32: {
			int32_t num = fnvlist_lookup_int32(self.nv_list, name);
			value = [NSNumber numberWithInt:num];
			break;
		}

		case DATA_TYPE_UINT32: {
			uint32_t num = fnvlist_lookup_uint32(self.nv_list, name);
			value = [NSNumber numberWithUnsignedInt:num];
			break;
		}

		case DATA_TYPE_INT64: {
			int64_t num = fnvlist_lookup_int64(self.nv_list, name);
			value = [NSNumber numberWithLong:num];
			break;
		}

		case DATA_TYPE_UINT64: {
			uint64_t num = fnvlist_lookup_uint64(self.nv_list, name);
			value = [NSNumber numberWithUnsignedLongLong:num];
			break;
		}

		case DATA_TYPE_STRING: {
			char *string = fnvlist_lookup_string(self.nv_list, name);
			value = @(string);
			break;
		}

		case DATA_TYPE_DOUBLE: {
			double num;
			nvlist_lookup_double(self.nv_list, name, &num);
			value = [NSNumber numberWithDouble:num];
			break;
		}

		case DATA_TYPE_HRTIME: {
			hrtime_t num;
			nvlist_lookup_hrtime(self.nv_list, name, &num);
			value = [NSNumber numberWithUnsignedLongLong:num];
			break;
		}

		case DATA_TYPE_NVLIST: {
			nvlist_t *list = fnvlist_lookup_nvlist(self.nv_list, name);
			value = [[ZFSNVList alloc] initWithNVList:list owned:NO];
			break;
		}

		case DATA_TYPE_BOOLEAN_ARRAY: {
			uint_t count;
			boolean_t *ary;
			nvlist_lookup_boolean_array(self.nv_list, name, &ary, &count);

			value = [NSMutableArray array];
			for (uint_t idx = 0; idx < count; idx++) {
				[(NSMutableArray *)value addObject:[NSNumber numberWithBool:(BOOL)ary[idx]]];
			}
			break;
		}

		case DATA_TYPE_BYTE_ARRAY: {
			uint_t count;
			uchar_t *ary;
			nvlist_lookup_byte_array(self.nv_list, name, &ary, &count);

			value = [NSMutableArray array];
			for (uint_t idx = 0; idx < count; idx++) {
				[(NSMutableArray *)value addObject:[NSNumber numberWithChar:ary[idx]]];
			}
			break;
		}

		case DATA_TYPE_INT8_ARRAY: {
			uint_t count;
			int8_t *ary;
			nvlist_lookup_int8_array(self.nv_list, name, &ary, &count);

			value = [NSMutableArray array];
			for (uint_t idx = 0; idx < count; idx++) {
				[(NSMutableArray *)value addObject:[NSNumber numberWithChar:ary[idx]]];
			}
			break;
		}

		case DATA_TYPE_UINT8_ARRAY: {
			uint_t count;
			uint8_t *ary;
			nvlist_lookup_uint8_array(self.nv_list, name, &ary, &count);

			value = [NSMutableArray array];
			for (uint_t idx = 0; idx < count; idx++) {
				[(NSMutableArray *)value addObject:[NSNumber numberWithUnsignedChar:ary[idx]]];
			}
			break;
		}

		case DATA_TYPE_INT16_ARRAY: {
			uint_t count;
			int16_t *ary;
			nvlist_lookup_int16_array(self.nv_list, name, &ary, &count);

			value = [NSMutableArray array];
			for (uint_t idx = 0; idx < count; idx++) {
				[(NSMutableArray *)value addObject:[NSNumber numberWithShort:ary[idx]]];
			}
			break;
		}

		case DATA_TYPE_UINT16_ARRAY: {
			uint_t count;
			uint16_t *ary;
			nvlist_lookup_uint16_array(self.nv_list, name, &ary, &count);

			value = [NSMutableArray array];
			for (uint_t idx = 0; idx < count; idx++) {
				[(NSMutableArray *)value addObject:[NSNumber numberWithUnsignedShort:ary[idx]]];
			}
			break;
		}

		case DATA_TYPE_INT32_ARRAY: {
			uint_t count;
			int32_t *ary;
			nvlist_lookup_int32_array(self.nv_list, name, &ary, &count);

			value = [NSMutableArray array];
			for (uint_t idx = 0; idx < count; idx++) {
				[(NSMutableArray *)value addObject:[NSNumber numberWithInt:ary[idx]]];
			}
			break;
		}

		case DATA_TYPE_UINT32_ARRAY: {
			uint_t count;
			uint32_t *ary;
			nvlist_lookup_uint32_array(self.nv_list, name, &ary, &count);

			value = [NSMutableArray array];
			for (uint_t idx = 0; idx < count; idx++) {
				[(NSMutableArray *)value addObject:[NSNumber numberWithUnsignedInt:(BOOL)ary[idx]]];
			}
			break;
		}

		case DATA_TYPE_INT64_ARRAY: {
			uint_t count;
			int64_t *ary;
			nvlist_lookup_int64_array(self.nv_list, name, &ary, &count);

			value = [NSMutableArray array];
			for (uint_t idx = 0; idx < count; idx++) {
				[(NSMutableArray *)value addObject:[NSNumber numberWithLong:ary[idx]]];
			}
			break;
		}

		case DATA_TYPE_UINT64_ARRAY: {
			uint_t count;
			uint64_t *ary;
			nvlist_lookup_uint64_array(self.nv_list, name, &ary, &count);

			value = [NSMutableArray array];
			for (uint_t idx = 0; idx < count; idx++) {
				[(NSMutableArray *)value addObject:[NSNumber numberWithUnsignedLongLong:ary[idx]]];
			}
			break;
		}

		case DATA_TYPE_STRING_ARRAY: {
			uint_t count;
			char **ary;
			nvlist_lookup_string_array(self.nv_list, name, &ary, &count);

			value = [NSMutableArray array];
			for (uint_t idx = 0; idx < count; idx++) {
				[(NSMutableArray *)value addObject:@(ary[idx])];
			}
			break;
		}

		case DATA_TYPE_NVLIST_ARRAY: {
			uint_t count;
			nvlist_t **ary;
			nvlist_lookup_nvlist_array(self.nv_list, name, &ary, &count);

			value = [NSMutableArray array];
			for (uint_t idx = 0; idx < count; idx++) {
				ZFSNVList *list = [[ZFSNVList alloc] initWithNVList:ary[idx] owned:NO];
				[(NSMutableArray *)value addObject:list];
			}
			break;
		}
	}
	return value;
}

- (NSEnumerator<NSString *> *)keyEnumerator
{
	return [[ZFSNVListEnumerator alloc] initWithNVList:self.nv_list];
}

- (NSArray <NSString *> *)allKeys
{
	NSMutableArray <NSString *> *keys = [NSMutableArray array];
	for (NSString *key in self.keyEnumerator) {
		[keys addObject:key];
	}
	return keys;
}

- (id)objectForKeyedSubscript:(NSString *)name
{
	nvpair_t *elem = NULL;
	while ((elem = nvlist_next_nvpair(self.nv_list, elem)) != NULL) {
		if (strcmp(nvpair_name(elem), name.UTF8String) == 0) break;
	}

	if (elem != NULL) {
		return [self _objectForNVPair:elem];
	}
	return nil;
}

- (NSString *)descriptionWithLocale:(nullable id)locale
{
	return [self descriptionWithLocale:locale indent:0];
}

- (NSString *)descriptionWithLocale:(nullable id)locale indent:(NSUInteger)level
{
	NSMutableString *string = [NSMutableString string];

	NSMutableString *indentStr = [NSMutableString string];
	for (int ind = 0; ind < level; ind++) {
		[indentStr appendString:@"\t"];
	}

	[string appendFormat:@"%@%@", indentStr, [self description]];

	ZFSNVList *copy = [self copy];

	nvpair_t *pair = NULL;
	while ((pair = nvlist_next_nvpair(copy.nv_list, pair)) != NULL) {
		const char *name = nvpair_name(pair);
		data_type_t type = nvpair_type(pair);

		id value = [copy _objectForNVPair:pair];

		if ([value isKindOfClass:[NSArray class]]) {
			value = [NSString stringWithFormat:@"(%@)", [(NSArray *)value componentsJoinedByString:@", "]];
		}

		[string appendFormat:@"%@\t%s (%@, %d) = %@\n", indentStr, name, ZFSNVPairStringFromDataType(type), type, value];
	}

	return string;
}

- (NSString *)debugDescription
{
	return [self descriptionWithLocale:nil];
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"<%@ %p flags: %d size: %ld empty: %@>\n", self.className, self, nvlist_nvflag(self.nv_list), self.size, (self.isEmpty ? @"YES" : @"NO")];
}

- (ZFSNVList *)lookupListWithCString:(const char *)name
{
	nvlist_t *list;
	int ret = nvlist_lookup_nvlist(self.nv_list, name, &list);
	if (ret != 0) {
		return nil;
	}

	return [[ZFSNVList alloc] initWithNVList:list owned:NO];
}

- (NSArray <ZFSNVList *> *)lookupListArrayWithCString:(const char *)name
{
	uint_t count = 0;
	nvlist_t **ary = NULL;

	int ret = nvlist_lookup_nvlist_array(self.nv_list, name, &ary, &count);
	if (ret != 0) {
		return nil;
	}

	NSMutableArray <ZFSNVList *> *array = [NSMutableArray array];
	for (uint_t idx = 0; idx < count; idx++) {
		ZFSNVList *list = [[ZFSNVList alloc] initWithNVList:ary[idx] owned:NO];
		[array addObject:list];
	}

	return array;
}

@end
