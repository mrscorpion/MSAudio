//
//  MSAudioVC.m
//  MSAudio
//
//  Created by mr.scorpion on 2016/10/19.
//  Copyright © 2016年 mr.scorpion. All rights reserved.
//

#import "MSAudioVC.h"
#import <AVFoundation/AVFoundation.h>
#import "MSToneGeneratorVC.h"

@interface MSAudioVC ()
@end

@implementation MSAudioVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];

    
//    监测耳机
    if ([self isHeadsetPluggedIn]) {
        NSLog(@"msaudio ==> 有耳机插入");
    }
    [[AVAudioSession sharedInstance] setActive:YES error:nil];//创建单例对象并且使其设置为活跃状态.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(audioRouteChangeListenerCallback:)   name:AVAudioSessionRouteChangeNotification object:nil];//设置通知
    
    
    // 示例2
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(next)];
    [self.view addGestureRecognizer:tap];
}
- (void)next
{
    [self presentViewController:[[MSToneGeneratorVC alloc] init] animated:YES completion:nil];
}


#pragma mark - 检测耳机是否插入
- (BOOL)isHeadsetPluggedIn
{
    AVAudioSessionRouteDescription* route = [[AVAudioSession sharedInstance] currentRoute];
    for (AVAudioSessionPortDescription* desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones])
            return YES;
    }
    return NO;
}

#pragma mark - 实时监测耳机插入和拔出
// 通知方法实现
- (void)audioRouteChangeListenerCallback:(NSNotification*)notification
{
    NSDictionary *interuptionDict = notification.userInfo;
    NSInteger routeChangeReason = [[interuptionDict valueForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
    switch (routeChangeReason) {
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            NSLog(@"AVAudioSessionRouteChangeReasonNewDeviceAvailable");
            [self tipWithMessage:@"msaudio ==> 耳机插入"];
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            NSLog(@"AVAudioSessionRouteChangeReasonOldDeviceUnavailable");
            [self tipWithMessage:@"msaudio ==> 耳机拔出，停止播放操作"];
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            // called at start - also when other audio wants to play
            [self tipWithMessage:@"msaudio ==> AVAudioSessionRouteChangeReasonCategoryChange"];
            break;
    }
}
// 提醒弹框
- (void)tipWithMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}
// 在dealloc的方法中都要移除所有观察者.
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
