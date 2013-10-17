//
//  AppDelegate+MemoryWarnings.m
//  CallCenter
//
//  Created by Igor Khomenko on 8/22/13.
//  Copyright (c) 2013 QuickBlox. All rights reserved.
//

#import "AppDelegate+MemoryWarnings.h"

#import <sys/sysctl.h>
#import <mach/mach_host.h>

@implementation ChattARAppDelegate (MemoryWarnings)

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
	
	printf("Free = %d Mb\n", sizefree);
	
	return sizefree;
}

- (void) checkMemory {
	if (printMemoryInfo() <= 3) {
        [self showStartMemoryAlert];
	}
}

// show memory Warning at start app
- (void) showStartMemoryAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Attention","Title of alert")
                                                    message:NSLocalizedString(@"Videu may crash  \n if you don't completely close \n other unused apps.", "Low memory alert")
                                                   delegate:nil
                                          cancelButtonTitle:NSLocalizedString(@"Go on working", "Button text")
                                          otherButtonTitles:nil];
    [alert show];
}

@end
