//! \file GiGraphView2.mm
//! \brief 实现iOS绘图视图类 GiGraphView2
// Copyright (c) 2012-2013, https://github.com/rhcad/touchvg

#import "GiGraphView2.h"
#import "GiViewHelper.h"
#import "GiPlayingHelper.h"
#import "GiPlayProvider.h"
#include "RandomShape.h"
#include "gicoreview.h"
#import "ARCMacro.h"

static char _lastVgFile[256] = { 0 };

@interface GiGraphView2()<GiPlayProvider>

@property(nonatomic, STRONG) NSMutableArray  *layers;
@property(nonatomic, STRONG) CAShapeLayer *shapeLayer;
@property(nonatomic, STRONG) CALayer *curLayer;
@property(nonatomic, STRONG) GiPlayingHelper *play;

@end

@implementation GiGraphView2
@synthesize layers = _layers;
@synthesize shapeLayer, curLayer;
@synthesize play = _play;

- (void)dealloc {
    [_play RELEASE];
    [super DEALLOC];
}

- (BOOL)exportPNG:(NSString *)filename
{
    if ((_testType & kKeyFrame) && _layers) {
        [self startPlayKeyFrames];
        return NO;
    }
    NSString *vgfile = [[filename stringByDeletingPathExtension]
                        stringByAppendingPathExtension:@"vg"];
    [[GiViewHelper sharedInstance:self] saveToFile:vgfile];
    [[GiViewHelper sharedInstance] exportSVG:vgfile];
    strncpy(_lastVgFile, [vgfile UTF8String], sizeof(_lastVgFile));
    return [super exportPNG:filename];
}

+ (NSString *)lastFileName
{
    if (_lastVgFile[0] == 0) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
        return [path stringByAppendingPathComponent:@"page0.png"];
    }
    
    return [NSString stringWithUTF8String:_lastVgFile];
}

- (id)initWithFrame:(CGRect)frame withType:(int)type {
    self = [super initWithFrame:frame];
    if (self) {
        _testType = type;
    }
    return self;
}

- (void)onFirstRegen:(id)view {
    GiViewHelper *helper = [GiViewHelper sharedInstance:self];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                          NSUserDomainMask, YES) objectAtIndex:0];
    if (_testType & kRecord) {
        _pauseBtn = [[UIButton alloc]initWithFrame:CGRectMake(0, 50, 120, 32)];
        _pauseBtn.showsTouchWhenHighlighted = YES;
        _pauseBtn.backgroundColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.8];
        [_pauseBtn setTitleColor:[UIColor blackColor] forState: UIControlStateNormal];
        [self addSubview:_pauseBtn];
        [_pauseBtn RELEASE];
    }
    if (_testType == kPlayShapes) {
        [_pauseBtn addTarget:self action:@selector(onPause) forControlEvents:UIControlEventTouchUpInside];
        _play = [[GiPlayingHelper alloc]initWithView:self];
        [_play startPlay:[path stringByAppendingPathComponent:@"record"]];
    }
    else if (_testType & kRecord) {
        [helper startRecord:[path stringByAppendingPathComponent:@"record"]];
    }
    [helper startUndoRecord:[path stringByAppendingPathComponent:@"undo"]];
    [self addUndoRedoButton];
    
    if (_testType & kProvider) {
        _play = [[GiPlayingHelper alloc]initWithView:self];
        //[_play addPlayProvider:self tag:0];
        [_play addPlayProvider:self tag:1];
    }
    if (_testType & kSpirit) {
        _play = [[GiPlayingHelper alloc]initWithView:self];
        [self setContextActionEnabled:(_testType & kSelectCmd) != 0];
        [_play insertSpirit:@"bird_%d.png" count:16 delay:100 repeatCount:0 tag:0];
        if ((_testType & kCmdMask) == kSplinesCmd) {
            helper.command = @"splines";
        }
    }
    if (_testType & kCmdMask) {
        for (UIView *v = self.superview; v; v = v.superview) {
            if (v.backgroundColor && v.backgroundColor != [UIColor clearColor]) {
                self.viewToMagnify = v;
                break;
            }
        }
    }
}

- (void)layoutSubviews {
    [self layoutButtons];
    [super layoutSubviews];
}

- (void)layoutButtons {
    _undoBtn.frame = CGRectMake(0, self.bounds.size.height - 32, 50, 32);
    _redoBtn.frame = CGRectMake(self.bounds.size.width - 50, self.bounds.size.height - 32, 50, 32);
}

