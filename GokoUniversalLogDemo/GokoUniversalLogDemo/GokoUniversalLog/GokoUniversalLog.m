//
//  GokoUniversalLog.m
//  Jumper
//
//  Created by Goko on 14/11/2017.
//  Copyright © 2017 Goko. All rights reserved.
//


#define GOKO_TOTAL_PARAMS(firstParam) ({\
NSMutableArray * paramArray = [[NSMutableArray alloc]init];\
va_list argList;\
if (firstParam) {\
[paramArray addObject:firstParam];\
va_start(argList, firstParam);\
id tempObject;\
while ((tempObject = va_arg(argList, id))) {\
[paramArray addObject:tempObject];\
}\
va_end(argList);\
}\
paramArray;\
})

#define FORCE_INLINE __inline__ __attribute__((always_inline))



#import <objc/runtime.h>
#import <objc/message.h>
#import "GokoUniversalLog.h"

#pragma mark - GokoUniversalLog ENUM
typedef NS_ENUM (NSUInteger, GokoEncodingNSType) {
    GokoEncodingTypeNSUnknown = 0,
    GokoEncodingTypeNSString,
    GokoEncodingTypeNSMutableString,
    GokoEncodingTypeNSValue,
    GokoEncodingTypeNSNumber,
    GokoEncodingTypeNSDecimalNumber,
    GokoEncodingTypeNSData,
    GokoEncodingTypeNSMutableData,
    GokoEncodingTypeNSDate,
    GokoEncodingTypeNSURL,
    GokoEncodingTypeNSArray,
    GokoEncodingTypeNSMutableArray,
    GokoEncodingTypeNSDictionary,
    GokoEncodingTypeNSMutableDictionary,
    GokoEncodingTypeNSSet,
    GokoEncodingTypeNSMutableSet,
};
/**
 Type encoding's type.
 */
