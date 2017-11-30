//
//  Foo.m
//  GokoUniversalLog
//
//  Created by Goko on 30/11/2017.
//  Copyright © 2017 Goko. All rights reserved.
//

#import "Foo.h"
#import "Bar.h"

@implementation Foo

-(NSArray *)array{
    if (nil == _array) {
        _array = @[[Bar new],[Bar new],@{@"bar":[Bar new]}];
    }
    return _array;
}
-(int)width{
    return 10;
}
@end
