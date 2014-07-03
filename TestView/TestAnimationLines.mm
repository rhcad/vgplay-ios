//
//  TestAnimationLines.mm
//
//  Created by Zhang Yungui on 14-7-3.
//  Copyright (c) 2014, https://github.com/touchvg/vgplay-ios
//

#import "TestAnimationLines.h"
#include "mgshapes.h"

@implementation TestAnimationLines

- (BOOL)initProvider:(GiFrame *)frame {
    return YES;
}

- (int)provideFrame:(GiFrame)frame {
    return 0;
}

- (void)onProvideEnded:(GiFrame)frame {
}

@end