typedef NS_OPTIONS(NSUInteger, GokoEncodingType) {
    GokoEncodingTypeMask       = 0xFF, ///< mask of type value
    GokoEncodingTypeUnknown    = 0, ///< unknown
    GokoEncodingTypeVoid       = 1, ///< void
    GokoEncodingTypeBool       = 2, ///< bool
    GokoEncodingTypeInt8       = 3, ///< char / BOOL
    GokoEncodingTypeUInt8      = 4, ///< unsigned char
    GokoEncodingTypeInt16      = 5, ///< short
    GokoEncodingTypeUInt16     = 6, ///< unsigned short
    GokoEncodingTypeInt32      = 7, ///< int
    GokoEncodingTypeUInt32     = 8, ///< unsigned int
    GokoEncodingTypeInt64      = 9, ///< long long
    GokoEncodingTypeUInt64     = 10, ///< unsigned long long
    GokoEncodingTypeFloat      = 11, ///< float
    GokoEncodingTypeDouble     = 12, ///< double
    GokoEncodingTypeLongDouble = 13, ///< long double
    GokoEncodingTypeObject     = 14, ///< id
    GokoEncodingTypeClass      = 15, ///< Class
    GokoEncodingTypeSEL        = 16, ///< SEL
    GokoEncodingTypeBlock      = 17, ///< block
    GokoEncodingTypePointer    = 18, ///< void*
    GokoEncodingTypeStruct     = 19, ///< struct
    GokoEncodingTypeUnion      = 20, ///< union
    GokoEncodingTypeCString    = 21, ///< char*
    GokoEncodingTypeCArray     = 22, ///< char[10] (for example)
    
    GokoEncodingTypeQualifierMask   = 0xFF00,   ///< mask of qualifier
    GokoEncodingTypeQualifierConst  = 1 << 8,  ///< const
    GokoEncodingTypeQualifierIn     = 1 << 9,  ///< in
    GokoEncodingTypeQualifierInout  = 1 << 10, ///< inout
    GokoEncodingTypeQualifierOut    = 1 << 11, ///< out
    GokoEncodingTypeQualifierBycopy = 1 << 12, ///< bycopy
    GokoEncodingTypeQualifierByref  = 1 << 13, ///< byref
    GokoEncodingTypeQualifierOneway = 1 << 14, ///< oneway
    
    GokoEncodingTypePropertyMask         = 0xFF0000, ///< mask of property
    GokoEncodingTypePropertyReadonly     = 1 << 16, ///< readonly
    GokoEncodingTypePropertyCopy         = 1 << 17, ///< copy
    GokoEncodingTypePropertyRetain       = 1 << 18, ///< retain
    GokoEncodingTypePropertyNonatomic    = 1 << 19, ///< nonatomic
    GokoEncodingTypePropertyWeak         = 1 << 20, ///< weak
    GokoEncodingTypePropertyCustomGetter = 1 << 21, ///< getter=
    GokoEncodingTypePropertyCustomSetter = 1 << 22, ///< setter=
    GokoEncodingTypePropertyDynamic      = 1 << 23, ///< @dynamic
};
static FORCE_INLINE GokoEncodingNSType GokoClassGetNSType(Class cls) {
    if (!cls) return GokoEncodingTypeNSUnknown;
    if ([cls isSubclassOfClass:[NSMutableString class]]) return GokoEncodingTypeNSMutableString;
    if ([cls isSubclassOfClass:[NSString class]]) return GokoEncodingTypeNSString;
    if ([cls isSubclassOfClass:[NSDecimalNumber class]]) return GokoEncodingTypeNSDecimalNumber;
    if ([cls isSubclassOfClass:[NSNumber class]]) return GokoEncodingTypeNSNumber;
    if ([cls isSubclassOfClass:[NSValue class]]) return GokoEncodingTypeNSValue;
    if ([cls isSubclassOfClass:[NSMutableData class]]) return GokoEncodingTypeNSMutableData;
    if ([cls isSubclassOfClass:[NSData class]]) return GokoEncodingTypeNSData;
    if ([cls isSubclassOfClass:[NSDate class]]) return GokoEncodingTypeNSDate;
    if ([cls isSubclassOfClass:[NSURL class]]) return GokoEncodingTypeNSURL;
    if ([cls isSubclassOfClass:[NSMutableArray class]]) return GokoEncodingTypeNSMutableArray;
    if ([cls isSubclassOfClass:[NSArray class]]) return GokoEncodingTypeNSArray;
    if ([cls isSubclassOfClass:[NSMutableDictionary class]]) return GokoEncodingTypeNSMutableDictionary;
    if ([cls isSubclassOfClass:[NSDictionary class]]) return GokoEncodingTypeNSDictionary;
    if ([cls isSubclassOfClass:[NSMutableSet class]]) return GokoEncodingTypeNSMutableSet;
    if ([cls isSubclassOfClass:[NSSet class]]) return GokoEncodingTypeNSSet;
    return GokoEncodingTypeNSUnknown;
}
static FORCE_INLINE BOOL GokoEncodingTypeIsCNumber(GokoEncodingType type) {
    switch (type & GokoEncodingTypeMask) {
        case GokoEncodingTypeBool:
        case GokoEncodingTypeInt8:
        case GokoEncodingTypeUInt8:
        case GokoEncodingTypeInt16:
        case GokoEncodingTypeUInt16:
        case GokoEncodingTypeInt32:
        case GokoEncodingTypeUInt32:
        case GokoEncodingTypeInt64:
        case GokoEncodingTypeUInt64:
        case GokoEncodingTypeFloat:
        case GokoEncodingTypeDouble:
        case GokoEncodingTypeLongDouble: return YES;
        default: return NO;
    }
}

