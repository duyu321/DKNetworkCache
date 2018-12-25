//
//  RequestModel.h
//  TestNetworking
//
//  Created by 杜宇 on 2018/12/18.
//  Copyright © 2018 杜宇. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RequestModel : NSObject

@property (copy, nonatomic) NSString *session;
@property (assign, nonatomic) NSInteger start;
@property (assign, nonatomic) NSInteger count;

@end

NS_ASSUME_NONNULL_END
