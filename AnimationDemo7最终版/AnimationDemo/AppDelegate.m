//
//  AppDelegate.m
//  AnimationDemo
//
//  Created by 曾家诗 on 16/9/27.
//  Copyright © 2016年 com.lufeifans. All rights reserved.
//

#import "AppDelegate.h"
#import "JSAnimationVC.h"

@interface AppDelegate ()

@property(nonatomic,strong)UIView *view;
@property(nonatomic,strong)UIImageView *launchView;

@property(nonatomic,strong)NSMutableArray *imgArr;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    self.imgArr = [NSMutableArray array];
    
    for (int i = 0; i<4; i++) {
        
        NSString *imgName = [NSString stringWithFormat:@"%d",i+1];
        UIImage *img = [UIImage imageNamed:imgName];
        [self.imgArr addObject:img];
        
    }
    
    JSAnimationVC *VC = [[JSAnimationVC alloc] init];
    VC.imgArr = self.imgArr;
    
    self.window.rootViewController = VC ;
    
    [self.window makeKeyAndVisible];
    
    
    /*
    //获取LaunchScreen.storyborad
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"LaunchScreen" bundle:nil];
    
    //通过使用storyborardID去获取启动页viewcontroller
    UIViewController *viewController = [storyboard instantiateViewControllerWithIdentifier:@"LaunchScreen"];
    NSLog(@"%@",viewController.view.subviews);
    //获取viewController的视图

    self.view = viewController.view;
    //把视图添加到window
    [self.window addSubview:self.view];
    self.launchView = [[UIImageView alloc] initWithFrame:CGRectMake(-20, -20, 400, 700)];
    [self.launchView setImage:[UIImage imageNamed:@"launch.jpg"]];//这边图片可以做网络请求加载图片、视频动画或者其他自定义的引导页
    [self.view addSubview:self.launchView];
    
    //开始设置动画;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:2.0];
    [UIView setAnimationTransition:UIViewAnimationTransitionNone forView:self.view cache:YES];
    [UIView setAnimationDelegate:self];
    //這裡還可以設置回調函數;
    
    //[UIView setAnimationDidStopSelector:@selector(startupAnimationDone:finished:context:)];
    self.launchView.frame = self.view.bounds;
    [UIView commitAnimations];
    //将图片视图推送到前面
    [self.window bringSubviewToFront:self.launchView];
    
    //设置3秒定时触发
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(colseLaunchScreen) userInfo:nil repeats:NO];
    */
    
    
    
    return YES;
}

- (void)colseLaunchScreen {
    if (self.launchView) {
        [self.launchView removeFromSuperview];
        self.launchView = nil;
    }
    if (self.view) {
        [self.view removeFromSuperview];
        self.view = nil;
    }
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
