//
//  CFIAppDelegate.m
//  UserDefaultsPerformanceSuite
//
//  Created by Robert Widmann on 3/24/13.
//  Copyright (c) 2013 CodaFi. All rights reserved.
//

#import "CFIAppDelegate.h"
#import "CFIUserDefaults.h"
#include <mach/mach_time.h>
#include <stdint.h>

@implementation CFIAppDelegate

- (void)dealloc
{
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	// Insert code here to initialize your application
	NSString *defaultStr = @"SomeDefaultString";
	[self logCFI];
	[self logNS];
}

- (void)logNS {
	//Warm up the caches with a register and a 10,000 val read in.
	NSString *defaultStr = @"SomeDefaultString";
	[[NSUserDefaults standardUserDefaults]registerDefaults:@{ @"DefaultString" : defaultStr }];

	NSMutableString *keyVal = @"I".mutableCopy;
	for (int i = 0; i < 10000; i++) {
		[[CFIUserDefaults standardUserDefaults]setObject:keyVal forKey:keyVal];
		[keyVal appendString:@"I"];
	}
	
	uint64_t startTime = mach_absolute_time();
	for (int i = 0; i < 10000; i++) {
		[[CFIUserDefaults standardUserDefaults]objectForKey:keyVal];
		[keyVal deleteCharactersInRange:NSMakeRange([keyVal length]-1, 1)];
	}
	uint64_t endTime = mach_absolute_time();
	
	uint64_t elapsedMTU = endTime - startTime;
	mach_timebase_info_data_t info;
	double elapsedNS = (double)elapsedMTU * (double)info.numer / (double)info.denom;
	
	NSLog(@"NS RegisterDefaults: %f", elapsedNS);

}

- (void)logCFI {
	//Warm up the caches with a register and a 10,000 val read in.
	NSString *defaultStr = @"SomeDefaultString";
	[[CFIUserDefaults standardUserDefaults]registerDefaults:@{ @"DefaultString" : defaultStr }];

	NSMutableString *keyVal = @"I".mutableCopy;
	for (int i = 0; i < 10000; i++) {
		[[CFIUserDefaults standardUserDefaults]setObject:keyVal forKey:keyVal];
		[keyVal appendString:@"I"];
	}

	uint64_t startTime = mach_absolute_time();
	for (int i = 0; i < 10000; i++) {
		[[CFIUserDefaults standardUserDefaults]objectForKey:keyVal];
		[keyVal deleteCharactersInRange:NSMakeRange([keyVal length]-1, 1)];
	}
	
	uint64_t endTime = mach_absolute_time();
	
	uint64_t elapsedMTU = endTime - startTime;
	mach_timebase_info_data_t info;
	double elapsedNS = (double)elapsedMTU * (double)info.numer / (double)info.denom;
	
	NSLog(@"CFI RegisterDefaults: %f", elapsedNS);
	
}

@end
