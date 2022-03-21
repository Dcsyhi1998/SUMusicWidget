#import "SUMusicWidget.h"

struct pixel {
    unsigned char r, g, b, a;
};

@implementation SUMusicWidget {
    int height;
    BOOL isPlaying;
    dispatch_source_t _progress;
}
    - (instancetype)initWithFrame:(CGRect)arg1 {
        self = [super initWithFrame:arg1];
        if (self) {
            //widget settings
            self.layer.masksToBounds = true;
            self.layer.cornerRadius = 15;

            height = self.bounds.size.height;

            //musicView
            self.musicView = [[UIView alloc] init];
            [self.musicView setBackgroundColor:[UIColor clearColor]];
            self.musicView.layer.cornerRadius =  height * 0.1;
            self.musicView.layer.masksToBounds = true;
            [self addSubview:self.musicView];

            //blurEffectView
            self.blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterial];
            self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:self.blurEffect];
            [self.musicView addSubview:self.blurEffectView];

            //stackView
            self.stackView = [[UIStackView alloc] init];
            self.stackView.axis = UILayoutConstraintAxisVertical;
            self.stackView.alignment = UIStackViewAlignmentCenter;
            self.stackView.distribution = UIStackViewDistributionEqualSpacing;
            [self.musicView addSubview:self.stackView];

            //shadowView
            self.shadowView = [[UIView alloc] init];
            self.shadowView.layer.shadowColor = [[UIColor whiteColor] CGColor];
            self.shadowView.layer.shadowOffset = CGSizeMake(0,5);
            self.shadowView.layer.shadowOpacity = 0.8;
            self.shadowView.layer.shadowRadius = 5;
            [self.stackView addArrangedSubview:self.shadowView];

            //circleView
            self.circleView = [[CircleProgressView alloc] init];
            [self.circleView setBackgroundColor:[UIColor clearColor]];
            self.circleView.progress = 0.0;
            self.circleView.clockwise = true;
            self.circleView.trackWidth = 2.0;
            self.circleView.trackFillColor = [UIColor whiteColor];
            self.circleView.trackBackgroundColor = [UIColor secondaryLabelColor];
            [self.shadowView addSubview:self.circleView];

            //artworkView
            self.artworkView = [[UIImageView alloc] init];
            self.artworkView.image = nil;
            self.artworkView.clipsToBounds = true;
            self.artworkView.layer.cornerRadius =  height * 4.5/10 * 1/2;
            [self.artworkView setContentMode:UIViewContentModeScaleAspectFill];
            [self.circleView.contentView addSubview:self.artworkView];

            //labelStackView
            self.labelStackView = [[UIStackView alloc] init];
            self.labelStackView.axis = UILayoutConstraintAxisVertical;
            self.labelStackView.alignment = UIStackViewAlignmentCenter;
            self.labelStackView.distribution = UIStackViewDistributionEqualSpacing;
            [self.stackView addArrangedSubview:self.labelStackView];

            //titleLabel
            self.titleLabel = [[CBAutoScrollLabel alloc] init];
            [self.titleLabel setText:@"Airaw"];
            [self.titleLabel setFont:[UIFont monospacedSystemFontOfSize:height * 1/10 weight:UIFontWeightMedium]];
            [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
            [self.titleLabel setTextColor:[UIColor labelColor]];
            [self.titleLabel sizeToFit];
            self.titleLabel.pauseInterval = 3.0;
            self.titleLabel.scrollSpeed = 30;
            self.titleLabel.fadeLength = 0.0;
            [self.labelStackView addArrangedSubview:self.titleLabel];

            //artistLabel
            self.artistLabel = [[CBAutoScrollLabel alloc] init];
            [self.artistLabel setText:@"SUMusicWidget"];
            [self.artistLabel setFont:[UIFont monospacedSystemFontOfSize:height * 1/10 * 3/4 weight:UIFontWeightRegular]];
            [self.artistLabel setTextAlignment:NSTextAlignmentCenter];
            [self.artistLabel setTextColor:[UIColor secondaryLabelColor]];
            [self.artistLabel sizeToFit];
            self.artistLabel.pauseInterval = 3.0;
            self.artistLabel.scrollSpeed = 30;
            self.artistLabel.fadeLength = 0.0;
            [self.labelStackView addArrangedSubview:self.artistLabel];

            //gestureView
            self.gestureView = [[UIView alloc] init];
            [self.gestureView setHidden:NO];
            [self.gestureView setBackgroundColor:[UIColor clearColor]];
            [self.musicView addSubview:self.gestureView];

            //tapGesture
            self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playOrPauseGesture:)];
            [self.gestureView addGestureRecognizer:self.tapGesture];

            //swipeGesture
            self.swipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(skipOrRewindGesture:)];
            self.swipeGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
            [self.gestureView addGestureRecognizer:self.swipeGestureLeft];

            self.swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(skipOrRewindGesture:)];
            self.swipeGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
            [self.gestureView addGestureRecognizer:self.swipeGestureRight];

            //set layout
            [self layoutMusicWidget];

            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getMusicInfo:) name:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification object:nil];
            [[NSNotificationCenter defaultCenter] postNotificationName:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification object:nil];

            // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playingDidChange:) name:@"kMRMediaRemoteNowPlayingApplicationPlaybackStateDidChangeNotification" object:nil];//(__bridge NSString *)
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerStatus) name:@"kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification" object:nil];
            [self playerStatus];
        }
        return self;
    }
    //レイアウトの固定
    -(void)layoutMusicWidget {
        if (!self.musicView) return;
        self.musicView.translatesAutoresizingMaskIntoConstraints = false;
        [NSLayoutConstraint activateConstraints:@[
            [self.musicView.topAnchor constraintEqualToAnchor:self.topAnchor],
            [self.musicView.leftAnchor constraintEqualToAnchor:self.leftAnchor],
            [self.musicView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
            [self.musicView.rightAnchor constraintEqualToAnchor:self.rightAnchor],
        ]];

        self.blurEffectView.translatesAutoresizingMaskIntoConstraints = false;
        [NSLayoutConstraint activateConstraints:@[
            [self.blurEffectView.topAnchor constraintEqualToAnchor:self.musicView.topAnchor],
            [self.blurEffectView.leftAnchor constraintEqualToAnchor:self.musicView.leftAnchor],
            [self.blurEffectView.bottomAnchor constraintEqualToAnchor:self.musicView.bottomAnchor],
            [self.blurEffectView.rightAnchor constraintEqualToAnchor:self.musicView.rightAnchor]
        ]];

        self.stackView.translatesAutoresizingMaskIntoConstraints = false;
        [NSLayoutConstraint activateConstraints:@[
            [self.stackView.topAnchor constraintEqualToAnchor:self.musicView.topAnchor constant:height/8],
            [self.stackView.leftAnchor constraintEqualToAnchor:self.musicView.leftAnchor constant:height/8],
            [self.stackView.bottomAnchor constraintEqualToAnchor:self.musicView.bottomAnchor constant:-height/8],
            [self.stackView.rightAnchor constraintEqualToAnchor:self.musicView.rightAnchor constant:-height/8]
        ]];

        self.shadowView.translatesAutoresizingMaskIntoConstraints = false;
        [NSLayoutConstraint activateConstraints:@[
            [self.shadowView.widthAnchor constraintEqualToConstant:height * 4.5/10],
            [self.shadowView.heightAnchor constraintEqualToConstant:height * 4.5/10]
        ]];

        self.circleView.translatesAutoresizingMaskIntoConstraints = false;
        [NSLayoutConstraint activateConstraints:@[
            [self.circleView.widthAnchor constraintEqualToConstant:height * 4.5/10],
            [self.circleView.heightAnchor constraintEqualToConstant:height * 4.5/10]
        ]];

        self.artworkView.translatesAutoresizingMaskIntoConstraints = false;
        [NSLayoutConstraint activateConstraints:@[
            [self.artworkView.widthAnchor constraintEqualToConstant:height * 4.5/10],
            [self.artworkView.heightAnchor constraintEqualToConstant:height * 4.5/10],
            [self.artworkView.centerYAnchor constraintEqualToAnchor:self.circleView.centerYAnchor],
            [self.artworkView.centerXAnchor constraintEqualToAnchor:self.circleView.centerXAnchor]
        ]];

        self.labelStackView.translatesAutoresizingMaskIntoConstraints = false;
        [NSLayoutConstraint activateConstraints:@[
            [self.labelStackView.widthAnchor constraintEqualToConstant:height * 2.2/10],
            [self.labelStackView.heightAnchor constraintEqualToConstant:height * 2.2/10]
        ]];

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false;
        [NSLayoutConstraint activateConstraints:@[
            [self.titleLabel.leftAnchor constraintEqualToAnchor:self.stackView.leftAnchor],
            [self.titleLabel.rightAnchor constraintEqualToAnchor:self.stackView.rightAnchor]
        ]];

        self.artistLabel.translatesAutoresizingMaskIntoConstraints = false;
        [NSLayoutConstraint activateConstraints:@[
            [self.artistLabel.leftAnchor constraintEqualToAnchor:self.stackView.leftAnchor],
            [self.artistLabel.rightAnchor constraintEqualToAnchor:self.stackView.rightAnchor]
        ]];

        self.gestureView.translatesAutoresizingMaskIntoConstraints = false;
        [NSLayoutConstraint activateConstraints:@[
            [self.gestureView.topAnchor constraintEqualToAnchor:self.musicView.topAnchor],
            [self.gestureView.leftAnchor constraintEqualToAnchor:self.musicView.leftAnchor],
            [self.gestureView.bottomAnchor constraintEqualToAnchor:self.musicView.bottomAnchor],
            [self.gestureView.rightAnchor constraintEqualToAnchor:self.musicView.rightAnchor]
        ]];
    }
    -(void)playOrPauseGesture:(UITapGestureRecognizer *)recognizer {
        if ([recognizer state] == UIGestureRecognizerStateEnded){
            MRMediaRemoteSendCommand(MRMediaRemoteCommandTogglePlayPause, nil);
        }
    }
    -(void)skipOrRewindGesture:(UISwipeGestureRecognizer *)recognizer {
        if ([recognizer state] == UIGestureRecognizerStateEnded) {
            if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft){
                MRMediaRemoteSendCommand(MRMediaRemoteCommandPreviousTrack, nil);
            }

            if (recognizer.direction == UISwipeGestureRecognizerDirectionRight){
                MRMediaRemoteSendCommand(MRMediaRemoteCommandNextTrack, nil);
            }
        }
    }
    -(UIColor *)averageColor:(UIImage *)image alpha:(CGFloat)alpha {
        NSUInteger red = 0;
        NSUInteger green = 0;
        NSUInteger blue = 0;

        struct pixel* pixels = (struct pixel*) calloc(1, image.size.width * image.size.height * sizeof(struct pixel));

        if (pixels != nil) {
            CGContextRef context = CGBitmapContextCreate( (void*) pixels, image.size.width, image.size.height, 8, image.size.width * 4, CGImageGetColorSpace(image.CGImage), kCGImageAlphaPremultipliedLast);
            if (context != NULL) {
                CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, image.size.width, image.size.height), image.CGImage);

                NSUInteger numberOfPixels = image.size.width * image.size.height;
                for (int i=0; i<numberOfPixels; i++) {
                    red += pixels[i].r;
                    green += pixels[i].g;
                    blue += pixels[i].b;
                }
                red /= numberOfPixels;
                green /= numberOfPixels;
                blue/= numberOfPixels;
                CGContextRelease(context);
            }
            free(pixels);
        }
        UIColor *averageColor = [UIColor colorWithRed:red/255.0f green:green/255.0f blue:blue/255.0f alpha:alpha];
        CGFloat h, s, b, a;
        [averageColor getHue:&h saturation:&s brightness:&b alpha:&a];
        return [UIColor colorWithHue:h saturation:s * 1.5 brightness:b alpha:a];
    }
