#import "AppDelegate.h"

#import "MasterViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];
  self.window = [[UIWindow alloc]
                  initWithFrame:[[UIScreen mainScreen] bounds]];
  self.viewController = [[MasterViewController alloc] init];
  self.window.rootViewController = self.viewController;
  [self.window makeKeyAndVisible];
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  
}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}

- (void)applicationWillEnterForeground:(UIApplication *)application {

}

- (void)applicationDidBecomeActive:(UIApplication *)application {

}

- (void)applicationWillTerminate:(UIApplication *)application {

}

@end
