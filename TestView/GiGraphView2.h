//! \file GiGraphView2.h
//! \brief 定义iOS绘图视图类 GiGraphView2
// Copyright (c) 2012-2013, https://github.com/rhcad/touchvg

#import "GiPaintView.h"

class ViewAdapter1;
class GiCoreView;

enum kTestFlags {
    kSplinesCmd = 1,
    kSelectCmd  = 2,
    kSelectLoad = 3,
    kLineCmd    = 4,
    kLinesCmd   = 5,
    kAddImages  = 7,
    kLoadImages = 8,
    kCmdMask    = 15,
    kSwitchCmd  = 16,
    kRandShapes = 32,
    kRecord     = 64,
    kPlayShapes = 64,
    kProvider   = 128,
    kKeyFrame   = 256,
    kSpirit     = 512,
};

//! iOS测试绘图视图类
@interface GiGraphView2 : GiPaintView {
    int         _testType;
    int         _frameIndex;
    UIButton    *_undoBtn;
    UIButton    *_redoBtn;
    UIButton    *_pauseBtn;
    UIGestureRecognizer *_recognizer;
}

- (id)initWithFrame:(CGRect)frame withType:(int)type;
+ (NSString *)lastFileName;

@end
