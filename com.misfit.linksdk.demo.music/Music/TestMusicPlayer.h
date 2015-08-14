#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@protocol TestPlayerDelegate <NSObject>

- (void) playDidBegin;

- (void) playDidPause;

@end

@interface TestMusicPlayer : NSObject

@property (nonatomic,readonly) NSArray * albums;
@property (nonatomic,readonly) BOOL isPlaying;
@property (nonatomic,weak) id<TestPlayerDelegate> delegate;

+(TestMusicPlayer *) sharedInstance;;
-(void) playSongWithId:(NSNumber*)songId songTitle:(NSString*)songTitle artist:(NSString*)artist;
-(void) pause;
-(void) play;
-(void) toggle;
-(void) advanceToNextSong;
-(void) clear;
-(void) remoteControlReceivedWithEvent:(UIEvent *)receivedEvent;
-(void) putAlbums:(NSArray *)albums;
-(NSDictionary *) getCurrentSong;
-(NSDictionary *) getCurrentAlbum;
@end
