//
//  KMLocationService.m
//  InstantCare
//
//  Created by Frank He on 9/27/16.
//  Copyright © 2016 omg. All rights reserved.
//

#import "KMLocationService.h"
#import "KMNetAPI.h"

@implementation KMLocationService


+ (instancetype)sharedInstance{
    static KMLocationService* instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)getValWithIMEI:(NSString *)imei
        successHandler:(void (^)(id data))success
        failureHandler:(void (^)(NSError *error))failure{
    
//    NSString *path = [NSString stringWithFormat:@"http://%@/kmhc-modem-restful/services/member/%@/%@/0/10?_type=json",kServerAddress, @"getCheckSummary", imei];
    NSString *path = [NSString stringWithFormat:@"http://%@/kmhc-modem-restful/services/member/%@/%@?_type=json",kServerAddress,@"getCheckSummary",imei];
    [[KMNetAPI sharedInstance] requestWithPath:path requestType:RequestTypeGet parameters:nil successHandler:success failureHandler:failure];
}

- (void)getCheckRecordsWithIMEI:(NSString *)imei
                 successHandler:(void (^)(id data))success
                 failureHandler:(void (^)(NSError *error))failure{
    NSString *path = [NSString stringWithFormat:@"http://%@/kmhc-modem-restful/services/member/%@/%@/0/10?_type=json",
                      kServerAddress, @"getCheckRecord", imei];
    [[KMNetAPI sharedInstance] requestWithPath:path requestType:RequestTypeGet parameters:nil successHandler:success failureHandler:failure];
}

- (void)getHisRecordsWithIMEI:(NSString *)imei
               successHandler:(void (^)(id data))success
               failureHandler:(void (^)(NSError *error))failure{
    NSString *path = [NSString stringWithFormat:@"http://%@/kmhc-modem-restful/services/member/%@/%@/0/10?_type=json",
                      kServerAddress, @"getRegular", imei];
    [[KMNetAPI sharedInstance] requestWithPath:path requestType:RequestTypeGet parameters:nil successHandler:success failureHandler:failure];
}

- (void)getEmgRecordsWithIMEI:(NSString *)imei
               successHandler:(void (^)(id data))success
               failureHandler:(void (^)(NSError *error))failure{
    NSString *path = [NSString stringWithFormat:@"http://%@/kmhc-modem-restful/services/member/%@/%@/0/10?_type=json",
                      kServerAddress, @"getEmg", imei];
    [[KMNetAPI sharedInstance] requestWithPath:path requestType:RequestTypeGet parameters:nil successHandler:success failureHandler:failure];
    
}

@end
