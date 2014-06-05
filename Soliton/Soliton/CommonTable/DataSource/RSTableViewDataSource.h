//
//  RSCTableViewDataSource.h
//  RenrenSixin
//
//  Created by zhongsheng on 12-5-28.
//  Copyright (c) 2012年 renren. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RSTableViewItem.h"

@class RSTableViewDataSource;
@protocol RSTableDataSourceActionButtonDelegate <NSObject>

- (void)dataSource:(RSTableViewDataSource*)ds item:(RSTableViewItem*)item ofSender:(id)sender withInfo:(NSDictionary*)info;

@end

@protocol RSTableViewDataSource <UITableViewDataSource, UISearchDisplayDelegate,RSTableViewItemActionButtonDelegate>

+ (NSArray *)lettersForSectionsWithSearch:(BOOL)search summary:(BOOL)summary;

- (id)tableView:(UITableView *)tableView objectForRowAtIndexPath:(NSIndexPath *)indexPath;

- (Class)tableView:(UITableView *)tableView cellClassForObject:(id)object;

- (NSString *)tableView:(UITableView *)tableView labelForObject:(id)object;

- (NSIndexPath *)tableView:(UITableView *)tableView indexPathForObject:(id)object;

- (void)tableView:(UITableView *)tableView cell:(UITableViewCell *)cell willAppearAtIndexPath:(NSIndexPath *)indexPath;

- (NSString *)titleForLoading:(BOOL)reloading;

- (UIImage*)imageForEmpty;

- (UIImage*)titleImageForEmpty;

- (NSString*)titleForEmpty;

- (NSString*)subtitleForEmpty;

- (UIImage*)imageForError:(NSError*)error;

- (NSString*)titleForError:(NSError*)error;

- (NSString*)subtitleForError:(NSError*)error;

- (BOOL)empty;

- (BOOL)buttonExecutable;

- (UIEdgeInsets)emptyViewEdgeInsets;

@optional

- (NSIndexPath *)tableView:(UITableView *)tableView willUpdateObject:(id)object atIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)tableView:(UITableView *)tableView willInsertObject:(id)object atIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)tableView:(UITableView *)tableView willRemoveObject:(id)object atIndexPath:(NSIndexPath *)indexPath;

- (void)search:(NSString *)text;

@end

typedef void (^loadDataCompleteBlock)(BOOL result, NSError *err);

@interface RSTableViewDataSource : NSObject <RSTableViewDataSource>{
    
}

@property (nonatomic, weak) id<RSTableDataSourceActionButtonDelegate> actionButtonDelegate;

@end
