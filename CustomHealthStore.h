//
//  CustomHealthStore.h
//  HealthTest
//
//  Created by zhaojian on 14-11-10.
//  Copyright (c) 2014年 zhaojian. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HealthKit/HealthKit.h>

@interface CustomHealthStore : NSObject

// 初始化      CustomHealthStore* customHealthStore = [[CustomHealthStore alloc] initWithHealthStore];
- (instancetype)initWithHealthStore ;

// 请求授权  [customHealthStore requestAuthorizationWithCompletion:^(BOOL success, NSError *error) {
- (void)requestAuthorizationWithCompletion:(void(^)(BOOL success, NSError *error))completion;


// 保存
/**
 number:@"40"    千焦
 HKUnit:[HKUnit calorieUnit];
 type:HKQuantityTypeIdentifierActiveEnergyBurned
 /////////////////
 示例
 if ([HKHealthStore isHealthDataAvailable]) {
 CustomHealthStore* customHealthStore = [[CustomHealthStore alloc] initWithHealthStore];
 
 NSDictionary* dict = @{@"calories": @"80",@"HKUnit":[HKUnit calorieUnit],@"type":HKQuantityTypeIdentifierActiveEnergyBurned};
 [customHealthStore saveSample:dict completion:^(BOOL success, NSError *error) {
 if (success ==YES) {
 NSLog(@"保存成");
 }
 }];
 }
 */
- (void)saveSample:(NSDictionary*)paraDict completion:(void(^)(BOOL success, NSError *error))completion;


// 查询
/**
 type:HKQuantityTypeIdentifierActiveEnergyBurned
 predicate:nil
 limit:100   HKObjectQueryNoLimit（全部返回，其实就是穿0全部返回）
 descriptors:@[timeSortDescriptor]     NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc]              initWithKey:HKSampleSortIdentifierEndDate ascending:NO];// 时间排序 降序
 ////////////////
 示例
 NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];// 时间排序 降序
 NSDictionary* dict = @{@"type": HKQuantityTypeIdentifierActiveEnergyBurned,@"limit":@"0",@"descriptors":@[timeSortDescriptor]};
 [customHealthStore querySamples:dict completion:^(NSArray *samples, NSError *error) {
 NSLog(@"%@",samples);
 }];
 */
- (void)querySamples:(NSDictionary*)para  completion:(void(^)(NSArray *samples, NSError *error))completion;


/** 示例
 [customHealthStore querySamples:dict completion:^(NSArray *samples, NSError *error) {
 NSLog(@"%@",samples);
 HKQuantitySample *quantitySample = samples.lastObject;
 NSLog(@"%@",quantitySample);
 NSDictionary* dict = @{@"sample": quantitySample};
 [customHealthStore deleteSample:dict completion:^(BOOL success, NSError *error) {
 if (success ==YES) {
 NSLog(@"删除成功");
 }
 }];
 
 }];
 */
// 删除
-(void)deleteSample:(NSDictionary*)paraDict completion:(void(^)(BOOL success, NSError *error))completion;






/** // 锚点查询
 NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];// 时间排序 降序
 NSDictionary* dict = @{@"type": HKQuantityTypeIdentifierDistanceCycling,@"limit":@"0",@"descriptors":@[timeSortDescriptor],@"anchor":@"0"};
 [customHealthStore AnchoredObjectQuery:dict completion:^(NSArray *results, NSUInteger newAnchor, NSError *error) {
 NSLog(@"%@",results);
 }];
 */
-(void)AnchoredObjectQuery:(NSDictionary*)paraDict completion:(void(^)(  NSArray *results, NSUInteger newAnchor,NSError *error))completion;



/**  sourceQuery
NSDictionary* dict1 = @{@"type": HKQuantityTypeIdentifierDistanceCycling};
[customHealthStore sourceQuery:dict1 completion:^(HKSourceQuery *query, NSSet *sources, NSError *error) {
    NSLog(@"%@",sources);
}];
 */
-(void)sourceQuery:(NSDictionary*)paraDict completion:(void(^)(HKSourceQuery *query, NSSet *sources, NSError *error))completion;


@end
