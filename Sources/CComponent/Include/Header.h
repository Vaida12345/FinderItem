//
//  Header.h
//  The Stratum Module - C Component
//
//  Created by Vaida on 6/6/23.
//  Copyright © 2019 - 2024 Vaida. All rights reserved.
//

#ifndef Header_h
#define Header_h

#include <fts.h>

/// Creates an `FTS` that could traverse a file hierarchy. The files are sorted using `kCFCompareNumerically | kCFCompareWidthInsensitive`.
FTS* fts_cmp_open(char * const * path, int options);

#endif /* Header_h */
