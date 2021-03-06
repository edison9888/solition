//
//  RSTableViewController.m
//  RenrenSixin
//
//  Created by zhongsheng on 12-5-28.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import "RSTableViewController.h"
#import "RSTableViewDataSource.h"
#import "RSBaseTableView.h"
#import "RSTableViewCell.h"
#import "RSErrorView.h"
#import "RSTableViewLoadMoreItem.h"
#import "RSTableViewLoadMoreCell.h"
#import "RSSearchDisplayController.h"
#import "SVPullToRefresh.h"
#import "UIWindow+RscExt.h"

@interface RSTableViewController (delegate);

@end

@interface RSTableViewController (Private);

- (void)loadMoreAction;

@end

@implementation RSTableViewController

@synthesize error = _error;
@synthesize tableView = _tableView;
@synthesize tableWatermarkView = _tableWatermarkView;
@synthesize tableOverlayView = _tableOverlayView;
@synthesize loadingView = _loadingView;
@synthesize errorView = _errorView;
@synthesize emptyView = _emptyView;
@synthesize tableViewStyle = _tableViewStyle;
@synthesize showTableShadows = _showTableShadows;
@synthesize dataSource = _dataSource;
@synthesize loadingData = _loadingData;
@synthesize searchViewController = _searchViewController;

- (id)initWithStyle:(UITableViewStyle)style
{
    if (self = [super init]) {
        _tableViewStyle = style;
        _loadingData = NO;
    }

    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    }

    return self;
}

#pragma mark -
#pragma mark Private

- (NSString *)defaultTitleForLoading
{
    return NSLocalizedString(@"Loading...", @"");
}

- (void)addToOverlayView:(UIView *)view
{
    if (!_tableOverlayView) {
        CGRect frame = self.view.bounds;
        _tableOverlayView = [[UIView alloc] initWithFrame:frame];
        _tableOverlayView.autoresizesSubviews = YES;
        _tableOverlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth
            | UIViewAutoresizingFlexibleHeight;
        NSInteger tableIndex = [_tableView.superview.subviews indexOfObject:_tableView];

        if (tableIndex != NSNotFound) {
            [_tableView.superview addSubview:_tableOverlayView];
        }
    }

    [_tableOverlayView removeAllSubviews];
    UIEdgeInsets edgeInsets = [_dataSource emptyViewEdgeInsets];
    CGRect       viewFrame = _tableOverlayView.bounds;
    viewFrame.origin.x += (edgeInsets.right - edgeInsets.left);
    viewFrame.origin.y += (edgeInsets.top - edgeInsets.bottom);
    view.frame = viewFrame;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_tableOverlayView addSubview:view];
}

- (void)addToWatermarkView:(UIView *)view
{
    if (!_tableWatermarkView) {
        CGRect frame = self.view.bounds;
        _tableWatermarkView = [[UIView alloc] initWithFrame:frame];
        _tableWatermarkView.autoresizesSubviews = YES;
        _tableWatermarkView.autoresizingMask = UIViewAutoresizingFlexibleWidth
            | UIViewAutoresizingFlexibleHeight;
        [_tableView addSubview:_tableWatermarkView];
    }

    [_tableWatermarkView removeAllSubviews];
    UIEdgeInsets edgeInsets = [_dataSource emptyViewEdgeInsets];
    CGRect       viewFrame = _tableWatermarkView.bounds;
    viewFrame.origin.x += (edgeInsets.right - edgeInsets.left);
    viewFrame.origin.y += (edgeInsets.top - edgeInsets.bottom);
    view.frame = viewFrame;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [_tableWatermarkView addSubview:view];

    if (![_tableWatermarkView superview]) {
        [_tableView addSubview:_tableWatermarkView];
    }
}

- (void)resetOverlayView
{
    if (_tableOverlayView && !_tableOverlayView.subviews.count) {
        [_tableOverlayView removeFromSuperview];
    }
}

- (void)resetWatermarkView
{
    if (_tableWatermarkView && !_tableWatermarkView.subviews.count) {
        [_tableWatermarkView removeFromSuperview];
    }
}

