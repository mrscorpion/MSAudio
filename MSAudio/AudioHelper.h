//
//  AudioHelper.h
//  MSAudio
//
//  Created by mr.scorpion on 2016/10/19.
//  Copyright © 2016年 mr.scorpion. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AudioHelper : NSObject{
    BOOL recording;
}

- (void)initSession;
- (BOOL)hasHeadset; //检查是否有耳机插入
- (BOOL)hasMicphone; //检测声音输入设备
- (void)cleanUpForEndRecording;
- (BOOL)checkAndPrepareCategoryForRecording;
@end
