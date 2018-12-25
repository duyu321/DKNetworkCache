//
//  TLSWorkingLogOverviewData.h
//  TakingLineService
//
//  Created by 杜宇 on 2017/8/16.
//  Copyright © 2017年 Huhedata. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLSWorkingLogOverview.h"

@interface TLSWorkingLogOverviewData : NSObject

@property (strong, nonatomic) NSArray<TLSWorkingLogOverview *> *ucWorkLogs;
@property (copy, nonatomic) NSString *count;

@end
