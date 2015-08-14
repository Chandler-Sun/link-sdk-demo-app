#import "AppDelegate.h"
#import "DetailViewController.h"
#import <MisfitLinkSDK/MisfitLinkSDK.h>
#import "MusicQuery.h"
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate ()<MFLGestureCommandDelegate,TestPlayerDelegate>
@property (nonatomic) NSInteger * lastPlayedIndex;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    //you can also set the buttonEventDelegate in somewhere else.
    [TestMusicPlayer sharedInstance].delegate = self;
    [MFLSession sharedInstance].gestureCommandDelegate = self;
    return YES;
}

#pragma mark - MFLGestureCommandDelegate

- (void) performActionByCommand:(MFLCommand *)command completion:(void (^)(MFLActionResultType result))completion
{
    if ([command.name isEqualToString:@"PlayAndPauseMusic"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TestMusicPlayer sharedInstance] toggle];
        });
    }
    else if ([command.name isEqualToString:@"NextSong"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[TestMusicPlayer sharedInstance] advanceToNextSong];
        });
    }
    completion(MFLActionResultTypeSuccess);
}

#pragma mark - TestPlayerDelegate

- (void) playDidBegin
{
    NSDictionary * album = [[TestMusicPlayer sharedInstance] getCurrentAlbum];
    NSDictionary * song = [[TestMusicPlayer sharedInstance] getCurrentSong];
    if (!self.detialView) {
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        DetailViewController * vc = (DetailViewController *)[sb instantiateViewControllerWithIdentifier:@"Detail"];
        self.detialView = vc;
        [self.detialView setArtistAlbum:album andSong:song];        
        UINavigationController * nc = (UINavigationController *)self.window.rootViewController;
        dispatch_async(dispatch_get_main_queue(), ^{
            [nc pushViewController:vc animated:YES];
        });
    }
    else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.detialView setArtistAlbum:album andSong:song];
        });
        
    }
    
}

- (void) playDidPause
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.detialView updatePlayButtonState];
    });
}

#pragma mark - methods that need to be overrided

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[MFLSession sharedInstance] handleDidBecomeActive];
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    BOOL handled = NO;
    if ([[MFLSession sharedInstance] canHandleOpenUrl:url])
    {
        handled = [[MFLSession sharedInstance] handleOpenURL:url];
    }
    return handled;
}



#pragma mark - other methods

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