GokoEncodingType GokoEncodingGetType(const char *typeEncoding) {
    char *type = (char *)typeEncoding;
    if (!type) return GokoEncodingTypeUnknown;
    size_t len = strlen(type);
    if (len == 0) return GokoEncodingTypeUnknown;
    
    GokoEncodingType preSelection = 0;
    bool prefix = true;
    while (prefix) {
        switch (*type) {
            case 'r': {
                preSelection |= GokoEncodingTypeQualifierConst;
                type++;
            } break;
            case 'n': {
                preSelection |= GokoEncodingTypeQualifierIn;
                type++;
            } break;
            case 'N': {
                preSelection |= GokoEncodingTypeQualifierInout;
                type++;
            } break;
            case 'o': {
                preSelection |= GokoEncodingTypeQualifierOut;
                type++;
            } break;
            case 'O': {
                preSelection |= GokoEncodingTypeQualifierBycopy;
                type++;
            } break;
            case 'R': {
                preSelection |= GokoEncodingTypeQualifierByref;
                type++;
            } break;
            case 'V': {
                preSelection |= GokoEncodingTypeQualifierOneway;
                type++;
            } break;
            default: { prefix = false; } break;
        }
    }
    
    len = strlen(type);
    if (len == 0) return GokoEncodingTypeUnknown | preSelection;
    
    switch (*type) {
        case 'v': return GokoEncodingTypeVoid | preSelection;
        case 'B': return GokoEncodingTypeBool | preSelection;
        case 'c': return GokoEncodingTypeInt8 | preSelection;
        case 'C': return GokoEncodingTypeUInt8 | preSelection;
        case 's': return GokoEncodingTypeInt16 | preSelection;
        case 'S': return GokoEncodingTypeUInt16 | preSelection;
        case 'i': return GokoEncodingTypeInt32 | preSelection;
        case 'I': return GokoEncodingTypeUInt32 | preSelection;
        case 'l': return GokoEncodingTypeInt32 | preSelection;
        case 'L': return GokoEncodingTypeUInt32 | preSelection;
        case 'q': return GokoEncodingTypeInt64 | preSelection;
        case 'Q': return GokoEncodingTypeUInt64 | preSelection;
        case 'f': return GokoEncodingTypeFloat | preSelection;
        case 'd': return GokoEncodingTypeDouble | preSelection;
        case 'D': return GokoEncodingTypeLongDouble | preSelection;
        case '#': return GokoEncodingTypeClass | preSelection;
        case ':': return GokoEncodingTypeSEL | preSelection;
        case '*': return GokoEncodingTypeCString | preSelection;
        case '^': return GokoEncodingTypePointer | preSelection;
        case '[': return GokoEncodingTypeCArray | preSelection;
        case '(': return GokoEncodingTypeUnion | preSelection;
        case '{': return GokoEncodingTypeStruct | preSelection;
        case '@': {
            if (len == 2 && *(type + 1) == '?')
                return GokoEncodingTypeBlock | preSelection;
            else
                return GokoEncodingTypeObject | preSelection;
        }
        default: return GokoEncodingTypeUnknown | preSelection;
    }
}

static FORCE_INLINE NSNumber *GokoCreateNumberFromProperty(GokoEncodingType type,
                                                           __unsafe_unretained id object,
                                                           NSString * propertyName) {
    switch (type & GokoEncodingTypeMask) {
        case GokoEncodingTypeBool: {
            return @(((bool (*)(id, SEL))(void *) objc_msgSend)((id)object, NSSelectorFromString(propertyName)));
        }
        case GokoEncodingTypeInt8: {
            return @(((int8_t (*)(id, SEL))(void *) objc_msgSend)((id)object, NSSelectorFromString(propertyName)));
        }
        case GokoEncodingTypeUInt8: {
            return @(((uint8_t (*)(id, SEL))(void *) objc_msgSend)((id)object, NSSelectorFromString(propertyName)));
        }
        case GokoEncodingTypeInt16: {
            return @(((int16_t (*)(id, SEL))(void *) objc_msgSend)((id)object, NSSelectorFromString(propertyName)));
        }
        case GokoEncodingTypeUInt16: {
            return @(((uint16_t (*)(id, SEL))(void *) objc_msgSend)((id)object, NSSelectorFromString(propertyName)));
        }
        case GokoEncodingTypeInt32: {
            return @(((int32_t (*)(id, SEL))(void *) objc_msgSend)((id)object, NSSelectorFromString(propertyName)));
        }
        case GokoEncodingTypeUInt32: {
            return @(((uint32_t (*)(id, SEL))(void *) objc_msgSend)((id)object, NSSelectorFromString(propertyName)));
        }
        case GokoEncodingTypeInt64: {
            return @(((int64_t (*)(id, SEL))(void *) objc_msgSend)((id)object, NSSelectorFromString(propertyName)));
        }
        case GokoEncodingTypeUInt64: {
            return @(((uint64_t (*)(id, SEL))(void *) objc_msgSend)((id)object, NSSelectorFromString(propertyName)));
        }
        case GokoEncodingTypeFloat: {
            float num = ((float (*)(id, SEL))(void *) objc_msgSend)((id)object, NSSelectorFromString(propertyName));
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        }
        case GokoEncodingTypeDouble: {
            double num = ((double (*)(id, SEL))(void *) objc_msgSend)((id)object, NSSelectorFromString(propertyName));
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        }
        case GokoEncodingTypeLongDouble: {
            double num = ((long double (*)(id, SEL))(void *) objc_msgSend)((id)object, NSSelectorFromString(propertyName));
            if (isnan(num) || isinf(num)) return nil;
            return @(num);
        }
        default: return nil;
    }
}