#pragma mark ミュージック情報
    -(void)getMusicInfo:(NSNotification *)notification {
        MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef result) {
            if (result) {
                NSDictionary *dict = (__bridge NSDictionary *)result;
                if(dict) {
                    if ([dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoArtworkData]) {
                        self.artworkView.image = [UIImage imageWithData:[dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoArtworkData]];
                        self.titleLabel.textColor = [self averageColor:self.artworkView.image alpha:1.0];
                        self.shadowView.layer.shadowColor = [[self averageColor:self.artworkView.image alpha:1.0] CGColor];
                    }else{
                        self.artworkView.image = nil;
                    }

                    if ([dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoTitle]) {
                        [self.titleLabel setText:[NSString stringWithFormat:@"%@", [dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoTitle]]];
                    }else{
                        [self.titleLabel setText:@""];
                    }

                    if ([dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoArtist]){
                        [self.artistLabel setText:[NSString stringWithFormat:@"%@", [dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoArtist]]];
                    }else {
                        [self.artistLabel setText:@""];
                    }

                    if ([dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoDuration]) {
                        self.musicDurationString = [NSString stringWithFormat:@"%@", [dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoDuration]];
                    }else{
                        self.musicDurationString = @"0.0";
                    }
                    self.musicDuration = [self.musicDurationString floatValue];

                    if ([dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoElapsedTime]){
                        self.currentElapsedTimeString = [NSString stringWithFormat:@"%@", [dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoElapsedTime]];
                    }else{
                        self.currentElapsedTimeString = @"0.0";
                    }

                    if (self.elapsedTime < 0.95) {
                        self.currentElapsedTime = [self.currentElapsedTimeString floatValue] / self.musicDuration;
                        self.elapsedTime = self.currentElapsedTime;
                    }

                    if (self.elapsedTime >= 1.0 || ![self.titleLabel.text isEqualToString:self.savedText]) {
                        [self.circleView setProgress:0.0 animated:NO];
                        self.elapsedTime = 0.0;
                    }

                    if(isPlaying)
                        [self getElapsedTimeInfo];
                }
            }
        });

    }
    -(void)getElapsedTimeInfo {
        self.savedText = self.titleLabel.text;
        if(_progress)
            dispatch_source_cancel(_progress);

        _progress = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_event_handler(_progress, ^{
            self.elapsedTime = self.elapsedTime + 1/ self.musicDuration;
            if(self.elapsedTime >= 1.0) {
                dispatch_source_cancel(_progress);
                [self.circleView setProgress:1.0 animated:true];
            } else {
                [self.circleView setProgress:self.elapsedTime animated:true];
            }
        });
        dispatch_time_t startTimer = dispatch_time(DISPATCH_TIME_NOW, 0);
        dispatch_source_set_timer(_progress, startTimer, 1.0 * NSEC_PER_SEC, 0);
        dispatch_resume(_progress);
    }
    -(void)playerStatus{
        MRMediaRemoteGetNowPlayingApplicationIsPlaying(dispatch_get_main_queue(), ^(Boolean isPlayingNow) {
            if ((BOOL)isPlayingNow) {
                isPlaying = true;
            }else {
                isPlaying = false;
                if (_progress)
                    dispatch_source_cancel(_progress);
            }
        });
    }
    /*-(void)playingDidChange:(NSNotification *)notification {
        MRMediaRemoteGetNowPlayingApplicationIsPlaying(dispatch_get_main_queue(), ^(Boolean isPlayingNow) {
            if (!isPlayingNow) {
                isPlaying = NO;
                if (_progress)
                    dispatch_source_cancel(_progress);
            } else {
                isPlaying = true;
            }
        });
    }*/
@end
