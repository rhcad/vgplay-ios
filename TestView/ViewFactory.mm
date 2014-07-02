// ViewFactory.mm
// Copyright (c) 2012-2013, https://github.com/rhcad/touchvg

#import "GiGraphView2.h"
#import "GiViewHelper.h"
#import "ARCMacro.h"

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

static void gatherTestView(NSMutableArray *arr, NSUInteger index, CGRect frame)
{
    NSUInteger i = 0;
    
    addGraphView(arr, i, index, @"Empty view", frame, -1);
    addGraphView(arr, i, index, @"GiPaintView record switch command", frame, kRecord|kSwitchCmd);
    addGraphView(arr, i, index, @"GiPaintView record splines", frame, kRecord|kSplinesCmd);
    addGraphView(arr, i, index, @"GiPaintView record line", frame, kRecord|kLineCmd);
    addGraphView(arr, i, index, @"GiPaintView record randShapes splines",
                 frame, kRecord|kSplinesCmd|kRandShapes);
    addGraphView(arr, i, index, @"GiPaintView record randShapes line",
                 frame, kRecord|kLineCmd|kRandShapes);
    addGraphView(arr, i, index, @"GiPaintView add images", frame, kAddImages);
    addGraphView(arr, i, index, @"GiPaintView load images", frame, kLoadImages);
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