/// Add indent to string (exclude first line)
static NSMutableString *GokoDescriptionAddIndent(NSMutableString *desc, NSUInteger indent) {
    for (NSUInteger i = 0, max = desc.length; i < max; i++) {
        unichar c = [desc characterAtIndex:i];
        if (c == '\n') {
            for (NSUInteger j = 0; j < indent; j++) {
                [desc insertString:@"    " atIndex:i + 1];
            }
            i += indent * 4;
            max += indent * 4;
        }
    }
    return desc;
}


#pragma mark - GokoUniversalLog Class @implementation
typedef void(^GokoConvenientBlock)(void);

@implementation GokoUniversalLog

static BOOL GOKO_LOG_ENABLE = YES;

void GOKO_LOG_ENABLE_MODE(GokoConvenientBlock expression){
    if (GOKO_LOG_ENABLE && expression) {
        expression();
    }
}
void GokoLogEnable(BOOL enable){
    GOKO_LOG_ENABLE = enable;
}

#pragma mark - Log Method
__attribute__((overloadable)) void GokoLog(CGFloat value){
    GOKO_LOG_ENABLE_MODE(^{
        NSLog(@"%@",GokoString(value));
    });
}
__attribute__((overloadable)) void GokoLog(CGRect value){
    GOKO_LOG_ENABLE_MODE(^{
        NSLog(@"%@",GokoString(value));
    });
}
__attribute__((overloadable)) void GokoLog(CGPoint value){
    GOKO_LOG_ENABLE_MODE(^{
        NSLog(@"%@",GokoString(value));
    });
}
__attribute__((overloadable)) void GokoLog(CGSize value){
    GOKO_LOG_ENABLE_MODE(^{
        NSLog(@"%@",GokoString(value));
    });
}

__attribute__((overloadable)) void GokoLog(id firstParam, ...){
    NSArray * params = GOKO_TOTAL_PARAMS(firstParam);
    GOKO_LOG_ENABLE_MODE(^{
        [params enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"%@",obj);
        }];
    });
}
__attribute__((overloadable)) void GokoDescriptionLog(id firstParam, ...){
    NSArray * params = GOKO_TOTAL_PARAMS(firstParam);
    GOKO_LOG_ENABLE_MODE(^{
        [params enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSLog(@"%@",GokoString(obj));
        }];
    });
}

#pragma mark - String Method

__attribute__((overloadable)) NSString * GokoString(CGFloat value) {
    NSString * string = @"";
    if (Goko_isIntValue(value)) {
        string = [@(value) stringValue];
    }else{
        string = [NSString stringWithFormat:@"%f",value];
    }
    return string;
}
__attribute__((overloadable)) NSString * GokoString(CGRect value) {
    return NSStringFromCGRect(value);
}
__attribute__((overloadable)) NSString * GokoString(CGPoint value) {
    return NSStringFromCGPoint(value);
}
__attribute__((overloadable)) NSString * GokoString(CGSize value) {
    return NSStringFromCGSize(value);
}
__attribute__((overloadable)) NSString * GokoString(id value){
    return Goko_description(value);
}