- (void)addSubviewOverTableView:(UIView *)view
{
    NSInteger tableIndex = [_tableView.superview.subviews
        indexOfObject:_tableView];

    if (NSNotFound != tableIndex) {
        [_tableView.superview addSubview:view];
    }
}

- (void)layoutOverlayView
{
    if (_tableOverlayView) {
        _tableOverlayView.frame = [self rectForOverlayView];
    }
}

- (void)layoutWatermarkView
{
    if (_tableWatermarkView) {
        _tableWatermarkView.frame = [self rectForWatermarkView];
    }
}

- (void)fadeOutView:(UIView *)view
{
    [UIView beginAnimations:nil context:(__bridge void *)view];
    [UIView setAnimationDuration:.3f];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(fadingOutViewDidStop:finished:context:)];
    view.alpha = 0;
    [UIView commitAnimations];
}

- (void)fadingOutViewDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    UIView *view = (__bridge UIView *)context;

    [view removeFromSuperview];
}

- (void)setSearchViewController:(RSTableViewController *)searchViewController
{
    if (_searchViewController == searchViewController) {
        return;
    }

    _searchViewController = searchViewController;

    if (searchViewController) {
        if (nil == _searchController) {
            UISearchBar *searchBar = [[UISearchBar alloc] init];
            [searchBar sizeToFit];
            _searchController = [[RSSearchDisplayController alloc] initWithSearchBar:searchBar
                                                                  contentsController:self];
        }

        _searchController.searchResultsViewController = searchViewController;
    } else {
        _searchController.searchResultsViewController = nil;
    }
}

#pragma mark -
#pragma mark UIViewController

- (void)loadView
{
    [super loadView];

    _shouldLoadTableView = YES;
    self.tableView.delegate = self;
    self.tableView.dataSource = self.dataSource;
    self.tableView.showsPullToRefresh = NO;     // default is NO
    self.tableView.showsInfiniteScrolling = NO; // default is NO
    [self.view addSubview:self.tableView];
    self.tableView.frame = self.view.bounds;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.backgroundView = nil;

    self.dataSource.actionButtonDelegate = self;
}

