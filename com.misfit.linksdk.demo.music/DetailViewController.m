#import "DetailViewController.h"
#import "TestMusicPlayer.h"
#import <MisfitLinkSDK/MisfitLinkSDK.h>
#import "AppDelegate.h"

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *songTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *songIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *albumNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

-(void)setArtistAlbum:(NSDictionary *)newArtistAlbum andSong:(NSDictionary *)newSong {
    _artistAlbum = newArtistAlbum;
    _songInfo = newSong;
    // Update the view.
    [self configureView];
}

-(void)updatePlayButtonState
{
    if ([TestMusicPlayer sharedInstance].isPlaying) {
        [self.playPauseButton setTitle:@"Pause" forState:UIControlStateNormal];
    }
    else {
        [self.playPauseButton setTitle:@"Play" forState:UIControlStateNormal];
    }
    
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.artistAlbum) {
        self.artistNameLabel.text = self.artistAlbum[@"artist"];
        self.albumNameLabel.text = self.artistAlbum[@"album"];
        self.songTitleLabel.text = self.songInfo[@"title"];
        self.songIdLabel.text = [NSString stringWithFormat:@"%@", self.songInfo[@"songId"]];
    }
    [self updatePlayButtonState];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self configureView];
    

}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    //play song
    if (((NSNumber *)[[[TestMusicPlayer sharedInstance] getCurrentSong]valueForKey:@"songId"]).intValue == ((NSNumber *)[self.songInfo valueForKey:@"songId"]).intValue) {
        [[TestMusicPlayer sharedInstance] play];
    }
    else {
        [[TestMusicPlayer sharedInstance] playSongWithId:self.songInfo[@"songId"] songTitle:self.songInfo[@"title"] artist:self.artistAlbum[@"artist"]];
    }
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
    
}

-(void) viewWillDisappear:(BOOL)animated
{
    [self resignFirstResponder];
    [[TestMusicPlayer sharedInstance] pause];
    [super viewWillDisappear:animated];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - user actions
-(IBAction)playPauseButtonTapped:(UIButton*)button
{
    [[TestMusicPlayer sharedInstance] toggle];
}

-(IBAction)nextButtonTapped:(UIButton*)button
{
    [[TestMusicPlayer sharedInstance] advanceToNextSong];
}

#pragma mark - remote control events
- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
    [[TestMusicPlayer sharedInstance] remoteControlReceivedWithEvent:receivedEvent];
}

#pragma mark - audio session management
- (BOOL) canBecomeFirstResponder {
    return YES;
}

@end



