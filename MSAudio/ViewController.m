//
//  ViewController.m
//  MSAudio
//
//  Created by mr.scorpion on 2016/10/19.
//  Copyright © 2016年 mr.scorpion. All rights reserved.
//

#import "ViewController.h"
#import "AudioHelper.h"
#import <AVFoundation/AVFoundation.h>  

#import "MSAudioVC.h"

@interface ViewController ()

@end

@implementation ViewController
#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 示例1
    if ([self isHeadsetPluggedIn]) {
        NSLog(@"有耳机插入");
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(unpluggInMic) name:@"unpluggInMicrophone" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pluggInMic) name:@"pluggInMicrophone" object:nil];
    AudioHelper *helper = [[AudioHelper alloc] init];
    [helper initSession];
    
    if ([helper hasHeadset]) {
        NSLog(@"有耳机插入");
    }
    
    if ([helper hasMicphone]) {
        NSLog(@"有麦克风");
    }
    
    
    // 示例2
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(next)];
    [self.view addGestureRecognizer:tap];
}
- (void)next
{
    [self presentViewController:[[MSAudioVC alloc] init] animated:YES completion:nil];
}




// 示例1
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
- (void)unpluggInMic
{
    NSLog(@"设备拔出");
}
- (void)pluggInMic
{
    NSLog(@"设备插入");
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