- (void)dealloc
{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (_lastInterfaceOrientation != self.interfaceOrientation) {
        _lastInterfaceOrientation = self.interfaceOrientation;
        [_tableView reloadData];
    } else if ([_tableView isKindOfClass:[RSBaseTableView class]]) {
        RSBaseTableView *tableView = (RSBaseTableView *)_tableView;
        tableView.showShadows = _showTableShadows;
    }

    [_tableView deselectRowAtIndexPath:[_tableView indexPathForSelectedRow] animated:animated];

    if (_shouldLoadTableView) {
        _shouldLoadTableView = NO;

        __weak RSTableViewController *tableViewController = self;

        // 添加下拉刷新功能
        if (self.tableView.showsPullToRefresh) {
            [self.tableView addPullToRefreshWithActionHandler:^{
                [tableViewController performSelectorOnMainThread:@selector(pullToRefreshAction) withObject:nil waitUntilDone:YES];
            }];
        }

        // 添加无限下翻功能
        if (self.tableView.showsInfiniteScrolling) {
            [self.tableView addInfiniteScrollingWithActionHandler:^{
                [tableViewController performSelectorOnMainThread:@selector(infiniteScrollingAction) withObject:nil waitUntilDone:YES];
            }];
        }
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)unLoadViews
{
    self.tableView = nil;
    [super unLoadViews];
}

- (void)releaseReuseTableviewCells:(UITableView *)tableview
{
    @try {
        NSString     *reuseCells = @"reusableTableCells";
        NSDictionary *data = [tableview valueForKey:reuseCells];
        DDLogInfo(@"dealloc reuse able tableview cells--- %@", data);

        NSArray *values = data.allValues;

        for (int i = 0; i < values.count; i++) {
            NSArray *views = values[i];

            for (int j = 0; j < views.count; j++) {
                UIView *v = views[j];
                [v removeFromSuperview];
            }
        }

        [tableview setValue:[NSMutableDictionary dictionary] forKey:reuseCells];
    }
    @catch(NSException *exception) {
        DDLogInfo(@"%@", exception.reason);
    }

    @finally {
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:animated];
}

- (void)showLoading:(BOOL)show
{
    if (show) {
        [self showEmpty:NO];
        [self showError:NO];

        if (self.dataSource.empty) {
            [[HudHelper getInstance] showHudOnView:self.view
                                        caption:NSLocalizedStringFromTable(@"载入中...", RS_CURRENT_LANGUAGE_TABLE, nil)
                                          image:nil
                                      acitivity:YES
                                   autoHideTime:0.0f];
        }
    } else {
        [[HudHelper getInstance] hideHudInView:self.view];
    }
}

- (void)showError:(BOOL)show
{
    if (show) {
        NSString *title = [_dataSource titleForError:self.error];
        NSString *subtitle = [_dataSource subtitleForError:self.error];
        UIImage  *image = [_dataSource imageForError:self.error];

        if (title.length || subtitle.length || image) {
            RSErrorView *errorView = [[RSErrorView alloc] initWithTitle:title
                                                               subtitle:subtitle
                                                                  image:image];
            errorView.backgroundColor = self.view.backgroundColor;
            self.errorView = errorView;
        } else {
            if ([[self.tableOverlayView subviews] containsObject:self.errorView]) {
                [self.errorView removeFromSuperview];
                self.errorView = nil;
            }
        }
    } else {
        if ([[self.tableOverlayView subviews] containsObject:self.errorView]) {
            [self.errorView removeFromSuperview];
            self.errorView = nil;
        }
    }
}

- (void)showEmpty:(BOOL)show
{
    if (show) {
        NSString *title = [_dataSource titleForEmpty];
        NSString *subtitle = [_dataSource subtitleForEmpty];
        UIImage  *image = [_dataSource imageForEmpty];
        UIImage  *titleImage = [_dataSource titleImageForEmpty];
        BOOL     executable = [_dataSource buttonExecutable];

        if (title.length || subtitle.length || image) {
            RSErrorView *errorView = [[RSErrorView alloc] initWithTitle:title
                                                               subtitle:subtitle
                                                             titleImage:titleImage
                                                         watermarkImage:image];

            if (executable && title) {
                [errorView addTarget:self action:@selector(emptyViewButtonAction)];
            }

            self.emptyView = errorView;
        } else {
            if ([[self.tableWatermarkView subviews] containsObject:self.emptyView]) {
                [self.emptyView removeFromSuperview];
                self.emptyView = nil;
            }
        }
    } else {
        if ([[self.tableWatermarkView subviews] containsObject:self.emptyView]) {
            [self.emptyView removeFromSuperview];
            self.emptyView = nil;
        }
    }
}

- (void)search:(NSString *)kw
{
}

- (void)cancelSearch
{
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
}

#pragma mark -
#pragma mark Public
- (void)createModel
{
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (UITableView *)tableView
{
    if (nil == _tableView) {
        _tableView = [[RSBaseTableView alloc] initWithFrame:CGRectZero style:_tableViewStyle];
        _tableView.frame = CGRectZero;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth
            | UIViewAutoresizingFlexibleHeight;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }

    return _tableView;
}

- (void)setTableView:(UITableView *)tableView
{
    if (tableView != _tableView) {
        if (_tableView) {
            if (![UIDevice isHigherIOS7]) {
                [_tableView removeFromSuperview];
            }
        }

        if (tableView == nil) {
            _tableView = nil;
            self.tableOverlayView = nil;
        } else {
            _tableView = tableView;
            _tableView.delegate = nil;
            _tableView.delegate = self;
            _tableView.dataSource = self.dataSource;

            if (!_tableView.superview) {
                [self.view addSubview:_tableView];
            }
        }
    }
}

- (void)setTableOverlayView:(UIView *)tableOverlayView animated:(BOOL)animated
{
    if (tableOverlayView != _tableOverlayView) {
        if (_tableOverlayView) {
            if (animated) {
                [self fadeOutView:_tableOverlayView];
            } else {
                [_tableOverlayView removeFromSuperview];
            }
        }

        _tableOverlayView = tableOverlayView;

        if (_tableOverlayView) {
            _tableOverlayView.frame = [self rectForOverlayView];
            [self addToOverlayView:_tableOverlayView];
        }
    }
}

- (void)setTableWatermarkView:(UIView *)tableWatermarkView animated:(BOOL)animated
{
    if (tableWatermarkView != _tableWatermarkView) {
        if (_tableWatermarkView) {
            if (animated) {
                [self fadeOutView:_tableWatermarkView];
            } else {
                [_tableWatermarkView removeFromSuperview];
            }
        }

        _tableWatermarkView = tableWatermarkView;

        if (_tableWatermarkView) {
            _tableWatermarkView.frame = [self rectForWatermarkView];
            [self addToWatermarkView:_tableWatermarkView];
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setDataSource:(id <RSTableViewDataSource> )dataSource
{
    if (dataSource != _dataSource) {
        _dataSource = dataSource;
        _tableView.dataSource = _dataSource;
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setLoadingView:(UIView *)view
{
    if (view != _loadingView) {
        if (_loadingView) {
            [_loadingView removeFromSuperview];
        }

        _loadingView = view;

        if (_loadingView) {
            [self addToOverlayView:_loadingView];
        } else {
            [self resetOverlayView];
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setErrorView:(UIView *)view
{
    if (view != _errorView) {
        if (_errorView) {
            [_errorView removeFromSuperview];
        }

        _errorView = view;

        if (_errorView) {
            [self addToOverlayView:_errorView];
        } else {
            [self resetOverlayView];
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setEmptyView:(UIView *)view
{
    if (view != _emptyView) {
        if (_emptyView) {
            [_emptyView removeFromSuperview];
        }

        _emptyView = view;

        if (_emptyView) {
            [self addToWatermarkView:_emptyView];
        } else {
            [self resetWatermarkView];
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath *)indexPath
{
    if ([object isKindOfClass:[RSTableViewLoadMoreItem class]] && !self.loadingData) {
        RSTableViewLoadMoreItem *moreItem = (RSTableViewLoadMoreItem *)object;
        moreItem.isLoading = YES;
        RSTableViewLoadMoreCell *cell = (RSTableViewLoadMoreCell *)[self.tableView cellForRowAtIndexPath:indexPath];

        if ([cell isKindOfClass:[RSTableViewLoadMoreCell class]]) {
            if (!moreItem.isNoMoreItem) {
                cell.animating = YES;
                [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
                [self loadMoreAction];
            } else {
                cell.animating = NO;
            }
        }
    }
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didBeginDragging
{
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didEndDragging
{
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGRect)rectForOverlayView
{
    CGRect frame = self.view.frame;

    UIWindow *window = [UIApplication sharedApplication].keyWindow;

    if ([window findFirstResponder]) {
        frame.size.height -= 216.0f;
    }

    return frame;
}

- (CGRect)rectForWatermarkView
{
    CGRect frame = self.view.frame;

    UIWindow *window = [UIApplication sharedApplication].keyWindow;

    if ([window findFirstResponder]) {
        frame.size.height -= 216.0f;
    }

    return frame;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)pullToRefreshAction
{
    [self showLoading:YES];
}

- (void)infiniteScrollingAction
{
    [self showLoading:YES];
}

- (void)loadMoreAction
{
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)stopRefreshAction
{
    [self.tableView.pullToRefreshView stopAnimating];
}

- (void)refreshTable
{
    if (![self isViewLoaded]) {
        return;
    }

    [self.tableView reloadData];

    [self showLoading:NO];
    [self showError:NO];
    [self showEmpty:[self.dataSource empty]];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)emptyViewButtonAction
{
}

- (void)dataSource:(RSTableViewDataSource *)ds item:(RSTableViewItem *)item ofSender:(id)sender withInfo:(NSDictionary *)info
{
    // 点击cell上的 button 的处理，子类去重写这个方法
}

///////////////////////////////////////////////////////////////////////////////////////////////////
@end

@implementation RSTableViewController (delegate)

#pragma mark - UIScrollViewDelegate
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self didBeginDragging];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self didEndDragging];
}

#pragma mark - UITableViewDelegate
///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id <RSTableViewDataSource> dataSource = (id <RSTableViewDataSource> )tableView.dataSource;

    id    object = [dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
    Class cls = [dataSource tableView:tableView cellClassForObject:object];

    return [cls tableView:tableView rowHeightForObject:object];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ([tableView.dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)]) {
        NSString *title = [tableView.dataSource tableView:tableView
                                  titleForHeaderInSection:section];

        if (!title.length) {
            return 0;
        }

        return 22.0;
    }

    return 0;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// 自定义sectionView在继承的controller中自己实现
// - (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    return nil;
// }

///////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * When the user taps a cell item, we check whether the tapped item has an attached URL and, if
 * it has one, we navigate to it. This also handles the logic for "Load more" buttons.
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id <RSTableViewDataSource> dataSource = (id <RSTableViewDataSource> )tableView.dataSource;
    id                         object = [dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
    [self didSelectObject:object atIndexPath:indexPath];
}

///////////////////////////////////////////////////////////////////////////////////////////////////

/**
 * Similar logic to the above. If the user taps an accessory item and there is an associated URL,
 * we navigate to that URL.
 */
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    id <RSTableViewDataSource> dataSource = (id <RSTableViewDataSource> )tableView.dataSource;
    id                         object = [dataSource tableView:tableView objectForRowAtIndexPath:indexPath];
    NSLog(@" object:%@", object);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (self.loadingData || self.forbidLoadMoreWhenScrolling) {
        return;
    }

    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat contentFoot = scrollView.contentSize.height - offsetY;
    CGFloat viewHeight = scrollView.frame.size.height;

    if (contentFoot <= viewHeight) {
        // 最后一项为加载更多
        int lastSectionIndex = 0;

        if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
            int sectionNumber = [self.dataSource numberOfSectionsInTableView:self.tableView];

            if (sectionNumber > 0) {
                lastSectionIndex = sectionNumber - 1;
            }
        }

        int lastRowIndex = 0;

        if ([self.dataSource tableView:self.tableView numberOfRowsInSection:lastSectionIndex] > 0) {
            lastRowIndex = [self.dataSource tableView:self.tableView numberOfRowsInSection:lastSectionIndex] - 1;
        }

        NSIndexPath *lastRowIndexPath = [NSIndexPath indexPathForRow:lastRowIndex inSection:lastSectionIndex];
        id          object = [self.dataSource tableView:self.tableView objectForRowAtIndexPath:lastRowIndexPath];

        if ([object isKindOfClass:[RSTableViewLoadMoreItem class]]) {
            [self didSelectObject:object atIndexPath:lastRowIndexPath];
        }
    }

    if (offsetY <= 40.0f) {
        // 第一项为加载更多
        NSIndexPath *lastRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        id          object = [self.dataSource tableView:self.tableView objectForRowAtIndexPath:lastRowIndexPath];

        if ([object isKindOfClass:[RSTableViewLoadMoreItem class]]) {
            [self didSelectObject:object atIndexPath:lastRowIndexPath];
        }
    }
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    if (self.loadingData || self.forbidLoadMoreWhenScrolling) {
        return;
    }

    // 第一项为加载更多
    NSIndexPath *lastRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    id          object = [self.dataSource tableView:self.tableView objectForRowAtIndexPath:lastRowIndexPath];

    if ([object isKindOfClass:[RSTableViewLoadMoreItem class]]) {
        [self didSelectObject:object atIndexPath:lastRowIndexPath];
    }
}

// skinchange
- (void)changeSkinStyle:(id)sender
{
    [super changeSkinStyle:sender];
}

@end