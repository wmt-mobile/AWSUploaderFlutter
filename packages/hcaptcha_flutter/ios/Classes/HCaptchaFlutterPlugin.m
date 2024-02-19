#import "HCaptchaFlutterPlugin.h"

NSString * const HFlutterMethodCallBadRequest = @"HFlutterMethodCallBadRequest";

@interface HCaptchaFlutterPlugin () <UIGestureRecognizerDelegate>

@property(strong, readonly) FlutterMethodChannel *channel;
@property(strong) NSDictionary *launchOptions;
@property(strong, nonatomic) HCaptcha *hCaptcha;
@property(strong, nonatomic) UIView *overlayView;
@property(weak, nonatomic) WKWebView *webView;

@end

@implementation HCaptchaFlutterPlugin
- (instancetype)initWithChannel:(FlutterMethodChannel *)channel {
    self = [super init];
    if (self) {
      _channel = channel;
    }
    return self;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"plugins.kjxbyz.com/hcaptcha_flutter_plugin"
            binaryMessenger:[registrar messenger]];
  HCaptchaFlutterPlugin* instance = [[HCaptchaFlutterPlugin alloc] initWithChannel: channel];
  [registrar addApplicationDelegate:instance];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"show" isEqualToString:call.method]) {
    id arguments = call.arguments;
    if (arguments == nil) {
      NSLog(@"HCaptcha配置为空");
      result([FlutterError errorWithCode:HFlutterMethodCallBadRequest message:@"HCaptcha配置为空" details:nil]);
      return;
    }

    if (![arguments isKindOfClass: NSMutableDictionary.class]) {
      NSLog(@"HCaptcha配置必须为字典类型");
      result([FlutterError errorWithCode:HFlutterMethodCallBadRequest message:@"HCaptcha配置必须为字典类型" details:nil]);
      return;
    }

    NSMutableDictionary *config = (NSMutableDictionary *) arguments;
    id siteKey = [config objectForKey:@"siteKey"];
    id language = [config objectForKey:@"language"];
    if (siteKey == nil || [@"" isEqualToString:siteKey]) {
      NSLog(@"HCaptcha验证码配置中siteKey字段为空");
      result([FlutterError errorWithCode:HFlutterMethodCallBadRequest message:@"HCaptcha验证码配置中siteKey字段为空" details:nil]);
      return;
    }

    if (language == nil || [@"" isEqualToString:language]) {
      NSLog(@"HCaptcha验证码配置中language字段为空");
      language = @"en";
    }

    if (self.hCaptcha == nil) {
      self.hCaptcha = [[HCaptcha alloc] initWithApiKey: siteKey
                                             baseURL: [NSURL URLWithString: @"http://localhost"]
                                             locale: [NSLocale localeWithLocaleIdentifier: language]
                                             size: HCaptchaSizeInvisible
                                             error: nil];
    }

    UIViewController* viewController = [self topViewController];
    UIView* view = viewController.view;

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
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] init];
    activityIndicator.frame = CGRectMake(0, 0, 40, 40);
    activityIndicator.center = CGPointMake(loadingView.frame.size.width / 2,
                                           loadingView.frame.size.height / 2);
    activityIndicator.hidesWhenStopped = YES;
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;

    [loadingView addSubview:activityIndicator];
    [self.overlayView addSubview:loadingView];
    [activityIndicator startAnimating];

    [self.hCaptcha configureWebView:^(WKWebView * _Nonnull webView) {
      CGFloat width = view.bounds.size.width;
      CGFloat height = view.bounds.size.height;
      CGFloat webviewWidth = 325;
      CGFloat webviewHeight = 490;
      webView.frame = CGRectMake((width - webviewWidth)/2, (height - webviewHeight)/2, webviewWidth, webviewHeight);
      self.webView = webView;
    }];

    [self.hCaptcha onEvent:^(enum HCaptchaEvent event, id _Nullable _) {
      NSLog(@"HCaptcha: event=%ld", event);
      dispatch_async(dispatch_get_main_queue(), ^{
        if (event == HCaptchaEventOpen) {
          [activityIndicator stopAnimating];
          [self.channel invokeMethod: @"open" arguments: nil];
        } else if (event == HCaptchaEventError) {
          [activityIndicator stopAnimating];
          [self.channel invokeMethod: @"error" arguments: nil];
        }
      });
    }];

    [self.hCaptcha validateOn:view resetOnError:NO completion:^(HCaptchaResult *result) {
      [self.hCaptcha reset];
      NSError *error = nil;
      NSString *token = [result dematerializeAndReturnError: &error];
      NSLog(@"HCaptcha: token=%@, error=%@", token, [error description]);
      dispatch_async(dispatch_get_main_queue(), ^{
        if (error == nil) {
          NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject: token forKey: @"token"];
          [self.channel invokeMethod: @"success" arguments: dict];
        } else {
          NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObject: [error description] forKey: @"error"];
          [self.channel invokeMethod: @"error" arguments: dict];
        }
      });

      [self.webView removeFromSuperview];
      [self.overlayView removeFromSuperview];
    }];

    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}

- (void)handleTap {
  NSLog(@"[HCaptchaFlutterPlugin]: handleTap");
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
