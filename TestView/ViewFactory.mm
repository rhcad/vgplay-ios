// ViewFactory.mm
// Copyright (c) 2012-2013, https://github.com/rhcad/touchvg

#import "GiGraphView2.h"
#import "GiViewHelper.h"
#import "ARCMacro.h"
#import "GiPlayingHelper.h"
#import "AnimatedPathView1.h"
#import "BoardView.h"

static UIViewController *_tmpController = nil;

static void addView(NSMutableArray *arr, NSString* title, UIView* view)
{
    if (arr) {
        [arr addObject:title];
    }
    else if (view) {
        _tmpController = [[[UIViewController alloc] init] AUTORELEASE];
        _tmpController.title = title;
        _tmpController.view = view;
    }
}

static void testGraphView(GiPaintView *v, int type)
{
    GiViewHelper *hlp = [GiViewHelper sharedInstance:v];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                          NSUserDomainMask, YES) objectAtIndex:0];
    if (type & kRandShapes) {
        [hlp addShapesForTest];
    }
    
    switch (type & kCmdMask) {
        case kSplinesCmd:
            hlp.command = @"splines";
            hlp.strokeWidth = 3;
            break;
            
        case kSelectCmd:
            hlp.command = @"select";
            break;
            
        case kSelectLoad:
            [hlp loadFromFile:[GiGraphView2 lastFileName]];
            hlp.command = @"select";
            break;
            
        case kLineCmd:
            hlp.command = @"line";
            hlp.lineStyle = GILineStyleDash;
            break;
            
        case kLinesCmd:
            hlp.command = @"lines";
            hlp.lineStyle = GILineStyleDot;
            hlp.strokeWidth = 5;
            break;
            
        case kAddImages:
            [hlp insertPNGFromResource:@"app72"];
            [hlp insertPNGFromResource:@"app57" center:CGPointMake(200, 100)];
            [hlp insertImageFromFile:[path stringByAppendingPathComponent:@"page0.png"]];
            break;
            
        case kLoadImages:
            [hlp setImagePath:path];
            [hlp loadFromFile:[GiGraphView2 lastFileName]];
            hlp.command = @"select";
            break;
    }
}

static UIView* addGraphView(NSMutableArray *arr, NSUInteger &i, NSUInteger index,
                            NSString* title, CGRect frame, int type)
{
    GiGraphView2 *v = nil;
    
    if (!arr && index == i++ && type >= 0) {
        v = [[GiGraphView2 alloc]initWithFrame:frame withType:type];
        testGraphView(v, type);
    }
    addView(arr, title, v);
    [v RELEASE];
    
    return v;
}


static void addAnimatedPathView1(NSMutableArray *arr, NSUInteger &i, NSUInteger index,
                                 NSString* title, CGRect frame, int type)
{
    AnimatedPathView1 *view = nil;
    
    if (!arr && index == i++) {
        view = [[AnimatedPathView1 alloc]initWithFrame:frame];
        
        GiPaintView *v = [[GiPaintView alloc]initWithFrame:frame];
        GiViewHelper *hlp = [GiViewHelper sharedInstance:v];
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                              NSUserDomainMask, YES) objectAtIndex:0];
        [hlp setImagePath:path];
        [hlp loadFromFile:[GiGraphView2 lastFileName]];
        if (hlp.shapeCount == 0) {
            [hlp addShapesForTest];
        }
        
        [view setupDrawingLayer:[GiPlayingHelper exportLayerTree:v hidden:YES]];
        [view startAnimation];
        [v RELEASE];
    }
    addView(arr, title, view);
}

static void addBoardView(NSMutableArray *arr, NSUInteger &i, NSUInteger index,
                         NSString* title, CGRect frame)
{
    UIView *view = nil;
    
    if (!arr && index == i++) {
        view = [[UIView alloc]initWithFrame:frame];
        [BoardView createTwoViews:view];
    }
    addView(arr, title, view);
    [view RELEASE];
}

void addAnimationLines(NSMutableArray *arr, NSUInteger &i, NSUInteger index,
                       NSString* title, CGRect frame)
{
    GiGraphView2 *v = nil;
    
    if (!arr && index == i++) {
        v = [[GiGraphView2 alloc]initWithFrame:frame withType:0];
    }
    addView(arr, title, v);
    [v RELEASE];
}

static void gatherTestView(NSMutableArray *arr, NSUInteger index, CGRect frame)
{
    NSUInteger i = 0;
    
    addGraphView(arr, i, index, @"Empty view", frame, -1);
    addBoardView(arr, i, index, @"SharedBoard demo", frame);
    addAnimationLines(arr, i, index, @"animation lines", frame);
    addGraphView(arr, i, index, @"record switch cmd", frame, kRecord|kSwitchCmd);
    addGraphView(arr, i, index, @"record splines", frame, kRecord|kSplinesCmd);
    addGraphView(arr, i, index, @"record line", frame, kRecord|kLineCmd);
    addGraphView(arr, i, index, @"record randShapes splines",
                 frame, kRecord|kSplinesCmd|kRandShapes);
    addGraphView(arr, i, index, @"record randShapes line",
                 frame, kRecord|kLineCmd|kRandShapes);
    addGraphView(arr, i, index, @"play", frame, kPlayShapes);
    addGraphView(arr, i, index, @"provider", frame, kSplinesCmd|kProvider);
    addGraphView(arr, i, index, @"provider record", frame, kSplinesCmd|kProvider|kRecord);
    addGraphView(arr, i, index, @"keyframe animation", frame, kKeyFrame|kSplinesCmd);
    addGraphView(arr, i, index, @"keyframe lines", frame, kKeyFrame|kLinesCmd);
    addGraphView(arr, i, index, @"spirit splines", frame, kSpirit|kSplinesCmd);
    addGraphView(arr, i, index, @"spirit select", frame, kSpirit|kSelectCmd);
    addGraphView(arr, i, index, @"spirit record", frame, kSpirit|kSelectCmd|kRecord);
    addGraphView(arr, i, index, @"add images", frame, kAddImages);
    addGraphView(arr, i, index, @"load images", frame, kLoadImages);
    addAnimatedPathView1(arr, i, index, @"AnimatedPathView1", frame, 0);
}

void getTestViewTitles(NSMutableArray *arr)
{
    gatherTestView(arr, 0, CGRectNull);
}

UIViewController *createTestView(NSUInteger index, CGRect frame)
{
    _tmpController = nil;
    gatherTestView(nil, index, frame);
    return _tmpController;
}
