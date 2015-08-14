#import "TestMusicPlayer.h"
#import "MusicQuery.h"
#import <AVFoundation/AVFoundation.h>

@interface TestMusicPlayer()
@property(nonatomic,strong) AVQueuePlayer *avQueuePlayer;
@property(nonatomic,strong) NSArray * albums;
@property(nonatomic,strong) NSArray * songs;
@property(nonatomic,weak) AVPlayerItem * currentMediaItem;
@property(nonatomic) int currentSongIndex;
@property(nonatomic) BOOL isPlaying;
@end

@implementation TestMusicPlayer

+(TestMusicPlayer *) sharedInstance
{
    static TestMusicPlayer *_sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[TestMusicPlayer alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver: _sharedInstance
                                                 selector: @selector(audioSessionInterrupted:)
                                                     name: AVAudioSessionInterruptionNotification
                                                   object: [AVAudioSession sharedInstance]];
        
        [[NSNotificationCenter defaultCenter] addObserver:_sharedInstance
                                                 selector:@selector(handleMediaServicesReset)
                                                     name:AVAudioSessionMediaServicesWereResetNotification
                                                   object:[AVAudioSession sharedInstance]];
        
        NSError *categoryError = nil;
        [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:&categoryError];
        if (categoryError) {
            NSLog(@"Error setting category! %@", [categoryError description]);
        }
        
        //activation of audio session
        NSError *activationError = nil;
        BOOL success = [[AVAudioSession sharedInstance] setActive: YES error: &activationError];
        if (!success) {
            if (activationError) {
                NSLog(@"Could not activate audio session. %@", [activationError localizedDescription]);
            } else {
                NSLog(@"audio session could not be activated!");
            }
        }
        
        [[MusicQuery new] queryForSongs:^(NSDictionary *result) {
            [_sharedInstance putAlbums:[result objectForKey:@"albums"]];
        }];
    });
    return _sharedInstance;
}

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.isPlaying = NO;
        self.albums = [[NSArray alloc]init];
        self.currentSongIndex = -1;
    }
    return self;
}

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

-(void)putAlbums:(NSArray *)albums
{
    [self clear];
    self.songs = nil;
    self.currentMediaItem = nil;
    self.currentSongIndex = -1;
    
    self.albums = albums;
    
    NSMutableArray * tempArray = [[NSMutableArray alloc]init];
    if (self.albums.count > 0) {
        for (NSDictionary * albumInfo in self.albums) {
            NSArray * songInfos = [albumInfo objectForKey:@"songs"];
            if ((songInfos != nil) && (songInfos.count > 0)) {
                for (NSDictionary * songInfo in songInfos) {
                    [tempArray addObject:songInfo];
                }
            }
        }
        self.songs = [[NSArray alloc]initWithArray:tempArray];
    }
    
    if (self.songs.count > 0) {
        self.currentSongIndex = 0;
    }
    else
    {
        self.currentSongIndex = -1;
    }
}

-(NSDictionary *) getCurrentSong
{
    if ((self.currentSongIndex == -1) || (!self.songs) || (self.songs.count == 0)) {
        return nil;
    }
    return [self.songs objectAtIndex:self.currentSongIndex];
}

-(NSDictionary *) getCurrentAlbum
{
    NSDictionary * currentSongInfo = [self getCurrentSong];
    return [self getAlbumBySong:currentSongInfo];
}

-(NSDictionary *) getAlbumBySong:(NSDictionary *) song
{
    for (NSDictionary * albumInfo in self.albums) {
        NSArray * songsInAlbum = [albumInfo objectForKey:@"songs"];
        if ((songsInAlbum) && ([songsInAlbum containsObject:song])) {
            return albumInfo;
        }
    }
    return nil;
}

-(void) playSongWithId:(NSNumber*)songId songTitle:(NSString*)songTitle artist:(NSString*)artist
{
    [[MusicQuery new] queryForSongWithId:songId completion:^(MPMediaItem *item) {
        if (item) {
            NSURL *assetUrl = [item valueForProperty: MPMediaItemPropertyAssetURL];
            AVPlayerItem *avSongItem = [[AVPlayerItem alloc] initWithURL:assetUrl];
            if (avSongItem) {
                
                [self clear];
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying:) name:AVPlayerItemDidPlayToEndTimeNotification object:avSongItem];
                
                [[self avQueuePlayer] insertItem:avSongItem afterItem:nil];
                
                self.currentMediaItem = avSongItem;
                
                [self setSongToCurrentWithSongId:songId];
                
                [self performPlay];
                
                [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = @{MPMediaItemPropertyTitle: songTitle, MPMediaItemPropertyArtist: artist};

            }
        }
    }];
}

