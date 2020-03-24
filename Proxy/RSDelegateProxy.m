//
//  RSDelegateProxy.m
//  Proxy
//
//  LPF. 2020/3/23.
//  Copyright © 2020 LPF. All rights reserved.
//

#import "RSDelegateProxy.h"
#import <os/lock.h>
#import <libkern/OSAtomic.h>
#import <objc/runtime.h>

static os_unfair_lock _lock = OS_UNFAIR_LOCK_INIT;
static CFMutableDictionaryRef _protocolCache = nil;

@interface RSDelegateProxy ()

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) Protocol *protocol;
@property (nonatomic, strong) NSValue *defaultReturnValue;

@property (nonatomic) CFDictionaryRef signatures;

@end

@implementation RSDelegateProxy

#pragma mark - Init
- (id)initWithDelegate:(id)delegate conformingToProtocol:(Protocol *)protocol defaultReturnValue:(NSValue *)returnValue {
    NSParameterAssert(protocol);
    NSParameterAssert(returnValue == nil || [returnValue isKindOfClass:NSValue.class]);
    if (self) {
        _delegate = delegate;
        _protocol = protocol;
        _defaultReturnValue = returnValue;
    }
    return self;
}


#pragma mark - Must override

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel {
    /// 当 _delegate == nil 时, signature 为 nil;
    NSMethodSignature *signature = [_delegate methodSignatureForSelector:sel];
    if (!signature) {
        signature = CFDictionaryGetValue(self.signatures, sel);
    }
    return signature;
}

- (void)forwardInvocation:(NSInvocation *)invocation {
    // 设置了 _defaultReturnValue 则会被当作返回值.
    if (_defaultReturnValue && strcmp(_defaultReturnValue.objCType, invocation.methodSignature.methodReturnType) == 0) {
        char buffer[invocation.methodSignature.methodReturnLength];
        [_defaultReturnValue getValue:buffer];
        [invocation setReturnValue:&buffer];
    }
}

#pragma mark - Public
- (BOOL)respondsToSelector:(SEL)aSelector {
    return self.delegate && [self.delegate respondsToSelector:aSelector];
}

- (instancetype)copyThatDefaultsTo:(NSValue *)defaultValue {
    return [[self.class alloc] initWithDelegate:_delegate
                           conformingToProtocol:_protocol
                             defaultReturnValue:defaultValue];
}

- (instancetype)copyThatDefaultsToYES {
    return [self copyThatDefaultsTo:@YES];
}

#pragma mark - Private
- (id)forwardingTargetForSelector:(SEL)selector {
    id delegate = self.delegate;
    return [delegate respondsToSelector:selector] ? delegate : self;
}

- (CFDictionaryRef)methodSignatureForProtocol:(Protocol *)protocol {
    os_unfair_lock_lock(&_lock);
    if (!_protocolCache) {
        _protocolCache = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
    }
    /// 从 _protocolCache 中取出 protocol 对应的值.
    CFDictionaryRef signatureCache = CFDictionaryGetValue(_protocolCache, (__bridge const void *)(protocol));

    if (!signatureCache) {
        /// 将协议方法+派生的协议方法定义添加到 protocolCache.
        signatureCache = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
        [self methodSignaturesForProtocol:protocol inDictionary:(CFMutableDictionaryRef)signatureCache];
        CFDictionarySetValue(_protocolCache, (__bridge const void *)(protocol), signatureCache);
        CFRelease(signatureCache);
    }
    
    os_unfair_lock_unlock(&_lock);
    return signatureCache;
}

- (void)methodSignaturesForProtocol:(Protocol *)protocol
                       inDictionary:(CFMutableDictionaryRef)cache {
    
    void (^enumerateRequiredMethods)(BOOL) = ^(BOOL isRequired) {
        unsigned int methodCount;
        struct objc_method_description *descr = protocol_copyMethodDescriptionList(protocol, isRequired, YES, &methodCount);
        for (NSUInteger idx = 0; idx < methodCount; idx++) {
            NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:descr[idx].types];
            NSLog(@"signature name is %@", NSStringFromSelector(descr[idx].name));
            /// 保存到 cache 中.
            CFDictionarySetValue(cache, descr[idx].name, (__bridge const void *)(signature));
        }
        free(descr);
    };
    // 分别获取必须和可选的协议方法.
    enumerateRequiredMethods(NO);
    enumerateRequiredMethods(YES);

    // 捕获一些子协议.
    unsigned int inheritedProtocolCount;
    Protocol *__unsafe_unretained* inheritedProtocols = protocol_copyProtocolList(protocol, &inheritedProtocolCount);
    for (NSUInteger idx = 0; idx < inheritedProtocolCount; idx++) {
        Protocol *aProtocol = inheritedProtocols[idx];
        /// NSObject 协议因为所有类都包含了所以直接跳过
        if ([NSStringFromProtocol(aProtocol) isEqualToString:@"NSObject"]) {
          continue;
        }
        [self methodSignaturesForProtocol:aProtocol inDictionary:cache];
    }
    free(inheritedProtocols);
}

#pragma mark - Getter
- (CFDictionaryRef)signatures {
    if (!_signatures) {
        _signatures = [self methodSignatureForProtocol:_protocol];
    }
    return _signatures;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"<%@: %p delegate:%@ protocol:%@>", self.class, self, self.delegate, self.protocol];
}

@end
