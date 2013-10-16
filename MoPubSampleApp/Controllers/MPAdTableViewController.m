//
//  MPAdTableViewController.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPAdTableViewController.h"
#import "MPAdInfo.h"
#import "MPAdSection.h"
#import "MPBannerAdDetailViewController.h"
#import "MPInterstitialAdDetailViewController.h"
#import "MPManualAdViewController.h"
#import "MPMRectBannerAdDetailViewController.h"
#import "MPLeaderboardBannerAdDetailViewController.h"
#import "MPGlobal.h"

@interface MPAdTableViewController ()

@property (nonatomic, strong) NSArray *sections;

@end

@implementation MPAdTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithAdSections:(NSArray *)sections
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.sections = sections;

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_7_0
        if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
            self.edgesForExtendedLayout = UIRectEdgeNone;
        }
#endif
    }
    return self;
}

- (MPAdInfo *)infoAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.sections[indexPath.section] adAtIndex:indexPath.row];
}

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor colorWithRed:0.21 green:0.21 blue:0.21 alpha:1];
    self.tableView.separatorColor = [UIColor colorWithRed:0.31 green:0.31 blue:0.31 alpha:1];
    self.tableView.rowHeight = 50;
    self.tableView.sectionHeaderHeight = 30;

    self.title = @"Ads";
    self.tableView.accessibilityLabel = @"Ad Table View";
    [self.tableView reloadData];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Manual"
                                                                              style:UIBarButtonItemStyleDone
                                                                             target:self
                                                                             action:@selector(didTapManualButton:)];
    self.navigationItem.rightBarButtonItem.accessibilityLabel = @"Manual";

    [super viewDidLoad];
}

- (void)didTapManualButton:(id)sender
{
    [self.navigationController pushViewController:[[MPManualAdViewController alloc] init] animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.sections count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.sections[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text = [[self infoAtIndexPath:indexPath] title];
    cell.detailTextLabel.text = [[self infoAtIndexPath:indexPath] ID];
    cell.textLabel.textColor = [UIColor colorWithRed:0.42 green:0.66 blue:0.85 alpha:1];
    cell.detailTextLabel.textColor = [UIColor colorWithRed:0.86 green:0.86 blue:0.86 alpha:1];

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [self.sections[section] title];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MPAdInfo *info = [self infoAtIndexPath:indexPath];
    UIViewController *detailViewController = nil;

    switch (info.type) {
        case MPAdInfoBanner:
            detailViewController = [[MPBannerAdDetailViewController alloc] initWithAdInfo:info];
            break;
        case MPAdInfoMRectBanner:
            detailViewController = [[MPMRectBannerAdDetailViewController alloc] initWithAdInfo:info];
            break;
        case MPAdInfoLeaderboardBanner:
            detailViewController = [[MPLeaderboardBannerAdDetailViewController alloc] initWithAdInfo:info];
            break;
        case MPAdInfoInterstitial:
            detailViewController = [[MPInterstitialAdDetailViewController alloc] initWithAdInfo:info];
            break;
        default:
            break;
    }

    if (detailViewController) {
        [self.navigationController pushViewController:detailViewController animated:YES];
    }
}

@end
