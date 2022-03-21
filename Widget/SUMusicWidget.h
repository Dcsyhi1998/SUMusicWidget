#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <MediaRemote/MediaRemote.h>
#import "Classes/SUWindow.h"
#import "Classes/SUBackgroundView.h"
#import "Classes/CircleProgressView.h"
#import "Classes/CBAutoScrollLabel.h"

#define W [UIScreen mainScreen].bounds.size.width
#define H [UIScreen mainScreen].bounds.size.height

/**
 *  This(identifier) property is required.
 * It is required for control on the Airaw side.
 * Please be careful not to delete it.^^;
 */

@protocol AirawControlProtocol
@required
    @property (nonatomic, retain) NSString *identifier;
    @property (assign, nonatomic) int pageIndex;
    @property (assign, nonatomic) int pageType;
@end

@interface SUMusicWidget : UIView <AirawControlProtocol>
    @property (nonatomic, retain) NSString *identifier;
    @property (assign, nonatomic) int pageIndex;
    @property (assign, nonatomic) int pageType;
    // @property (assign, nonatomic) BOOL isPlaying;
    @property (assign, nonatomic) NSString *savedText;
    @property (assign, nonatomic) CGFloat elapsedTime;
    @property (assign, nonatomic) NSString *musicDurationString;
    @property (assign, nonatomic) CGFloat musicDuration;
    @property (assign, nonatomic) NSString *currentElapsedTimeString;
    @property (assign, nonatomic) CGFloat currentElapsedTime;
    @property (nonatomic, retain) UIView *musicView;
    @property (nonatomic, retain) UIBlurEffect *blurEffect;
    @property (nonatomic, retain) UIVisualEffectView *blurEffectView;
    @property (nonatomic, retain) UIStackView *stackView;
    @property (nonatomic, retain) UIView *shadowView;
    @property (nonatomic, retain) CircleProgressView *circleView;
    @property (nonatomic, retain) UIImageView *artworkView;
    @property (nonatomic, retain) UIStackView *labelStackView;
    @property (nonatomic, retain) CBAutoScrollLabel *titleLabel;
    @property (nonatomic, retain) CBAutoScrollLabel *artistLabel;
    @property (nonatomic, retain) UIView *gestureView;
    @property (nonatomic, retain) UITapGestureRecognizer *tapGesture;
    @property (nonatomic, retain) UISwipeGestureRecognizer *swipeGestureLeft;
    @property (nonatomic, retain) UISwipeGestureRecognizer *swipeGestureRight;
    -(instancetype)initWithFrame:(CGRect)arg1;
    -(void)layoutMusicWidget;
@end

@interface SBMediaController : NSObject
    + (id)sharedInstance;
    - (BOOL)changeTrack:(int)arg1 eventSource:(long long)arg2;
    - (BOOL)togglePlayPauseForEventSource:(long long)arg1;
@end