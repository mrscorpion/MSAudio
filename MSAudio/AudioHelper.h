//
//  AudioHelper.h
//  K歌卡路里
//
//  Created by amber on 15/1/15.
//  Copyright (c) 2015年 amber. All rights reserved.
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
