//
//  Extender.h
//  Chattar
//
//  Created by Igor Khomenko on 7/9/12.
//  Copyright (c) 2012 Injoit. All rights reserved.
//

#import <sys/sysctl.h>
#import <mach/mach_host.h>
#import <malloc/malloc.h>
#import <stdio.h>
#import <string.h>
#include <assert.h>
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <syslog.h>
#import <objc/runtime.h> 
#import <objc/message.h>

// Print free memory
static int printMemoryInfo(){
	int sizefree = 1;
	size_t length;
	int mib[6];
	
	int pagesize;
	mib[0] = CTL_HW;
	mib[1] = HW_PAGESIZE;
	length = sizeof(pagesize);
	if (sysctl(mib, 2, &pagesize, &length, NULL, 0) < 0)
	{
        //	perror("getting page size");
	}
    
	mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
	
	vm_statistics_data_t vmstat;
	if (host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmstat, &count) != KERN_SUCCESS)
	{
        //	printf("Failed to get VM statistics.");
	}
	
	sizefree = (vmstat.free_count * pagesize)/1024/1024;
	
	
	//printf("Free = %d Mb\n", sizefree);
	
	return sizefree;
}