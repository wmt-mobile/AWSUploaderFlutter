//
//  DxCaptchaFlutterPlugin.m
//
//  Created by Ying Wang on 2023/12/08.
//

#import "DxCaptchaFlutterPlugin.h"
#import <DXRiskStaticWithIDFA/DXRiskManager.h>
#import <DingxiangCaptchaSDKStatic/DXCaptchaView.h>
#import <DingxiangCaptchaSDKStatic/DXCaptchaDelegate.h>

NSString * const DxFlutterMethodCallBadRequest = @"DxFlutterMethodCallBadRequest";

@interface DxCaptchaFlutterPlugin () <DXCaptchaDelegate, UIGestureRecognizerDelegate>

@property(strong, readonly) FlutterMethodChannel *channel;
@property(strong) NSDictionary *launchOptions;
@property(strong, nonatomic) UIView *overlayView;
@property(strong, nonatomic) UIActivityIndicatorView *activityIndicator;
@property(strong, nonatomic) DXCaptchaView *captchaView;

@end

@implementation DxCaptchaFlutterPlugin
- (instancetype)initWithChannel:(FlutterMethodChannel *)channel {
    self = [super init];
    if (self) {
        _channel = channel;
    }
    return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"plugins.kjxbyz.com/dxcaptcha_flutter_plugin"
            binaryMessenger:[registrar messenger]];
  DxCaptchaFlutterPlugin* instance = [[DxCaptchaFlutterPlugin alloc] initWithChannel:channel];
  [registrar addApplicationDelegate:instance];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"show" isEqualToString:call.method]) {
    id arguments = call.arguments;
    if (arguments == nil) {
      NSLog(@"顶象验证码配置为空");
      result([FlutterError errorWithCode:DxFlutterMethodCallBadRequest message:@"顶象验证码配置为空" details:nil]);
      return;
    }

    if (![arguments isKindOfClass: NSMutableDictionary.class]) {
      NSLog(@"顶象验证码配置必须为字典类型");
      result([FlutterError errorWithCode:DxFlutterMethodCallBadRequest message:@"顶象验证码配置必须为字典类型" details:nil]);
      return;
    }

    NSMutableDictionary *config = (NSMutableDictionary *) arguments;
    id appId = [config objectForKey:@"appId"];
    id language = [config objectForKey:@"language"];
    if (appId == nil || [@"" isEqualToString:appId]) {
      NSLog(@"顶象验证码配置中appId字段为空");
      result([FlutterError errorWithCode:DxFlutterMethodCallBadRequest message:@"顶象验证码配置中appId字段为空" details:nil]);
      return;
    }

    if (language == nil || [@"" isEqualToString:language]) {
      NSLog(@"顶象验证码配置中language字段为空");
      language = @"en";
    }

    UIViewController* viewController = [self topViewController];
    UIView* view = viewController.view;

    CGRect frame = CGRectMake(view.center.x - 150, view.center.y - 100, 300, 200);
    self.captchaView = [[DXCaptchaView alloc] initWithConfig:config delegate:self frame:frame];
    self.captchaView.tag = 1234;

    // tap
    UITapGestureRecognizer* gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap)];

    // overlay
    self.overlayView = [[UIView alloc] init];
    self.overlayView.frame = view.bounds;
    self.overlayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    [self.overlayView addGestureRecognizer:gestureRecognizer];
    [view addSubview:self.overlayView];

    // loading view
    UIView* loadingView = [[UIView alloc] init];
    loadingView.frame = CGRectMake(0, 0, 80, 80);
    loadingView.center = self.overlayView.center;
    loadingView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.7];
    loadingView.clipsToBounds = true;
    loadingView.layer.cornerRadius = 10;

    // loading indicator
    self.activityIndicator = [[UIActivityIndicatorView alloc] init];
    self.activityIndicator.frame = CGRectMake(0, 0, 40, 40);
    self.activityIndicator.center = CGPointMake(loadingView.frame.size.width / 2,
                                           loadingView.frame.size.height / 2);
    self.activityIndicator.hidesWhenStopped = YES;
    self.activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;

    [loadingView addSubview:self.activityIndicator];
    [self.overlayView addSubview:loadingView];
    [self.activityIndicator startAnimating];
    [view addSubview:self.captchaView];

    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void) captchaView:(DXCaptchaView *)view didReceiveEvent:(DXCaptchaEventType)eventType arg:(NSDictionary *)dict {
  switch(eventType) {
    case DXCaptchaEventReady:
    case DXCaptchaEventLoadFail:
    {
      [self.activityIndicator stopAnimating];
      break;
    }
    case DXCaptchaEventSuccess:
    {
      NSLog(@"dxcaptcha success");
      [self.captchaView removeFromSuperview];
      [self.overlayView removeFromSuperview];
      NSString *token = dict[@"token"];
      NSLog(@"token: %@", token);
      [self.channel invokeMethod: @"success" arguments: dict];
      break;
    }
    case DXCaptchaEventFail:
    {
      NSLog(@"dxcaptcha failure");
      [self.captchaView removeFromSuperview];
      [self.overlayView removeFromSuperview];
      [self.channel invokeMethod: @"error" arguments: dict];
      break;
    }
    default:
      break;
  }
}

- (void)handleTap {
  NSLog(@"[DxCaptchaFlutterPlugin]: handleTap");
}

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
  return NO;
}

- (UIViewController *)topViewController {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
  // TODO(stuartmorgan) Provide a non-deprecated codepath. See
  // https://github.com/flutter/flutter/issues/104117
  return [self topViewControllerFromViewController:[UIApplication sharedApplication]
                                                       .keyWindow.rootViewController];
#pragma clang diagnostic pop
}

/**
 * This method recursively iterate through the view hierarchy
 * to return the top most view controller.
 *
 * It supports the following scenarios:
 *
 * - The view controller is presenting another view.
 * - The view controller is a UINavigationController.
 * - The view controller is a UITabBarController.
 *
 * @return The top most view controller.
 */
- (UIViewController *)topViewControllerFromViewController:(UIViewController *)viewController {
  if ([viewController isKindOfClass:[UINavigationController class]]) {
    UINavigationController *navigationController = (UINavigationController *)viewController;
    return [self
        topViewControllerFromViewController:[navigationController.viewControllers lastObject]];
  }
  if ([viewController isKindOfClass:[UITabBarController class]]) {
    UITabBarController *tabController = (UITabBarController *)viewController;
    return [self topViewControllerFromViewController:tabController.selectedViewController];
  }
  if (viewController.presentedViewController) {
    return [self topViewControllerFromViewController:viewController.presentedViewController];
  }
  return viewController;
}

@end