- (void)addUndoRedoButton {
    _undoBtn = [[UIButton alloc]initWithFrame:CGRectNull];
    _undoBtn.showsTouchWhenHighlighted = YES;
    [_undoBtn setTitle:@"Undo" forState: UIControlStateNormal];
    _undoBtn.backgroundColor = [UIColor clearColor];
    [_undoBtn setTitleColor:[UIColor blackColor] forState: UIControlStateHighlighted];
    [_undoBtn addTarget:self action:@selector(undo) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_undoBtn];
    [_undoBtn RELEASE];
    
    _redoBtn = [[UIButton alloc]initWithFrame:CGRectNull];
    _redoBtn.showsTouchWhenHighlighted = YES;
    [_redoBtn setTitle:@"Redo" forState: UIControlStateNormal];
    _redoBtn.backgroundColor = [UIColor clearColor];
    [_redoBtn setTitleColor:[UIColor blackColor] forState: UIControlStateHighlighted];
    [_redoBtn addTarget:self action:@selector(redo) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_redoBtn];
    [_redoBtn RELEASE];
    
    [self layoutButtons];
}

- (void)onPlayFrame:(id)view {
    long ticks = [[GiViewHelper sharedInstance:self] getPlayTicks];
    NSString *text = [NSString stringWithFormat:@"%03d %2ld:%02ld.%03ld",
                      _frameIndex++, ticks / 60000, ticks / 1000 % 60, ticks % 1000];
    [_pauseBtn setTitle:text forState: UIControlStateNormal];
}

- (void)onShapesRecorded:(NSDictionary *)info {
    dispatch_async(dispatch_get_main_queue(), ^{
        long ticks = [info[@"tick"] longValue];
        NSString *text = [NSString stringWithFormat:@"%03d %2ld:%02ld.%03ld",
                          [info[@"index"] intValue], ticks / 60000, ticks / 1000 % 60, ticks % 1000];
        [_pauseBtn setTitle:text forState: UIControlStateNormal];
    });
}

- (void)onPause {
    if ([[GiViewHelper sharedInstance:self] isPaused]) {
        [[GiViewHelper sharedInstance] playResume];
    } else {
        [[GiViewHelper sharedInstance] playPause];
    }
}

- (BOOL)initProvider:(GiFrame *)frame {
    MgShapes* shapes = MgShapes::fromHandle(frame->shapes);
    BOOL ret = YES;
    
    if (frame->tag > 0) {
        GiCoreView* cv = GiCoreView::createView(NULL, 0);
        NSString* f = [GiViewHelper addExtension:[GiGraphView2 lastFileName] :@".vg"];
        
        ret = cv->loadFromFile([f UTF8String]);
        shapes->copyShapes(MgShapes::fromHandle(cv->backShapes()), false);
        cv->release();
        
        if (_recognizer) {
            Point2d oldpt(shapes->getExtent().center());
            CGPoint newpt = [_recognizer locationInView:self];
            newpt = [[GiViewHelper sharedInstance:self] displayToModel:newpt];
            shapes->transform(Matrix2d::translation(Point2d(newpt.x, newpt.y) - oldpt));
        }
        Point2d pt(shapes->getExtent().center());
        frame->extra = [[NSValue valueWithCGPoint:CGPointMake(pt.x, pt.y)] RETAIN];
    }
    
    return ret;
}

- (int)provideFrame:(GiFrame)frame {
    MgShapes* shapes = MgShapes::fromHandle(frame.shapes);
    int ret = 0;
    
    if (frame.tag == 0) {
        if (frame.tick > frame.lastTick + 1000) {
            shapes->clear();
            RandomParam(frame.tick / 100 % 100).addShapes(shapes);
            ret = 1;
        }
    } else {
        if (frame.tick > frame.lastTick + 60 - frame.tag * 10) {
            CGPoint pt = [frame.extra CGPointValue];
            shapes->transform(Matrix2d::rotation(2.5f * _M_D2R, Point2d(pt.x, pt.y)));
            ret = 1;
        }
    }
    
    return ret;
}

- (void)onProvideEnded:(GiFrame)frame {
    NSLog(@"onPlayEnded tag=%d", frame.tag);
}

