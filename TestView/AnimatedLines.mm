//
//  AnimatedLines.mm
//
//  Created by Zhang Yungui on 14-7-4.
//  Copyright (c) 2014, https://github.com/touchvg/vgplay-ios
//

#import "GiPlayingHelper.h"
#import "GiPlayProvider.h"
#import "GiViewHelper.h"
#include "mgshapes.h"
#include "mgspfactory.h"
#include "mglines.h"

static Point2d d2m(float x, float y, GiViewHelper *helper)
{
    CGPoint pt = [helper displayToModel:CGPointMake(x, y)];
    return Point2d(pt.x, pt.y);
}

void addAnimatedLinesDemo(GiPlayingHelper *play)
{
    __block MgShape* pathsp = NULL;
    __block int segment = -1;
    __block float length, pos, step;
    
    [play addPlayProvider:^int(GiFrame frame) {
        MgShapes *shapes = MgShapes::fromHandle(frame.shapes);
        
        if (!pathsp) {
            GiViewHelper *helper = [GiViewHelper sharedInstance:frame.view];
            MgShape *newsp = [helper shapeFactory]->createShape(MgLines::Type());
            MgLines* lines = (MgLines*)newsp->shape();
            
            GiContext ctx(newsp->context());
            ctx.setLineWidth(-10, true);
            newsp->setContext(ctx);
            
            lines->addPoint(d2m(10, 10, helper));
            lines->addPoint(d2m(300, 10, helper));
            lines->addPoint(d2m(10, 300, helper));
            lines->addPoint(d2m(300, 300, helper));
            lines->addPoint(d2m(10, 10, helper));
            
            shapes->addShapeDirect(newsp);
            pathsp = newsp->cloneShape();
            step = fabsf([helper displayRectToModel:CGRectMake(0, 0, 1, 1)].size.width);
        }
        
        if (frame.tick < frame.lastTick + 20) {
            return 0;
        }
        
        MgShape* newsp = shapes->getLastShape()->cloneShape();
        MgLines* lines = (MgLines*)newsp->shape();
        const MgBaseShape* path = pathsp->shapec();
        
        if (segment < 0 || segment + 1 >= path->getPointCount()) {
            segment = 0;
            length = 0;
            lines->clear();
        }
        if (length < _MGZERO) {
            length = path->getPoint(segment).distanceTo(path->getPoint(segment + 1));
            pos = 0;
            for (int i = lines->getPointCount(); i <= segment + 1; i++) {
                lines->addPoint(path->getPoint(i));
            }
            lines->setPoint(segment + 1, path->getPoint(segment));
        }
        if (pos > length - _MGZERO) {
            segment++;
            length = 0;
        } else {
            pos = mgMin(length, pos + step * (float)(frame.tick - frame.lastTick));
            Point2d pt(path->getPoint(segment).rulerPoint(path->getPoint(segment + 1), pos, 0));
            lines->setPoint(segment + 1, pt);
        }
        
        GiContext ctx(newsp->context());
        ctx.setLineAlpha(100 + frame.index % 100);
        newsp->setContext(ctx);
        
        shapes->updateShape(newsp, true);
        return 1;
    } ended:^void(GiFrame) {
        MgObject::release_pointer(pathsp);
    } tag:1];
}
