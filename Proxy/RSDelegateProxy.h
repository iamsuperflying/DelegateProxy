//
//  RSDelegateProxy.h
//  Proxy
//
//  LPF. 2020/3/23.
//  Copyright © 2020 LPF. All rights reserved.
//

#import <Foundation/Foundation.h>

/// 重写 delegate 的 setter, 用来初始化 delegateProxy;
/// 需要声明以下属性:
// @property (nonatomic, strong) RSDelegateProxy<XXXDelegate> delegateProxy;
#define RS_DELEGATE_SETTER_CUSTOM(PROTOCOL_NAME, GETTER, SETTER) \
- (void)SETTER:(id<PROTOCOL_NAME>)delegate { \
_##GETTER = delegate; \
self.GETTER##Proxy = [[RSDelegateProxy<PROTOCOL_NAME> alloc] initWithDelegate:delegate conformingToProtocol:@protocol(PROTOCOL_NAME) defaultReturnValue:nil]; \
}

#define RS_DELEGATE_SETTER(PROTOCOL_NAME) RS_DELEGATE_SETTER_CUSTOM(PROTOCOL_NAME, delegate, setDelegate)

NS_ASSUME_NONNULL_BEGIN

@interface RSDelegateProxy<T> : NSProxy

/// 代理的委托.
@property (nonatomic, weak, readonly) T delegate;

/// delegate 遵循的 protocol.
@property (nonatomic, strong, readonly) Protocol *protocol;

/// 如果未实现方法，则默认的带框原始原语返回值。默认为nil.
@property (nonatomic, strong, readonly) NSValue *defaultReturnValue;

/// 指定的初始化器。 'delegate' 可以为 nil。
/// 'returnValue' 将在返回原始数的方法签名上取消装箱（例如@YES）
/// 与 'returnValue' 中未装箱类型不匹配的方法签名将被忽略。
- (instancetype)initWithDelegate:(nullable id)delegate
            conformingToProtocol:(Protocol *)protocol
              defaultReturnValue:(nullable NSValue *)returnValue;

/// 返回一个对象，该对象将为返回原始值类型的方法返回 ‘defaultValue’。
/// 与“ returnValue”中未装箱类型不匹配的方法签名将被忽略。
- (instancetype)copyThatDefaultsTo:(NSValue *)defaultValue;
- (instancetype)copyThatDefaultsToYES;

@end

NS_ASSUME_NONNULL_END
