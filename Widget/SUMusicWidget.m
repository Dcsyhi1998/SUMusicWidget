#import "SUMusicWidget.h"
#define save_path ROOT_PATH_NS_VAR(@"/Library/Airaw/Preferences/com.sugiuta.sumusicwidget.plist")

struct pixel {
    unsigned char r, g, b, a;
};
static NSString *titale_lbl;
static NSString *old_titale_lbl;

@implementation SUMusicWidget {
    int height;
    int type;
    BOOL isPlaying;
}
    -(void)Prefs{
        NSMutableDictionary *Dict = [NSMutableDictionary dictionaryWithContentsOfFile:save_path];
        type = Dict[@"kColorType"] ? [Dict[@"kColorType"] intValue] : 2;
    }
    -(instancetype)initWithFrame:(CGRect)arg1{
        self = [super initWithFrame:arg1];
        if(self){
            [self Prefs];
            isPlaying = false;
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
            self.artworkView.layer.cornerRadius =  height * 4.5/11 * 1/2;
            [self.artworkView setContentMode:UIViewContentModeScaleAspectFill];
            [self.circleView addSubview:self.artworkView];

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
            [self.gestureView setHidden:false];
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
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerStatus) name:@"kMRMediaRemoteNowPlayingApplicationPlaybackStateDidChangeNotification" object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerStatus) name:@"kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification" object:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[NSNotificationCenter defaultCenter] postNotificationName:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoDidChangeNotification object:nil];
                [self playerStatus];
            });
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
            [self.artworkView.widthAnchor constraintEqualToConstant:height * 4.5/11],
            [self.artworkView.heightAnchor constraintEqualToConstant:height * 4.5/11],
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
#pragma mark 色の平均を取得
    -(UIColor *)lighterColorForColor:(UIColor *)color{
        CGFloat r, g, b, a;
        if ([color getRed:&r green:&g blue:&b alpha:&a])
            return [UIColor colorWithRed:MIN(r + 0.2, 1.0)green:MIN(g + 0.2, 1.0)blue:MIN(b + 0.2, 1.0)alpha:a];
        return nil;
    }
    -(UIColor *)darkerColorForColor:(UIColor *)color{
        CGFloat r, g, b, a;
        if ([color getRed:&r green:&g blue:&b alpha:&a])
            return [UIColor colorWithRed:MAX(r - 0.2, 0.0)green:MAX(g - 0.2, 0.0)blue:MAX(b - 0.2, 0.0)alpha:a];
        return nil;
    }
    -(UIColor *)ImageColorAverage:(UIImage *)image alpha:(CGFloat)alpha style:(bool)style {
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        unsigned char rgba[4];
        CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);

        //Draw our image down to 1x1 pixels
        CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), image.CGImage);
        CGColorSpaceRelease(colorSpace);
        CGContextRelease(context);

        //Check if image alpha is 0
        UIColor *averageColor;
        if (rgba[3] == 0) {
            CGFloat imageAlpha = ((CGFloat)rgba[3])/255.0;
            CGFloat multiplier = imageAlpha/255.0;

            averageColor = [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier green:((CGFloat)rgba[1])*multiplier blue:((CGFloat)rgba[2])*multiplier alpha:alpha];
        }else {
            averageColor = [UIColor colorWithRed:((CGFloat)rgba[0])/255.0 green:((CGFloat)rgba[1])/255.0 blue:((CGFloat)rgba[2])/255.0 alpha:alpha];
        }
        averageColor = style ? [self darkerColorForColor:averageColor] : [self lighterColorForColor:averageColor];
        return averageColor;
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
                    //アルバの画像取得
                    if ([dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoArtworkData]) {
                        self.artworkView.image = [UIImage imageWithData:[dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoArtworkData]];

                        UIColor *col;
                        if(type == 2){
                            col = [self averageColor:self.artworkView.image alpha:1.0];
                        }else if(type == 0){
                            col = [self ImageColorAverage:self.artworkView.image alpha:1.0 style:false];
                        }else if(type == 1){
                            col = [self ImageColorAverage:self.artworkView.image alpha:1.0 style:true];
                        }
                        self.titleLabel.textColor = col;
                        self.shadowView.layer.shadowColor = col.CGColor;
                        self.circleView.trackFillColor = col;
                    }else{
                        self.artworkView.image = nil;
                    }

                    //音楽のタイトル取得
                    if([dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoTitle]){
                        [self.titleLabel setText:[NSString stringWithFormat:@"%@", [dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoTitle]]];
                        titale_lbl = self.titleLabel.text;
                    }else{
                        [self.titleLabel setText:@""];
                        titale_lbl = @"";
                    }

                    //音楽のアーティストの取得
                    if([dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoArtist]){
                        [self.artistLabel setText:[NSString stringWithFormat:@"%@", [dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoArtist]]];
                    }else {
                        [self.artistLabel setText:@""];
                    }

                    //曲の再生時間
                    if([dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoDuration]){
                        self.musicDurationString = [NSString stringWithFormat:@"%@", [dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoDuration]];
                    }else{
                        self.musicDurationString = @"0.0";
                    }
                    self.musicDuration = [self.musicDurationString floatValue];

                    //音楽の再生位置
                    if([dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoElapsedTime]){
                        self.currentElapsedTimeString = [NSString stringWithFormat:@"%@", [dict objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoElapsedTime]];
                    }else{
                        self.currentElapsedTimeString = @"0.0";
                    }

                    if(self.elapsedTime < 0.95){
                        self.elapsedTime = [self.currentElapsedTimeString floatValue] / self.musicDuration;
                    }
                    if(self.elapsedTime >= 1.0 || ![self.titleLabel.text isEqualToString:old_titale_lbl]){
                        [self.circleView setProgress:0.0];
                        self.elapsedTime = 0.0;
                    }
                    if(isPlaying){
                        [self getElapsedTimeInfo];
                    }
                    if([self.timer isValid]){
                        [self updateAnimation];
                    }
                }
            }
        });
    }
    -(void)getElapsedTimeInfo{
        if (![self.timer isValid] || self.timer == nil) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateAnimation) userInfo:nil repeats:YES];
        }
    }
    -(void)updateAnimation{
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            old_titale_lbl = titale_lbl;
            if (self.elapsedTime >= 1.0) {
                [self.timer invalidate];
                [self.circleView setProgress:1.0];
            } else {
                self.elapsedTime += 1.0 / self.musicDuration;
                [self.circleView setProgress:self.elapsedTime];
            }
        });
    }
    -(void)dealloc{
        if ([self.timer isValid]) {
            [self.timer invalidate];
            self.timer = nil;
        }
        // [super dealloc];
    }

    -(void)playerStatus{
        MRMediaRemoteGetNowPlayingApplicationIsPlaying(dispatch_get_main_queue(), ^(Boolean isPlayingNow) {
            if((BOOL)isPlayingNow){
                isPlaying = true;
            }else{
                isPlaying = false;
                if ([self.timer isValid]) {
                    [self.timer invalidate];
                    self.timer = nil;
                }
            }
        });
    }
@end