- (BOOL)pressHandler:(UILongPressGestureRecognizer *)sender {
    GiViewHelper *helper = [GiViewHelper sharedInstance:self];
    
    if ([_play playProviderCount] == 0) {
        return [super pressHandler:sender];
    }
    if (sender.state == UIGestureRecognizerStateBegan) {
        if (_testType & kSpirit) {
            [_play insertSpirit:@"bird_%d.png"
                          count:16
                          delay:100 - [_play playProviderCount] * 10
                    repeatCount:0
                            tag:[_play playProviderCount]
                         center:[sender locationInView:self]];
            if ((_testType & kCmdMask) == kSplinesCmd) {
                helper.command = @"splines";
            }
        } else {
            _recognizer = sender;
            [_play addPlayProvider:self tag:[_play playProviderCount] + 1];
            _recognizer = nil;
        }
    }
    
    return YES;
}

- (void)onContentChanged:(id)view {
    GiViewHelper *helper = [GiViewHelper sharedInstance:self];
    
    if (_testType & kKeyFrame) {
        CALayer *layer = [GiPlayingHelper exportLayers:self];
        
        if (layer) {
            if (!self.layers)
                self.layers = [NSMutableArray array];
            [self.layers addObject:layer];
        }
    }
    
    _undoBtn.backgroundColor = [helper canUndo] ? [UIColor grayColor] : [UIColor clearColor];
    _redoBtn.backgroundColor = [helper canRedo] ? [UIColor grayColor] : [UIColor clearColor];
}

- (BOOL)twoTapsHandler:(UITapGestureRecognizer *)sender {
    if (_testType & kSwitchCmd) {
        if (sender.state < UIGestureRecognizerStateEnded)
            return YES;
        [[GiViewHelper sharedInstance:self] switchCommand];
        
        [[[[UIAlertView alloc] initWithTitle:@"Switch command"
                                     message:[GiViewHelper sharedInstance].command
                                    delegate:nil
                           cancelButtonTitle:@"OK"
                           otherButtonTitles:nil] AUTORELEASE]show];
        return YES;
    }
    return [super twoTapsHandler:sender];
}

- (void)startPlayKeyFrames {
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.frame = self.bounds;
    [self.layer addSublayer:self.shapeLayer];
    [self playKeyFrame];
}

- (void)playKeyFrame
{
    NSUInteger i = 0;
    CAShapeLayer *nowLayer;
    CAShapeLayer *nextLayer;
    
    if (self.curLayer) {
        for (; i < [_layers count] && [_layers objectAtIndex:i] != curLayer; i++) {
        }
    }
    self.curLayer = i < [_layers count] ? [_layers objectAtIndex:i] : nil;
    if (!self.curLayer) {
        return;
    }
    nowLayer = [curLayer.sublayers lastObject];
    self.shapeLayer.strokeColor = nowLayer.strokeColor;
    self.shapeLayer.fillColor = nowLayer.fillColor;
    self.shapeLayer.lineWidth = nowLayer.lineWidth;
    self.shapeLayer.lineDashPhase = nowLayer.lineDashPhase;
    self.shapeLayer.lineDashPattern = nowLayer.lineDashPattern;
    self.shapeLayer.lineCap = nowLayer.lineCap;
    
    self.curLayer = i + 1 < [_layers count] ? [_layers objectAtIndex:i + 1] : nil;
    if (!self.curLayer) {
        [self.shapeLayer removeFromSuperlayer];
        self.shapeLayer = nil;
        return;
    }
    nextLayer = [curLayer.sublayers lastObject];
    
    CABasicAnimation* pathAnim = [CABasicAnimation animationWithKeyPath: @"path"];
    pathAnim.fromValue = (__bridge id)nowLayer.path;
    pathAnim.toValue = (__bridge id)nextLayer.path;
    
    CABasicAnimation* frameAnim = [CABasicAnimation animationWithKeyPath: @"frame"];
    frameAnim.fromValue = [NSValue valueWithCGRect:nowLayer.frame];
    frameAnim.toValue = [NSValue valueWithCGRect:nextLayer.frame];
    
    CAAnimationGroup *anims = [CAAnimationGroup animation];
    anims.animations = @[pathAnim, frameAnim];
    anims.duration = 0.5;
    anims.delegate = self;
    [self.shapeLayer addAnimation:anims forKey:nil];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self performSelector:@selector(playKeyFrame) withObject:nil afterDelay:0];
}

@end
