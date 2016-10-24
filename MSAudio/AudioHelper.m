//
//  AudioHelper.m
//  MSAudio
//
//  Created by mr.scorpion on 2016/10/19.
//  Copyright © 2016年 mr.scorpion. All rights reserved.
//

#import "AudioHelper.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <UIKit/UIKit.h>

@implementation AudioHelper
- (BOOL)hasMicphone
{
    return [[AVAudioSession sharedInstance] inputIsAvailable];
}

- (BOOL)hasHeadset
{
#if TARGET_IPHONE_SIMULATOR
#warning *** Simulator mode: audio session code works only on a device
    return NO;
#else
    CFStringRef route = NULL;
    UInt32 propertySize = sizeof(CFStringRef);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, (void*)route);
    
    if((route == NULL) || (CFStringGetLength(route) == 0))
    {
        // Silent Mode
        NSLog(@"AudioRoute: SILENT, do nothing!");
    }
    else {
        NSString* routeStr = (__bridge NSString*)route;
        NSLog(@"AudioRoute: %@", routeStr);
        
        /* Known values of route:
         * "Headset"
         * "Headphone"
         * "Speaker"
         * "SpeakerAndMicrophone"
         * "HeadphonesAndMicrophone"
         * "HeadsetInOut"
         * "ReceiverAndMicrophone"
         * "Lineout"
         */
        NSRange headphoneRange = [routeStr rangeOfString : @"Headphone"];
        NSRange headsetRange = [routeStr rangeOfString : @"Headset"];
        if (headphoneRange.location != NSNotFound) {
            return YES;
        } else if(headsetRange.location != NSNotFound) {
            return YES;
        }
    }
    return NO;
#endif
}

- (void)resetOutputTarget
{
    BOOL hasHeadset = [self hasHeadset];
    NSLog (@"Will Set output target is_headset = %@ .", hasHeadset ? @"YES" : @"NO");
    UInt32 audioRouteOverride = hasHeadset ?
kAudioSessionOverrideAudioRoute_None:kAudioSessionOverrideAudioRoute_Speaker;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(audioRouteOverride), &audioRouteOverride);
    [self hasHeadset];
}

- (BOOL)checkAndPrepareCategoryForRecording
{
    recording = YES;
    BOOL hasMicphone = [self hasMicphone];
    NSLog(@"Will Set category for recording! hasMicophone = %@", hasMicphone?@"YES":@"NO");
    if (hasMicphone) {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord
                                               error:nil];
    }
    [self resetOutputTarget];
    return hasMicphone;
}

- (void)resetCategory
{
    if (!recording) {
        NSLog(@"Will Set category to static value = udioSessionCategoryPlayback!");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback
                                               error:nil];
    }
}

- (void)resetSettings
{
    [self resetOutputTarget];
    [self resetCategory];
    BOOL isSucced = [[AVAudioSession sharedInstance] setActive: YES error:NULL];
    if (!isSucced) {
        NSLog(@"Reset audio session settings failed!");
    }
}

- (void)cleanUpForEndRecording
{
    recording = NO;
    [self resetSettings];
}

- (void)printCurrentCategory
{
    return;
    
    UInt32 audioCategory = 0;
    UInt32 size = sizeof(audioCategory);
    AudioSessionGetProperty(kAudioSessionProperty_AudioCategory, &size, audioCategory);
    
    if ( audioCategory == kAudioSessionCategory_UserInterfaceSoundEffects ){
        NSLog(@"current category is : dioSessionCategory_UserInterfaceSoundEffects");
    } else if ( audioCategory == kAudioSessionCategory_AmbientSound ){
        NSLog(@"current category is : kAudioSessionCategory_AmbientSound");
    } else if ( audioCategory == kAudioSessionCategory_AmbientSound ){
        NSLog(@"current category is : kAudioSessionCategory_AmbientSound");
    } else if ( audioCategory == kAudioSessionCategory_SoloAmbientSound ){
        NSLog(@"current category is : kAudioSessionCategory_SoloAmbientSound");
    } else if ( audioCategory == kAudioSessionCategory_MediaPlayback ){
        NSLog(@"current category is : kAudioSessionCategory_MediaPlayback");
    } else if ( audioCategory == kAudioSessionCategory_LiveAudio ){
        NSLog(@"current category is : kAudioSessionCategory_LiveAudio");
    } else if ( audioCategory == kAudioSessionCategory_RecordAudio ){
        NSLog(@"current category is : kAudioSessionCategory_RecordAudio");
    } else if ( audioCategory == kAudioSessionCategory_PlayAndRecord ){
        NSLog(@"current category is : kAudioSessionCategory_PlayAndRecord");
    } else if ( audioCategory == kAudioSessionCategory_AudioProcessing ){
        NSLog(@"current category is : kAudioSessionCategory_AudioProcessing");
    } else {
        NSLog(@"current category is : unknow");
    }
}

void audioRouteChangeListenerCallback (void                      *inUserData,
                                       AudioSessionPropertyID    inPropertyID,
                                       UInt32                    inPropertyValueS,
                                       const void                *inPropertyValue
                                       ) {
    if (inPropertyID != kAudioSessionProperty_AudioRouteChange)
        return;
    
    CFDictionaryRef routeChangeDictionary = (CFDictionaryRef)inPropertyValue;
    CFNumberRef routeChangeReasonRef = (CFNumberRef)CFDictionaryGetValue (routeChangeDictionary,CFSTR (kAudioSession_AudioRouteChangeKey_Reason));
    SInt32 routeChangeReason;
    CFNumberGetValue (routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);
    
    AudioHelper *_self = (__bridge AudioHelper *)inUserData;
    if (routeChangeReason == kAudioSessionRouteChangeReason_OldDeviceUnavailable) { // 原有设备被拔出
        NSLog(@"原有设备被拔出");
        [_self resetSettings];
        if (![_self hasHeadset]){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"unpluggInMicrophone" object:nil];
        }
    }
    else if (routeChangeReason == kAudioSessionRouteChangeReason_NewDeviceAvailable) { // 有新设备插入
        NSLog(@"有新设备插入");
        [_self resetSettings];
        if (![_self hasMicphone]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"pluggInMicrophone"
                                                                object:nil];
        }
    }
    else if (routeChangeReason == kAudioSessionRouteChangeReason_NoSuitableRouteForCategory) {
        [_self resetSettings];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"lostMicroPhone"
                                                            object:nil];
    }
    [_self printCurrentCategory];
}

- (void)initSession
{
    recording = NO;
    AudioSessionInitialize(NULL, NULL, NULL, NULL);
    [self resetSettings];
    AudioSessionAddPropertyListener (kAudioSessionProperty_AudioRouteChange,
                                     audioRouteChangeListenerCallback,
                                     (__bridge_retained void *)self);
    [self printCurrentCategory];
    [[AVAudioSession sharedInstance] setActive: YES error:NULL];
    
    [[UIDevice currentDevice] setProximityMonitoringEnabled:NO];
    //添加监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(sensorStateChange:)
                                                 name:@"UIDeviceProximityStateDidChangeNotification"
                                               object:nil];
}

//处理监听触发事件
- (void)sensorStateChange:(NSNotificationCenter *)notification;
{
    // 如果此时手机靠近面部放在耳朵旁，那么声音将通过听筒输出，并将屏幕变暗
    if ([[UIDevice currentDevice] proximityState] == YES)
    {
        NSLog(@"Device is close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    }
    else
    {
        NSLog(@"Device is not close to user");
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    }
}
@end