-(void) advanceToNextSong
{
    NSDictionary * songInfo = [self getNextSong];
    NSDictionary * albumInfo = [self getAlbumBySong:songInfo];
    if (!songInfo) {
        [self pause];
        [self clear];
        return;
    }
    
    [self playSongWithId:[songInfo valueForKey:@"songId"] songTitle:[songInfo valueForKey:@"title"] artist:[albumInfo valueForKey:@"artist"]];
}


-(NSDictionary *) getNextSong
{
    if ((self.currentSongIndex == -1) || (!self.songs) || (self.songs.count == 0)) {
        return nil;
    }
    int songIndex = self.currentSongIndex;
    if ((songIndex+1) >= self.songs.count) {
        songIndex = 0;
    }
    else
    {
        songIndex++;
    }
    return [self.songs objectAtIndex:songIndex];
}

-(AVPlayer *)avQueuePlayer
{
    if (!_avQueuePlayer) {
        _avQueuePlayer = [[AVQueuePlayer alloc]init];
    }
    
    return _avQueuePlayer;
}

-(void) setSongToCurrentWithSongId:(NSNumber *) songId
{
    
    for (NSDictionary * songInfo in self.songs) {
        NSNumber * persistedSongId = [songInfo valueForKey:@"songId"];
        if (persistedSongId == songId) {
            self.currentSongIndex = (int)[self.songs indexOfObject:songInfo];
            return;
        }
    }
    self.currentSongIndex = -1;
}

#pragma mark - notifications
-(void)audioSessionInterrupted:(NSNotification*)interruptionNotification
{
    NSLog(@"interruption received: %@", interruptionNotification);
//    [self pause];
    
    NSNumber *interruptionType = [[interruptionNotification userInfo] objectForKey:AVAudioSessionInterruptionTypeKey];
    NSNumber *interruptionOption = [[interruptionNotification userInfo] objectForKey:AVAudioSessionInterruptionOptionKey];
    
    switch (interruptionType.unsignedIntegerValue) {
        case AVAudioSessionInterruptionTypeBegan:{
            // • Audio has stopped, already inactive
            // • Change state of UI, etc., to reflect non-playing state
        } break;
        case AVAudioSessionInterruptionTypeEnded:{
            NSError * activationError = nil;
            [[AVAudioSession sharedInstance] setActive: YES error: &activationError];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1), dispatch_get_main_queue(), ^{
                [self play];
            });
            // • Make session active
            // • Update user interface
            // • AVAudioSessionInterruptionOptionShouldResume option
            if (interruptionOption.unsignedIntegerValue == AVAudioSessionInterruptionOptionShouldResume) {
                NSLog(@"AVAudioSessionInterruptionOptionShouldResume");
                // Here you should continue playback.
//                [self play];
            }
        } break;
        default:
            break;
    }
}
-(void)handleMediaServicesReset
{
    NSLog(@"handleMediaServicesReset");
}

-(void)itemDidFinishPlaying:(NSNotification *) notification
{
    [self advanceToNextSong];
}

#pragma mark - player actions
-(void) pause
{
    [[self avQueuePlayer] pause];
    self.isPlaying = NO;
    if (self.delegate) {
        [self.delegate playDidPause];
    }
}

-(void) performPlay
{
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [[self avQueuePlayer] play];
    self.isPlaying = YES;
    if (self.delegate) {
        [self.delegate playDidBegin];
    }
}

-(void) play
{
    if ([[AVAudioSession sharedInstance]isOtherAudioPlaying]) {
        [self pause];
    }
    if (self.currentMediaItem) {
        [self performPlay];
    }
    else {
        NSDictionary * currentSong = [self getCurrentSong];
        NSDictionary * currentAlbum = [self getCurrentAlbum];
        [self playSongWithId:[currentSong objectForKey:@"songId"] songTitle:[currentSong objectForKey:@"title"] artist:[currentAlbum objectForKey:@"artist"]];
    }
    
}

-(void) toggle
{
    if (self.isPlaying) {
        [self pause];
    }
    else
    {
        [self play];
    }
}

-(void) clear
{
    self.isPlaying = NO;
    if (self.currentMediaItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self.currentMediaItem];
    }
    
    [[self avQueuePlayer] removeAllItems];
}

#pragma mark - remote control events
     
- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    NSLog(@"received event!");
    
    if (receivedEvent.type == UIEventTypeRemoteControl) {
        switch (receivedEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause: {
                if ([self avQueuePlayer].rate > 0.0) {
                    [[self avQueuePlayer] pause];
                } else {
                    [[self avQueuePlayer] play];
                }

                break;
            }
            case UIEventSubtypeRemoteControlPlay: {
                [[self avQueuePlayer] play];
                break;
            }
            case UIEventSubtypeRemoteControlPause: {
                [[self avQueuePlayer] pause];
                break;
            }
            default:
                break;
        }
    }
}

@end
