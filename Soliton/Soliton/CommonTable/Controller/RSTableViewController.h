//
//  RSTableViewController.h
//  RenrenSixin
//
//  Created by zhongsheng on 12-5-28.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "RSTableViewDataSource.h"
#import "PKResManager.h"

@class RSTableViewDataSource;
@class RSSearchDisplayController;

@interface RSTableViewController : BaseViewController <UITableViewDelegate, RSTableDataSourceActionButtonDelegate> {
    UITableView *_tableView;
    UIView      *_tableWatermarkView;
    UIView      *_tableOverlayView;
    UIView      *_loadingView;
    UIView      *_errorView;
    UIView      *_emptyView;

    NSTimer *_bannerTimer;

    UITableViewStyle _tableViewStyle;

    UIInterfaceOrientation _lastInterfaceOrientation;

    BOOL _showTableShadows;

    RSTableViewDataSource *_dataSource;

    RSSearchDisplayController *_searchController;

    @private
    BOOL _shouldLoadTableView;
}

@property (nonatomic, strong) NSError               *error;
@property (nonatomic, assign) BOOL                  loadingData; // 默认是NO, 载入数据时为YES,主要防止load more多次使用
@property (nonatomic, assign) BOOL                  forbidLoadMoreWhenScrolling;
@property (nonatomic, strong) UITableView           *tableView;
@property (nonatomic, strong) RSTableViewController *searchViewController;

/**
 * A view that is displayed over the table view.
 */
@property (nonatomic, strong) UIView *tableOverlayView;
@property (nonatomic, strong) UIView *tableWatermarkView;

@property (nonatomic, strong) UIView *loadingView;
@property (nonatomic, strong) UIView *errorView;
@property (nonatomic, strong) UIView *emptyView;

/**
 * The data source used to populate the table view.
 *
 * Setting dataSource has the side effect of also setting model to the value of the
 * dataSource's model property.
 */
@property (nonatomic, strong) RSTableViewDataSource *dataSource;

/**
 * The style of the table view.
 */
@property (nonatomic) UITableViewStyle tableViewStyle;

/**
 * When enabled, draws gutter shadows above the first table item and below the last table item.
 *
 * Known issues: When there aren't enough cell items to fill the screen, the table view draws
 * empty cells for the remaining space. This causes the bottom shadow to appear out of place.
 */
@property (nonatomic) BOOL showTableShadows;

/**
 * Initializes and returns a controller having the given style.
 */
- (id)initWithStyle:(UITableViewStyle)style;

/**
 * Tells the controller that the user selected an object in the table.
 *
 * By default, the object's URLValue will be opened in TTNavigator, if it has one. If you don't
 * want this to be happen, be sure to override this method and be sure not to call super.
 */
- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath *)indexPath;

/**
 * Tells the controller that the user began dragging the table view.
 */
- (void)didBeginDragging;

/**
 * Tells the controller that the user stopped dragging the table view.
 */
- (void)didEndDragging;

/**
 * The rectangle where the overlay view should appear.
 */
- (CGRect)rectForOverlayView;

/**
 * 下拉刷新需要执行的方法
 */
- (void)pullToRefreshAction;

/**
 * 重置下拉刷新状态
 */
- (void)stopRefreshAction;

/**
 * 上拉刷新需要执行得方法
 */
- (void)infiniteScrollingAction;

- (void)refreshTable;

/**
 * emptyView 显示的时，点击button，需要执行的方法
 */
- (void)emptyViewButtonAction;

/**
 * 状态显示
 */

- (void)showEmpty:(BOOL)show;
- (void)showLoading:(BOOL)show;
- (void)showError:(BOOL)show;

/**
 * 搜索
 */

- (void)search:(NSString *)kw;
- (void)cancelSearch;
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar;

/**
 * 释放tableview中没有显示出来但复用了的内存
 */
- (void)releaseReuseTableviewCells:(UITableView *)tableview;

@end