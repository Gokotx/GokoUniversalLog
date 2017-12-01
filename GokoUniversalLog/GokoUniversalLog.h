//
//  GokoUniversalLog.h
//  Jumper
//
//  Created by Goko on 14/11/2017.
//  Copyright © 2017 Goko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#pragma mark - GokoUniversalLog Class
@interface GokoUniversalLog : NSObject


/**
 Gloable setting for GokoUniversalLog
 
 @param enable YES for enable , NO for disable
 */
void GokoLogEnable(BOOL enable);

__attribute__((overloadable)) void GokoLog(CGFloat value);
__attribute__((overloadable)) void GokoLog(CGRect value);
__attribute__((overloadable)) void GokoLog(CGPoint value);
__attribute__((overloadable)) void GokoLog(CGSize value);


/**
 * Normal Log just like NSLog output
 * Params should be a object
 */
__attribute__((overloadable)) void GokoLog(id firstParam, ...) NS_REQUIRES_NIL_TERMINATION;

__attribute__((overloadable)) void GokoDescriptionLog(id firstParam, ...) NS_REQUIRES_NIL_TERMINATION;


__attribute__((overloadable)) NSString * GokoString(CGFloat value);
__attribute__((overloadable)) NSString * GokoString(CGRect value);
__attribute__((overloadable)) NSString * GokoString(CGPoint value);
__attribute__((overloadable)) NSString * GokoString(CGSize value);
__attribute__((overloadable)) NSString * GokoString(id value);

@end
