//! \file GiPlayingHelper.h
//! \brief 实现矢量图形播放类 GiPlayingHelper
// Copyright (c) 2014 Zhang Yungui, https://github.com/touchvg/vgplay

#import <UIKit/UIKit.h>

@class GiPaintView;
@class CALayer;
@protocol GiPlayProvider;

extern const int GI_FRAMEFLAGS_DYN;

//! 图形播放辅助类
/*! \ingroup GROUP_IOS
 */
@interface GiPlayingHelper : NSObject

- (id)initWithView:(GiPaintView *)view;
+ (NSString *)getVersion;                   //!< 得到本库的版本号
- (void)stop;                               //!< 停止所有播放项

- (BOOL)startPlay:(NSString *)path;         //!< 开始播放，在主线程用
- (void)stopPlay;                           //!< 停止播放，在主线程用

- (BOOL)startSyncPlay:(int)cid path:(NSString *)path;   //!< 开始同步播放
- (void)applySyncPlayFrame:(int)cid index:(int)index;   //!< 同步播放一帧
- (void)stopSyncPlay:(int)cid;              //!< 停止同步播放
- (void)stopSyncPlayings;                   //!< 停止所有同步播放

- (BOOL)addPlayProvider:(id<GiPlayProvider>)p tag:(int)tag;  //!< 添加一个播放项
- (int)playProviderCount;                   //!< 返回播放项的个数

- (int)insertSprite:(NSString *)format count:(int)count
              delay:(int)ms repeatCount:(int)rcount tag:(int)tag;    //!< 在默认位置插入帧动画精灵
- (int)insertSprite:(NSString *)format count:(int)count
              delay:(int)ms repeatCount:(int)rcount
                tag:(int)tag center:(CGPoint)pt;    //!< 插入帧动画精灵，并指定其中心位置

//! 将静态图形转换到三级层，第二级为每个图形的层，其下有CAShapeLayer
+ (CALayer *)exportLayerTree:(GiPaintView *)view hidden:(BOOL)hidden;

//! 将静态图形转换为二级层，第二级为多个CAShapeLayer
+ (CALayer *)exportLayers:(GiPaintView *)view;

@end
