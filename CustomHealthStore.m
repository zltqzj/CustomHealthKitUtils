//
//  CustomHealthStore.m
//  HealthTest
//
//  Created by zhaojian on 14-11-10.
//  Copyright (c) 2014年 zhaojian. All rights reserved.
//

#import "CustomHealthStore.h"
@interface CustomHealthStore()

@property (strong, nonatomic) HKHealthStore *healthStore;

@end

@implementation CustomHealthStore


// 初始化
- (instancetype)initWithHealthStore  {
    self = [super init];
    if (self) {
        self.healthStore = [[HKHealthStore alloc] init];
      
    }
    return self;
}


// 测试
-(void)sourceQuery:(NSDictionary*)paraDict completion:(void(^)(HKSourceQuery *query, NSSet *sources, NSError *error))completion{
    HKSampleType* type =[HKSampleType quantityTypeForIdentifier: paraDict[@"type"]];
    NSPredicate* predicate =  paraDict[@"predicate"];
    HKSourceQuery* query = [[HKSourceQuery alloc] initWithSampleType:type samplePredicate:predicate completionHandler:^(HKSourceQuery *query, NSSet *sources, NSError *error) {
        completion(query,sources,error);
    }];
    [self.healthStore executeQuery:query];
}

/** 锚点查询
 示例：
 NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc] initWithKey:HKSampleSortIdentifierEndDate ascending:NO];// 时间排序 降序
 NSDictionary* dict = @{@"type": HKQuantityTypeIdentifierDistanceCycling,@"limit":@"0",@"descriptors":@[timeSortDescriptor],@"anchor":@"0"};
 [customHealthStore AnchoredObjectQuery:dict completion:^(NSArray *results, NSUInteger newAnchor, NSError *error) {
 NSLog(@"%@",results);
 }];
 */
-(void)AnchoredObjectQuery:(NSDictionary*)paraDict completion:(void(^)( NSArray *results, NSUInteger newAnchor,NSError *error))completion{
    HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:paraDict[@"type"]];
    NSPredicate* predicate =  paraDict[@"predicate"];
    NSInteger anchor =[paraDict[@"anchor"] integerValue]; //HKAnchoredObjectQueryNoAnchor;
    NSInteger limit = [paraDict[@"limit"] integerValue];
    HKAnchoredObjectQuery* query = [[HKAnchoredObjectQuery alloc] initWithType:type predicate:predicate anchor:anchor limit:limit completionHandler:^(HKAnchoredObjectQuery *query, NSArray *results, NSUInteger newAnchor, NSError *error) {
        completion(results,newAnchor,error);
    }];
    [self.healthStore executeQuery:query];
}

// 查询
/**
 type:HKQuantityTypeIdentifierActiveEnergyBurned
 predicate:nil
 limit:100   HKObjectQueryNoLimit（全部返回）
 descriptors:@[timeSortDescriptor]     NSSortDescriptor *timeSortDescriptor = [[NSSortDescriptor alloc]              initWithKey:HKSampleSortIdentifierEndDate ascending:NO];// 时间排序 降序
 */

- (void)querySamples:(NSDictionary*)para  completion:(void(^)(NSArray *samples, NSError *error))completion{
    
        HKQuantityType *type = [HKQuantityType quantityTypeForIdentifier:para[@"type"]];
        NSPredicate* predicate =  para[@"predicate"];
        NSInteger limit = [para[@"limit"] integerValue];
        NSArray* descriptors = para[@"descriptors"];
        HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:type
                                                               predicate:predicate
                                                                   limit:limit
                                                         sortDescriptors:descriptors
                                                          resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error) {
                                                              if (error) {
                                                                  NSLog(@"Error fetching samples from HealthKit: %@", error);
                                                              }
                                                              if (completion) {
                                                                  completion(results, error);
                                                              }
                                                          }];
        [self.healthStore executeQuery:query];
   
}

// 保存
/**
 number:@"40"    千焦
 HKUnit:[HKUnit calorieUnit];
 type:HKQuantityTypeIdentifierActiveEnergyBurned
 */
- (void)saveSample:(NSDictionary*)paraDict completion:(void(^)(BOOL success, NSError *error))completion{
   

    double cal = [paraDict[@"number"] doubleValue];
    HKUnit * calUnit = paraDict[@"HKUnit"];
    HKQuantity *calQuantity = [HKQuantity quantityWithUnit:calUnit doubleValue:cal];
    HKQuantityType *calType = [HKQuantityType quantityTypeForIdentifier:paraDict[@"type"]];
      NSDate *now = [NSDate date];
     HKQuantitySample *calSample = [HKQuantitySample quantitySampleWithType:calType quantity:calQuantity startDate:now endDate:now];
    [self.healthStore saveObject:calSample withCompletion:completion];
}


// 删除
-(void)deleteSample:(NSDictionary*)paraDict completion:(void(^)(BOOL success, NSError *error))completion{
    
    HKObject* sample = paraDict[@"sample"];
    [self.healthStore deleteObject:sample withCompletion:^(BOOL success, NSError *error) {
        completion(success,error);
    }];
     
}


// 请求授权
- (void)requestAuthorizationWithCompletion:(void(^)(BOOL success, NSError *error))completion {
    if ([HKHealthStore isHealthDataAvailable]) {
        
        [self.healthStore requestAuthorizationToShareTypes:[self dataTypesToWrite] readTypes:[self dataTypesToRead] completion:^(BOOL success, NSError *error) {
            if (error) {
                NSLog(@"Error requesting HealthKit permissions: %@", error);
            }
            if (completion) {
                completion(success, error);
            }
        }];
    } else if (completion) {
        completion(NO, nil);
    }
}

// Returns the types of data that Fit wishes to write to HealthKit.
- (NSSet *)dataTypesToWrite {
    HKQuantityType *activeEnergyBurnType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];  //活动时消耗的卡路里
    HKQuantityType *distanceWalkingRunningType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];// 步行+跑步距离
        HKQuantityType *distanceCyclingType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling];// 骑自行车距离
    return [NSSet setWithObjects:activeEnergyBurnType,distanceWalkingRunningType,distanceCyclingType,nil];
    
}

// Returns the types of data that Fit wishes to read from HealthKit.
- (NSSet *)dataTypesToRead {
    HKQuantityType *activeEnergyBurnType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];  //活动时消耗的卡路里
    HKQuantityType *distanceWalkingRunningType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceWalkingRunning];// 步行+跑步距离
    HKQuantityType *distanceCyclingType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDistanceCycling];// 骑自行车距离
    return [NSSet setWithObjects:activeEnergyBurnType,distanceWalkingRunningType,distanceCyclingType,nil];
}


@end
