//
//  ViewController.m
//  TestNetworking
//
//  Created by 杜宇 on 2018/12/18.
//  Copyright © 2018 杜宇. All rights reserved.
//

#import "ViewController.h"
#import "DKNetworkingTool.h"
#import <SVProgressHUD.h>
#import "RequestModel.h"
#import <MJRefresh.h>
#import <MJExtension.h>
#import "TLSWorkingLogOverviewData.h"

@interface ViewController () <UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSMutableArray<TLSWorkingLogOverview *> *array;

@property (assign, nonatomic) NSInteger strat;

@end

@implementation ViewController

#define kLength 100

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [weakSelf.array removeAllObjects];
        weakSelf.strat = 0;
        [weakSelf loadDataIsCache:YES];
    }];
    
    self.tableView.mj_footer = [MJRefreshAutoFooter footerWithRefreshingBlock:^{
        weakSelf.strat += kLength;
        [weakSelf loadDataIsCache:NO];
    }];
    
    [self.tableView.mj_header beginRefreshing];
}

- (void)loadDataIsCache:(BOOL)isCache
{
    RequestModel *request = [[RequestModel alloc] init];
    request.session = @"LOGIN-CONNECT-21-1545637341543-btvORJc5oHUyCojJ";
    request.start = self.strat;
    request.count = kLength;
    [DKNetworkingTool postRequestURLStr:@"http://222.240.37.5:9998/s1-connect/connect?method=worklog/workLogListMy" parameters:request isCache:isCache success:^(NSDictionary * _Nonnull requestDic, NSString * _Nonnull msg) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        TLSWorkingLogOverviewData *data = [TLSWorkingLogOverviewData mj_objectWithKeyValues:requestDic];
        if (isCache) {
            self.array = data.ucWorkLogs.mutableCopy;
        } else {
            [self.array addObjectsFromArray:data.ucWorkLogs];
        }
        if (data.ucWorkLogs.count==0) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
        [self.tableView reloadData];
    } failure:^(NSString * _Nonnull errorInfo) {
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        NSLog(@"");
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    cell.textLabel.text = self.array[indexPath.row].content;
    cell.detailTextLabel.text = self.array[indexPath.row].userName;
    return cell;
}

- (NSString*)dictionaryToJson:(NSDictionary *)dic;
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (NSMutableArray<TLSWorkingLogOverview *> *)array
{
    if (!_array) {
        _array = [[NSMutableArray alloc] init];
    }
    return _array;
}

- (void)dealloc
{
    NSLog(@"成功释放");
}

@end
