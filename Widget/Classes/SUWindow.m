#import "SUWindow.h"

@implementation SUWindow

- (id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    self.clipsToBounds = YES;
    self.backgroundColor = [UIColor clearColor];
    self.layer.masksToBounds = YES;
    self.windowLevel = 3000;
    self.alpha = 1.0;
    self.opaque = NO;
    self.userInteractionEnabled = YES;

    return self;

}

- (bool)_shouldCreateContextAsSecure{

    return NO;

}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {

    for (UIView* subview in self.subviews ) {
        if ( [subview hitTest:[self convertPoint:point toView:subview] withEvent:event] != nil ) {
            return YES;
        }
    }
    return NO;

}

@end