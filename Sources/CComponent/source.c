//
//  source.c
//  The FinderItem Module - C Component
//
//  Created by Vaida on 6/6/23.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

#include "fts.h"
#include <CoreFoundation/CoreFoundation.h>


int cmp(const FTSENT **l, const FTSENT **r) {
    char* lhs = (char*) (*l)->fts_name;
    char* rhs = (char*) (*r)->fts_name;
    
    CFStringRef lhsString = CFStringCreateWithCString(NULL, lhs, kCFStringEncodingUTF8);
    CFStringRef rhsString = CFStringCreateWithCString(NULL, rhs, kCFStringEncodingUTF8);
    
    int returnValue = (int) CFStringCompareWithOptionsAndLocale(lhsString, rhsString, CFRangeMake(0, strlen(lhs)), kCFCompareNumerically | kCFCompareWidthInsensitive, nil);
    
    CFRelease(lhsString);
    CFRelease(rhsString);
    
    return returnValue;
}

FTS* fts_cmp_open(char * const * path, int options, int ordered) {
    return fts_open(path, options, ordered != 0 ? cmp : NULL);
}
