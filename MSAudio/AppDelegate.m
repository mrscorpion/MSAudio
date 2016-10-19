//
//  AppDelegate.m
//  MSAudio
//
//  Created by mr.scorpion on 2016/10/19.
//  Copyright © 2016年 mr.scorpion. All rights reserved.
//

#import "AppDelegate.h"
#import <MediaPlayer/MediaPlayer.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // 耳机线控按键的监控
    
//    // iOS7.1 前处理
//    // 1. 启用远程事件接收
//    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
//    [[UIApplication sharedApplication] becomeFirstResponder];
    
    
    // iOS7.1 后处理
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self remoteControlEventHandler];
    return YES;
}

//#pragma mark - iOS7.1 前处理
//// 2. 第一响应者 STEP2： 响应远程音乐播放控制消息
//- (BOOL)canBecomeFirstResponder
//{
//    return YES;
//}
//// received remote event
//- (void)remoteControlReceivedWithEvent:(UIEvent *)event
//{
//    NSLog(@"event tyipe:::%ld   subtype:::%ld",(long)event.type,(long)event.subtype);
//    //type==2  subtype==单击暂停键：103，双击暂停键104
//    switch (event.subtype) {
//            
//        case UIEventSubtypeRemoteControlPlay:
//        {
//            // 播放
//            NSLog(@"RemoteControlEvents: play 播放");
//        }
//            break;
//        case UIEventSubtypeRemoteControlPause:
//        {
//            // 暂停
//            NSLog(@"RemoteControlEvents: pause 暂停");
//        }
//            break;
//        case UIEventSubtypeRemoteControlStop:
//        {
//            // 停止
//            NSLog(@"RemoteControlEvents: stop 停止");
//        }
//            break;
//        case UIEventSubtypeRemoteControlTogglePlayPause:
//        {
//            //单击暂停键：103
//            NSLog(@"单击暂停键：103 耳机线控播放暂停");
//            // 耳机线控播放暂停（操作：按耳机线控中间按钮一下）
////            NSLog(@"RemoteControlEvents: TogglePlayPause");
//        }
//            break;
//        case UIEventSubtypeRemoteControlNextTrack:
//        {
//            //双击暂停键：104
//            NSLog(@"双击暂停键：104 下一曲");
//            // 下一曲（操作：按耳机线控中间按钮两下）
////            NSLog(@"RemoteControlEvents: playModeNext");
//        }
//            break;
//        case UIEventSubtypeRemoteControlPreviousTrack:
//        {
//            NSLog(@"三击暂停键：105 上一曲");
//            // 上一曲（操作：按耳机线控中间按钮三下）
////            NSLog(@"RemoteControlEvents: playPrev");
//        }
//            break;
//        case UIEventSubtypeRemoteControlBeginSeekingBackward:
//        {
//            NSLog(@"按耳机线控中间按钮两下到了\"-\"位置，不放：106");
//            // 快退停止（操作：按耳机线控中间按钮三下到了"+" 快退的位置松开）
//            //            NSLog(@"RemoteControlEvents: end seeking backward");
//        }
//        case UIEventSubtypeRemoteControlEndSeekingBackward:
//        {
//            NSLog(@"按耳机线控中间按钮两下到了\"-\"位置，松开时：107 快退停止");
//            // 快退停止（操作：按耳机线控中间按钮三下到了"+" 快退的位置松开）
//            //            NSLog(@"RemoteControlEvents: end seeking backward");
//        }
//            break;
//        case UIEventSubtypeRemoteControlBeginSeekingForward:
//        {
//            NSLog(@"按耳机线控中间按钮两下到了\"-\"位置 不放：108");
//        }
//            break;
//        case UIEventSubtypeRemoteControlEndSeekingForward:
//        {
//            NSLog(@"按耳机线控中间按钮两下到了\"-\"位置，松开时：109  快进停止");
//            // 快进停止（操作：按耳机线控中间按钮两下到了"-" 快进的位置松开）
////            NSLog(@"RemoteControlEvents: end seeking forward");
//        }
//            break;
//        default:
//            break;
//    }
//}



#pragma mark - iOS7.1 后处理
// STEP2： 响应远程音乐播放控制消息
- (void)remoteControlEventHandler
{
    // 直接使用 sharedCommandCenter 获取 MPRemoteCommandCenter 实例
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    
    // 启用播放命令 (锁屏界面和上拉快捷功能菜单处的播放按钮触发的命令)
    commandCenter.playCommand.enabled = YES;
    // 为播放命令添加响应事件, 在点击后触发
    [commandCenter.playCommand addTarget:self action:@selector(playAction:)];
    
    // 播放, 暂停, 上下曲的命令默认都是启用状态, 即enabled默认为YES
    // 为暂停, 上一曲, 下一曲分别添加对应的响应事件
    [commandCenter.pauseCommand addTarget:self action:@selector(pauseAction:)];
    [commandCenter.previousTrackCommand addTarget:self action:@selector(previousTrackAction:)];
    [commandCenter.nextTrackCommand addTarget:self action:@selector(nextTrackAction:)];
    
    // 启用耳机的播放/暂停命令 (耳机上的播放按钮触发的命令)
    commandCenter.togglePlayPauseCommand.enabled = YES;
    // 为耳机的按钮操作添加相关的响应事件
    [commandCenter.togglePlayPauseCommand addTarget:self action:@selector(playOrPauseAction:)];
}
- (void)playAction:(MPRemoteCommand *)playCommand
{
    NSLog(@"playCommand");
}
- (void)pauseAction:(MPRemoteCommand *)pauseCommand
{
    NSLog(@"pauseCommand");
}
- (void)previousTrackAction:(MPRemoteCommand *)previousTrackCommand
{
    NSLog(@"previousTrackCommand");
}
- (void)nextTrackAction:(MPRemoteCommand *)nextTrackCommand
{
    NSLog(@"nextTrackCommand");
}
- (void)playOrPauseAction:(MPRemoteCommand *)togglePlayPauseCommand
{
    NSLog(@"togglePlayPauseCommand");
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
