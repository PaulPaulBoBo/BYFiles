//
//  NSData+BY.m
//  BYCategory
//
//  Created by Liu on 2021/8/27.
//

#import "NSData+BY.h"

@implementation NSData (BY)

+(NSData *)dataWithString:(NSString *)string {
    NSData *data =[string dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

+(NSData *)dataWithArray:(NSArray *)array {
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:array];
    return data;
}

+(NSData *)dataWithDic:(NSDictionary *)dic {
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    return data;
}

-(NSString *)dataToString {
    NSString *string = [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
    return string;
}

-(NSArray *)dataToArray {
    NSArray *array = [NSKeyedUnarchiver unarchiveObjectWithData:self];
    return array;
}

-(NSDictionary *)dataToDic {
    NSString *string = [[NSString alloc]initWithData:self encoding:NSUTF8StringEncoding];
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
    return dic;
}

@end
