#import "MasterViewController.h"
#import "DetailViewController.h"
#import "MusicQuery.h"
#import "AppDelegate.h"

@interface MasterViewController ()

@end

@implementation MasterViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [TestMusicPlayer sharedInstance].albums.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *artistAlbum = [[TestMusicPlayer sharedInstance].albums objectAtIndex:section];
    return  [artistAlbum[@"songs"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    NSDictionary *artistAlbum = [[TestMusicPlayer sharedInstance].albums objectAtIndex:indexPath.section];
    NSDictionary *song = [artistAlbum[@"songs"] objectAtIndex:indexPath.row];
    cell.textLabel.text = song[@"title"];
    cell.detailTextLabel.text = artistAlbum[@"album"];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDictionary *artistAlbum = [[TestMusicPlayer sharedInstance].albums objectAtIndex:indexPath.section];
        DetailViewController *detailVC = [segue destinationViewController];
        detailVC.artistAlbum = artistAlbum;
        NSArray * songs = [artistAlbum objectForKey:@"songs"];
        NSDictionary * songInfo = [songs objectAtIndex:indexPath.row];
        detailVC.songInfo = songInfo;
        ((AppDelegate *)[[UIApplication sharedApplication]delegate]).detialView = detailVC;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSDictionary *artistAlbum = [[TestMusicPlayer sharedInstance].albums objectAtIndex:section];
    return artistAlbum[@"artist"];
}



@end
