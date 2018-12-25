//
//  TLSWorkingLogOverviewData.m
//  TakingLineService
//
//  Created by 杜宇 on 2017/8/16.
//  Copyright © 2017年 Huhedata. All rights reserved.
//

#import "TLSWorkingLogOverviewData.h"
#import <MJExtension.h>

@implementation TLSWorkingLogOverviewData

+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"ucWorkLogs":[TLSWorkingLogOverview class]};
}

@end
