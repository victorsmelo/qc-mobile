//
//  JKQCView.m
//  QCMobile
//
//  Created by Joris Kluivers on 5/8/13.
//  Copyright (c) 2013 Joris Kluivers. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "JKQCView.h"
#import "JKComposition.h"
#import "JKPatch.h"

@interface JKQCView ()

@property(nonatomic, readwrite, assign) CGFloat frameRate;
@property(nonatomic, strong) NSSet *touches;
@property(nonatomic, strong) UIEvent *event;

- (void) render:(CADisplayLink *)link;
@end

@implementation JKQCView {
    GLKBaseEffect *_effect;
    
    CADisplayLink *_link;
    NSDate *_startDate;
    NSDate *_prevFrameDate;
    
    CIContext *_ciContext;
}

@synthesize touches, event;

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
        // TODO: update on resize
        
        
        //GLKMatrix4 modelview = GLKMatrix4MakeTranslation(0, 0, -10.0f);
        // _baseEffect.transform.modelviewMatrix = modelview;
    }
    
    return self;
}

#pragma mark - JKContext

- (CGSize) size
{
    return self.bounds.size;
}

- (EAGLContext *) glContext
{
    return self.context;
}

- (GLKBaseEffect *) effect
{
    if (!_effect) {
        _effect = [[GLKBaseEffect alloc] init];
    }
    
    return _effect;
}

- (CIContext *) ciContext
{
    if (!_ciContext) {
        _ciContext = [CIContext contextWithEAGLContext:self.glContext options:@{
            kCIContextWorkingColorSpace: [NSNull null]
        }];
    }
    
    return _ciContext;
}

- (GLKMatrix4) projectionMatrix
{
    CGFloat height = 2.0 * (self.size.height / self.size.width);
    return GLKMatrix4MakeOrtho(-1, 1, -height/2.0f, height/2.0f, 1, -1);
//    
//    CGFloat aspect = fabsf(self.size.width / self.size.height);
//    
//    GLKMatrix4 projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.f, 2.0f);
//    return projection;
}

- (void) drawRect:(CGRect)rect
{
    NSDate *current = [NSDate date];
    
    CGFloat rate = 1.0 / [current timeIntervalSinceDate:_prevFrameDate];
    self.frameRate = rate;
    
    [self.composition.rootPatch execute:self atTime:[current timeIntervalSinceDate:_startDate]];
    
    _prevFrameDate = current;
}

- (void) layoutSubviews
{
    [super layoutSubviews];
    
//    // TODO: figure out correct translation
//    GLKMatrix4 lookAt = GLKMatrix4MakeLookAt(0, 0, -1.9, 0, 0, 0, 0, 1, 0);
//    _baseEffect.transform.modelviewMatrix = lookAt;
//    
//    CGFloat width = CGRectGetWidth(self.bounds);
//    CGFloat height = CGRectGetHeight(self.bounds);
//    CGFloat ratio = width / height;
//    
//    GLKMatrix4 projection = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(45.0), ratio, .01f, 100.0f);
//    _baseEffect.transform.projectionMatrix = projection;
    
    [self setNeedsDisplay];
}

- (void) startAnimation
{
    [self.composition.rootPatch startExecuting:self];
    
    _startDate = [NSDate date];
    _prevFrameDate = _startDate;
    
    _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    [_link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void) stopAnimation
{
    self.frameRate = 0.0f;
    [_link invalidate];
    _link = nil;
}

- (BOOL) isAnimating
{
    return _link != nil;
}

- (void) render:(CADisplayLink *)link
{
    //self.frameRate = 1.0f / link.duration;
    
    [self display];
}

- (void) setValue:(id)value forInputKey:(NSString *)key
{
    [self.composition.rootPatch setValue:value forInputKey:key];
}

- (void) touchesBegan:(NSSet *)touchSet withEvent:(UIEvent *)viewEvent
{
    self.touches = touchSet;
    self.event = viewEvent;
}

- (void) touchesMoved:(NSSet *)touchSet withEvent:(UIEvent *)viewEvent
{
    self.touches = touchSet;
    self.event = viewEvent;
}

- (void) touchesEnded:(NSSet *)touchSet withEvent:(UIEvent *)viewEvent
{
    self.touches = nil;
    self.event = nil;
}

@end
