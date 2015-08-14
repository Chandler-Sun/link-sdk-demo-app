//
//  DetailViewController.h
//  BackgroundAudioObjc
//
//  Created by Jonathan Sagorin on 3/4/2015.
//
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController
@property(nonatomic,strong)NSDictionary *artistAlbum;
@property(nonatomic,assign)NSDictionary *songInfo;

-(void)setArtistAlbum:(NSDictionary *)newArtistAlbum andSong:(NSDictionary *)newSong;

-(void)updatePlayButtonState;

@end