#pragma mark - Private Methods

static inline BOOL Goko_isIntValue(CGFloat value){
    NSNumber * numberValue = @(value);
    NSString * stringValue = [numberValue stringValue];
    NSScanner * scanner = [NSScanner scannerWithString:stringValue];
    int intValue;
    return [scanner scanInt:&intValue]&&[scanner isAtEnd];
}

static NSString * Goko_description(NSObject * object){
    static const int kDataDescMaxLength = 100;
    if (!object) return @"<nil>";
    if (object == (id)kCFNull) return @"<null>";
    if (![object isKindOfClass:[NSObject class]]) return [NSString stringWithFormat:@"%@",object];
    
    GokoEncodingNSType classEncodingType = GokoClassGetNSType([object class]);
    switch (classEncodingType) {
        case GokoEncodingTypeNSString:
        case GokoEncodingTypeNSMutableString:{
            return [NSString stringWithFormat:@"\"%@\"",object];
        }
            
        case GokoEncodingTypeNSValue:
        case GokoEncodingTypeNSData:
        case GokoEncodingTypeNSMutableData:{
            NSString * tempStr = object.description;
            if (tempStr.length > kDataDescMaxLength) {
                tempStr = [tempStr substringToIndex:kDataDescMaxLength];
                tempStr = [tempStr stringByAppendingString:@"..."];
            }
            return tempStr;
        }
            
        case GokoEncodingTypeNSNumber:
        case GokoEncodingTypeNSDecimalNumber:
        case GokoEncodingTypeNSDate:
        case GokoEncodingTypeNSURL:{
            return object.description;
        }
            
        case GokoEncodingTypeNSSet:
        case GokoEncodingTypeNSMutableSet:{
            object = [(NSSet *)object allObjects];
        }
            
        case GokoEncodingTypeNSArray:
        case GokoEncodingTypeNSMutableArray:{
            NSArray * array = (NSArray *)object;
            NSMutableString * descStr = @"".mutableCopy;
            NSInteger arrayCount = array.count;
            if (arrayCount == 0) {
                return [descStr stringByAppendingString:@"[]"];
            }else{
                [descStr appendFormat:@"[\n"];
                [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    [descStr appendString:@"    "];
                    [descStr appendString:GokoDescriptionAddIndent(Goko_description(obj).mutableCopy,1)];
                    [descStr appendString:(idx + 1 == arrayCount) ? @"\n" : @";\n"];
                }];
                [descStr appendString:@"]"];
                return descStr;
            }
        }
            
        case GokoEncodingTypeNSDictionary:
        case GokoEncodingTypeNSMutableDictionary:{
            NSDictionary * dic = (NSDictionary *)object;
            NSInteger dicCount = dic.allKeys.count;
            NSMutableString * descStr = @"".mutableCopy;
            if (dicCount == 0) {
                return [descStr stringByAppendingString:@"{}"];
            }else{
                NSString * lastKey = dic.allKeys.lastObject;
                [descStr appendFormat:@"{\n"];
                [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                    [descStr appendString:@"    "];
                    [descStr appendFormat:@"%@ = %@",key,GokoDescriptionAddIndent(Goko_description(obj).mutableCopy, 1)];
                    [descStr appendString:([key isEqualToString:lastKey]) ? @"\n" : @";\n"];
                }];
                [descStr appendString:@"}"];
            }
            return descStr;
        }
            
        default:{
            NSMutableString * descStr = @"".mutableCopy;
            [descStr appendFormat:@"<%@: %p>",object.class,object];
            
            NSMutableArray <NSString *>* allPropertiesName = @[].mutableCopy;
            unsigned int propertyCount = 0;
            objc_property_t *tempProperties = class_copyPropertyList([object class], &propertyCount);
            for (int i = 0; i < propertyCount; i ++) {
                objc_property_t property = tempProperties[i];
                const char * propertyName = property_getName(property);
                [allPropertiesName addObject:[NSString stringWithUTF8String:propertyName]];
            }
            if (allPropertiesName.count == 0) {
                return descStr;
            }
            
            __block unsigned int attrCount;
            __block objc_property_attribute_t *attrs;
            __block GokoEncodingType type = 0;
            
            [descStr appendFormat:@" {\n"];
            [allPropertiesName enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSString *propertyDesc;
                attrs = property_copyAttributeList(tempProperties[idx], &attrCount);
                for (unsigned int i = 0; i < attrCount; i++) {
                    switch (attrs[i].name[0]) {
                        case 'T': {
                            if (attrs[i].value) {
                                type = GokoEncodingGetType(attrs[i].value);
                            }
                        } break;
                        case 'V': {
                        } break;
                        case 'R': {
                            type |= GokoEncodingTypePropertyReadonly;
                        } break;
                        case 'C': {
                            type |= GokoEncodingTypePropertyCopy;
                        } break;
                        case '&': {
                            type |= GokoEncodingTypePropertyRetain;
                        } break;
                        case 'N': {
                            type |= GokoEncodingTypePropertyNonatomic;
                        } break;
                        case 'D': {
                            type |= GokoEncodingTypePropertyDynamic;
                        } break;
                        case 'W': {
                            type |= GokoEncodingTypePropertyWeak;
                        } break;
                        case 'G': {
                            type |= GokoEncodingTypePropertyCustomGetter;
                        } break;
                        case 'S': {
                            type |= GokoEncodingTypePropertyCustomSetter;
                        }
                        default: break;
                    }
                }
                
                if (GokoEncodingTypeIsCNumber(type)) {
                    NSNumber * num = GokoCreateNumberFromProperty(type,object,obj);
                    propertyDesc = num.stringValue;
                }else{
                    SEL getter = NSSelectorFromString(obj);
                    switch (type & GokoEncodingTypeMask) {
                        case GokoEncodingTypeObject:{
                            id value = ((id (*)(id, SEL))(void *) objc_msgSend)((id)object, getter);
                            propertyDesc = Goko_description(value);
                            if (!propertyDesc) {propertyDesc = @"<nil>";}
                        }break;
                        case GokoEncodingTypeClass:{
                            id v = ((id (*)(id, SEL))(void *) objc_msgSend)((id)object, getter);
                            propertyDesc = ((NSObject *)v).description;
                            if (!propertyDesc){propertyDesc = @"<nil>";}
                        }break;
                        case GokoEncodingTypeSEL:{
                            SEL sel = ((SEL (*)(id, SEL))(void *) objc_msgSend)((id)object, getter);
                            if (sel) {propertyDesc = NSStringFromSelector(sel);}
                            else {propertyDesc = @"<NULL>";}
                        }break;
                        case GokoEncodingTypeBlock:{
                            id block = ((id (*)(id, SEL))(void *) objc_msgSend)((id)object, getter);
                            propertyDesc = block ? ((NSObject *)block).description : @"<nil>";
                        }break;
                        case GokoEncodingTypeCArray:
                        case GokoEncodingTypeCString:
                        case GokoEncodingTypePointer:{
                            void *pointer = ((void* (*)(id, SEL))(void *) objc_msgSend)((id)object, getter);
                            propertyDesc = [NSString stringWithFormat:@"%p",pointer];
                        }break;
                        case GokoEncodingTypeStruct:
                        case GokoEncodingTypeUnion:{
                            NSValue *value = [object valueForKey:obj];
                            propertyDesc = value ? value.description : @"{unknown}";
                        }break;
                        default:
                            propertyDesc = @"<unknown>";
                            break;
                    }
                }
                propertyDesc = GokoDescriptionAddIndent(propertyDesc.mutableCopy, 1);
                [descStr appendFormat:@"    %@ = %@",obj, propertyDesc];
                [descStr appendString:(idx + 1 == allPropertiesName.count) ? @"\n" : @";\n"];
            }];
            free(tempProperties);
            free(attrs);
            [descStr appendFormat:@"}"];
            return descStr;
        }
    }
}

@end

