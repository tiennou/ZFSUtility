//
//  Test.m
//  ZFS Utility
//
//  Created by Etienne on 28/07/2018.
//  Copyright © 2018 Etienne Samson. All rights reserved.
//

#import <Foundation/Foundation.h>

#include <libzfs.h>

static libzfs_handle_t *handle;

int main(int argc, char **argv)
{
	handle = libzfs_init();


	libzfs_fini(handle);
}

