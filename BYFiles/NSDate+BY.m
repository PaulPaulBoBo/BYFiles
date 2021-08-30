//
//  NSDate+BY.m
//  BYCategory
//
//  Created by Liu on 2021/8/27.
//

#import "NSDate+BY.h"

#define BY_MINUTE 60
#define BY_HOUR   3600
#define BY_DAY    86400
#define BY_WEEK   604800
#define BY_YEAR   31556926

@implementation NSDate (BY)

#pragma mark - Public

/// 类方法

// 返回值为NSDate

+(NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second {
    if(year <= 0) {
        year = 0;
    }
    if(month <= 0) {
        month = 0;
    }
    if(day <= 0) {
        day = 0;
    }
    if(hour <= 0) {
        hour = 0;
    }
    if(minute <= 0) {
        minute = 0;
    }
    if(second <= 0) {
        second = 0;
    }
    if(year == 0 && month == 0 && day == 0 && hour == 0 && minute == 0 && second == 0) {
        return [NSDate dateFromString:@"0000-00-00T00:00:00.000Z" type:(BY_DateFormatterType_utc) zone:BY_UTC_TIMEZONE];
    }
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    [dateComps setCalendar:BY_CURRENT_CALENDAR];
    [dateComps setTimeZone:BY_SYSTEM_TIMEZONE];
    [dateComps setYear:year];
    [dateComps setMonth:month];
    [dateComps setDay:day];
    [dateComps setHour:hour];
    [dateComps setMinute:minute];
    [dateComps setSecond:second];
    return [dateComps date];
}

+(NSDate *)dateWithHour:(NSInteger)hour minute:(NSInteger)minute {
    if(hour <= 0) {
        hour = 0;
    }
    if(minute <= 0) {
        minute = 0;
    }
    if(hour == 0 && minute == 0) {
        return [NSDate dateFromString:@"00:00" type:(BY_DateFormatterType_hm)];
    }
    NSDate *now = [NSDate date];
    NSDateComponents *components = [BY_CURRENT_CALENDAR components:BY_DATE_COMPONENTS fromDate:now];
    [components setHour:hour];
    [components setMinute:minute];
    NSDate *newDate = [BY_CURRENT_CALENDAR dateFromComponents:components];
    return newDate;
}

+(NSDate *)dateTomorrow {
    return [NSDate dateWithDaysFromNow:1];
}

+(NSDate *)dateYesterday {
    return [NSDate dateWithDaysBeforeNow:1];
}

+(NSDate *)dateWithDaysFromNow:(NSInteger)days {
    return [NSDate dateAfterDays:[NSDate date] days:days];
}

+(NSDate *)dateWithDaysBeforeNow:(NSInteger)days {
    return [NSDate dateBeforeDays:[NSDate date] days:days];
}

+(NSDate *)dateAfterDays:(NSDate *)curDate days:(NSInteger)days {
    return [curDate dateByAddingDays:days];
}

+(NSDate *)dateBeforeDays:(NSDate *)curDate days:(NSInteger)days {
    return [curDate dateByAddingDays:(days * -1)];
}

+(NSDate *)dateWithHoursFromNow:(NSInteger)dHours {
    NSTimeInterval aTimeInterval = BY_REFERENCE_DATEINTERVAL + BY_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+(NSDate *)dateWithHoursBeforeNow:(NSInteger)dHours {
    NSTimeInterval aTimeInterval = BY_REFERENCE_DATEINTERVAL - BY_HOUR * dHours;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+(NSDate *)dateWithMinutesFromNow:(NSInteger)dMinutes {
    NSTimeInterval aTimeInterval = BY_REFERENCE_DATEINTERVAL + BY_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+(NSDate *)dateWithMinutesBeforeNow:(NSInteger)dMinutes {
    NSTimeInterval aTimeInterval = BY_REFERENCE_DATEINTERVAL - BY_MINUTE * dMinutes;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

+(NSDate *)dateFromString:(NSString *)string type:(BY_DateFormatterType)type {
    return [self dateFromString:string type:type zone:BY_SYSTEM_TIMEZONE];
}

+(NSDate *)dateFromString:(NSString *)string type:(BY_DateFormatterType)type zone:(NSTimeZone *)zone {
    NSDateFormatter *inputFormatter = [NSDate loadDateFormater:type zone:zone];
    return [inputFormatter dateFromString:string];
}


// 返回值为NSString

+(NSString *)stringWithDate:(NSDate *)date type:(BY_DateFormatterType)type {
    return [NSDate stringWithDate:date type:type zone:BY_SYSTEM_TIMEZONE];
}

+(NSString *)stringWithDate:(NSDate *)date type:(BY_DateFormatterType)type zone:(NSTimeZone *)zone {
    return [NSDate stringWithDate:date type:type zone:zone local:BY_SYSTEM_LOCALE];
}

+(NSString *)stringWithDate:(NSDate *)date type:(BY_DateFormatterType)type zone:(NSTimeZone *)zone local:(NSLocale *)local {
    if (date == nil) {
        return @"";
    }
    NSDateFormatter *formatter = [NSDate loadDateFormater:type zone:zone local:local];
    return [formatter stringFromDate:date];
}

+(NSString *)stringWithDate:(NSDate *)date formatStr:(NSString *)formatStr {
    return [NSDate stringWithDate:date formatStr:formatStr zone:BY_SYSTEM_TIMEZONE];
}

+(NSString *)stringWithDate:(NSDate *)date formatStr:(NSString *)formatStr zone:(NSTimeZone *)zone {
    return [NSDate stringWithDate:date formatStr:formatStr zone:zone local:BY_SYSTEM_LOCALE];
}

+(NSString *)stringWithDate:(NSDate *)date formatStr:(NSString *)formatStr zone:(NSTimeZone *)zone local:(NSLocale *)local {
    if (date == nil) {
        return @"";
    }
    NSDateFormatter *formatter = [NSDate loadDateFormaterWithFormatStr:formatStr zone:zone local:local];
    return [formatter stringFromDate:date];
}

+(NSString *)createYearMonthDayZeroDate:(NSDate*)date {
    NSString *ymd_DateStr = [NSDate stringWithDate:date type:(BY_DateFormatterType_ymd)];
    NSDateFormatter *dateFormat = [NSDate loadDateFormater:(BY_DateFormatterType_ymdhms)];
    NSDate *zeroTimeDate = [dateFormat dateFromString:[NSString stringWithFormat:@"%@ 00:00:00", ymd_DateStr]];
    return [NSDate stringWithDate:zeroTimeDate type:(BY_DateFormatterType_utc) zone:BY_UTC_TIMEZONE];
}

+(NSString *)compareCurrentTimeWithDate:(NSDate*)timeDate {
    if (timeDate == nil) {
        return @"";
    }
    
    NSString *result = @"";
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:timeDate];
    NSString *suffixStr = @"前";
    if(timeInterval < 0) {
        timeInterval = fabs(timeInterval);
        suffixStr = @"后";
    }
    if(timeInterval < 1) {
        result = [NSString stringWithFormat:@"%@%@", @"1秒", suffixStr];
    } else if (timeInterval < 60) {
        result = [NSString stringWithFormat:@"%.0f%@%@", timeInterval, @"秒", suffixStr];
    } else if (timeInterval/60 < 60) {
        result = [NSString stringWithFormat:@"%.0f%@%@", timeInterval/60, @"分钟", suffixStr];
    } else if (timeInterval/3600 < 24) {
        result = [NSString stringWithFormat:@"%.0f%@%@", timeInterval/3600, @"小时", suffixStr];
    } else if (timeInterval/(3600*24) <= 30) {
        result = [NSString stringWithFormat:@"%.0f%@%@", timeInterval/(3600*24), @"天", suffixStr];
    } else {
        NSDateFormatter *formatter = [NSDate loadDateFormater:(BY_DateFormatterType_ymdhm)];
        result = [formatter stringFromDate:timeDate];
        if(result == nil) {
            result = @"";
        }
    }
    return  result;
}

+(NSString *)transToDayWithDate:(NSDate*)timeDate {
    if (timeDate == nil) {
        return @"";
    }
    NSDateFormatter *formatter = [NSDate loadDateFormater:(BY_DateFormatterType_ymdhm)];
    NSDateFormatter *formatterToday = [NSDate loadDateFormater:(BY_DateFormatterType_hm)];
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:timeDate];
    timeInterval = fabs(timeInterval);
    NSString *result = @"";
    if (timeInterval > 24*60*60) {
        result = [formatter stringFromDate:timeDate];
    } else {
        result = [formatterToday stringFromDate:timeDate];
    }
    return result;
}

+(NSString *)transToRangeDateString:(NSDate *)startTime endTime:(NSDate *)endTime {
    if(startTime == nil && endTime == nil) {
        return @"";
    } else {
        NSString *beginStr = @"";
        NSString *endStr = @"";
        NSString *shortEndStr = @"";
        NSInteger days = 0;
        if(startTime == nil) {
            days = 1; // 只有endTime不为nil时 将endtime以"yyyy-MM-dd HH:mm"展示
            endStr = [NSDate stringWithDate:endTime type:(BY_DateFormatterType_ymdhm)];
        } else if(endTime == nil) {
            beginStr = [NSDate stringWithDate:startTime type:(BY_DateFormatterType_ymdhm)];
        } else {
            beginStr = [NSDate stringWithDate:startTime type:(BY_DateFormatterType_ymdhm)];
            endStr = [NSDate stringWithDate:endTime type:(BY_DateFormatterType_ymdhm)];
            shortEndStr = [NSDate stringWithDate:endTime type:(BY_DateFormatterType_hm)];
            days = [NSDate daysOffsetBetweenStartDate:startTime endDate:endTime];
        }
        NSString *dateStr = @"";
        if (days >= 1) {
            if (beginStr.length > 0 && endStr.length > 0) {
                dateStr = [NSString stringWithFormat:@"%@ - %@",beginStr, endStr];
            } else if (beginStr.length == 0 && endStr.length > 0) {
                dateStr = [NSString stringWithFormat:@"%@", endStr];
            } else if (beginStr.length > 0 && endStr.length == 0) {
                dateStr = [NSString stringWithFormat:@"%@", beginStr];
            } else {
                dateStr = @"";
            }
        } else {
            if (beginStr.length > 0 && shortEndStr.length > 0) {
                dateStr = [NSString stringWithFormat:@"%@ - %@",beginStr, shortEndStr];
            } else if (beginStr.length == 0 && shortEndStr.length > 0) {
                dateStr = [NSString stringWithFormat:@"%@",shortEndStr];
            } else if (beginStr.length > 0 && shortEndStr.length == 0) {
                dateStr = [NSString stringWithFormat:@"%@",beginStr];
            } else {
                dateStr = @"";
            }
        }
        return dateStr;
    }
}

+(NSString *)transToRangeTimeString:(NSDate *)startTime endTime:(NSDate *)endTime {
    NSString *beginStr = [NSDate stringWithDate:startTime type:(BY_DateFormatterType_hm)];
    NSString *shortEndStr = [NSDate stringWithDate:endTime type:(BY_DateFormatterType_hm)];
    NSString *dateStr = @"";
    if (beginStr.length > 0 && shortEndStr.length > 0) {
        dateStr = [NSString stringWithFormat:@"%@ - %@",beginStr, shortEndStr];
    } else if (beginStr.length == 0 && shortEndStr.length > 0) {
        dateStr = [NSString stringWithFormat:@"%@",shortEndStr];
    } else if (beginStr.length > 0 && shortEndStr.length == 0) {
        dateStr = [NSString stringWithFormat:@"%@",beginStr];
    } else {
        dateStr = @"";
    }
    return dateStr;
}

+(NSString *)stringRelateTimeWithDate:(NSDate *)date hasPrefix:(BOOL)hasPrefix {
    if (date == nil) {
        return @"";
    } else {
        if ([self isTodayWithDate:date]) {
            if(hasPrefix) {
                return [NSDate timeHourMinuteWithPrefixDate:date];
            } else {
                return [NSDate timeHourMinuteDate:date];
            }
        } else if ([self isYesterdayCompareWithDate:date]) {
            return @"昨天";
        } else {
            return [self stringWithDate:date type:(BY_DateFormatterType_ymd)];
        }
    }
}

+(NSString *)loadCurrentStatusWithDate:(NSDate *)curDate {
    return [self loadCurrentStatusWithDate:curDate zone:BY_SYSTEM_TIMEZONE];
}

+(NSString *)loadCurrentStatusWithDate:(NSDate *)curDate zone:(NSTimeZone *)zone {
    if(curDate == nil) {
        return @"";
    }
    NSTimeInterval timeInterval = [curDate timeIntervalSince1970];
    NSTimeInterval timeIntervalNow = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval cha = timeInterval - timeIntervalNow;
    NSInteger chaDay = cha / 86400.0;
    NSString *str = nil;
    if (chaDay == 0) {
        str = @"今天";
    } else if (chaDay == 1) {
        str = @"明天";
    } else if (chaDay == -1) {
        str = @"昨天";
    }
    
    if (str) {
        NSString *timeStr = [NSDate timeHourMinuteWithPrefixDate:curDate zone:zone];
        return [NSString stringWithFormat:@"%@ %@", str, timeStr];
    } else {
        NSDateFormatter *format = [NSDate loadDateFormater:(BY_DateFormatterType_ymdhm) zone:zone];
        return [format stringFromDate:curDate];
    }
}

+(NSString *)transUTCDate:(NSDate *)date {
    NSDateFormatter *dateFormatter = [NSDate loadDateFormater:(BY_DateFormatterType_utc) zone:BY_UTC_TIMEZONE];
    return [dateFormatter stringFromDate:date];
}

+(NSString *)weekday:(NSDate *)date {
    return [self weekdayDate:date zone:BY_SYSTEM_TIMEZONE];
}

+(NSString *)weekdayDate:(NSDate *)date zone:(NSTimeZone *)zone {
    NSString *week = @"";
    NSDateComponents *comps =[BY_CURRENT_CALENDAR components:BY_DATE_COMPONENTS fromDate:date];
    NSInteger weekday = [comps weekday]; // 注意，周日是“1”，周一是“2”，以此类推
    switch (weekday) {
        case 1: week = @"星期日"; break;
        case 2: week = @"星期一"; break;
        case 3: week = @"星期二"; break;
        case 4: week = @"星期三"; break;
        case 5: week = @"星期四"; break;
        case 6: week = @"星期五"; break;
        case 7: week = @"星期六"; break;
        default: break;
    }
    return week;
}

+(NSString *)timeHourMinuteDate:(NSDate *)date {
    return [NSDate timeHourMinuteDate:date enablePrefix:NO enableSuffix:NO];
}

+(NSString *)timeHourMinuteDate:(NSDate *)date zone:(NSTimeZone *)zone {
    return [NSDate timeHourMinuteDate:date enablePrefix:NO enableSuffix:NO zone:zone];
}

+(NSString *)timeHourMinuteWithPrefixDate:(NSDate *)date {
    return [NSDate timeHourMinuteDate:date enablePrefix:YES enableSuffix:NO];
}

+(NSString *)timeHourMinuteWithPrefixDate:(NSDate *)date zone:(NSTimeZone *)zone{
    return [NSDate timeHourMinuteDate:date enablePrefix:YES enableSuffix:NO zone:zone];
}

+(NSString *)timeHourMinuteWithSuffixDate:(NSDate *)date {
    return [NSDate timeHourMinuteDate:date enablePrefix:NO enableSuffix:YES];
}

+(NSString *)timeHourMinuteWithSuffixDate:(NSDate *)date zone:(NSTimeZone *)zone{
    return [NSDate timeHourMinuteDate:date enablePrefix:NO enableSuffix:YES zone:zone];
}

+(NSString *)timeHourMinuteDate:(NSDate *)date enablePrefix:(BOOL)enablePrefix enableSuffix:(BOOL)enableSuffix {
    return [NSDate timeHourMinuteDate:date enablePrefix:enablePrefix enableSuffix:enableSuffix zone:BY_SYSTEM_TIMEZONE];
}

+(NSString *)timeHourMinuteDate:(NSDate *)date enablePrefix:(BOOL)enablePrefix enableSuffix:(BOOL)enableSuffix zone:(NSTimeZone *)zone {
    if(date == nil) {
        return @"";
    }
    NSString *timeStr = @"";
    if (enablePrefix) {
        timeStr = [NSDate stringWithDate:date type:(BY_DateFormatterType_tw_hm) zone:zone];
        timeStr = [NSString stringWithFormat:@"%@ %@",([date hour:zone] > 12 ? @"下午": @"上午"),timeStr];
    } else if (enableSuffix) {
        timeStr = [NSDate stringWithDate:date type:(BY_DateFormatterType_tw_hm) zone:zone];
        timeStr = [NSString stringWithFormat:@"%@ %@", timeStr, ([date hour:zone] > 12 ? @"pm" : @"am")];
    } else {
        timeStr = [NSDate stringWithDate:date type:(BY_DateFormatterType_hm) zone:zone];
    }
    return timeStr;
}


// 返回值为NSInteger

+(NSInteger)daysOffsetBetweenStartDate:(NSDate *)startDate endDate:(NSDate *)endDate {
    if(startDate == nil || endDate == nil) {
        return 0;
    }
    if([startDate timeIntervalSince1970] >= [endDate timeIntervalSince1970]) {
        return 0;
    }
    NSDateComponents *comps = [BY_CURRENT_CALENDAR components:NSCalendarUnitDay fromDate:startDate toDate:endDate options:0];
    [comps setTimeZone:BY_SYSTEM_TIMEZONE];
    return [comps day];
}

+(NSInteger)timestamp {
    return (NSInteger)([[NSDate date] timeIntervalSince1970] * 1000);
}



// 返回值为BOOL

+(BOOL)isEqualToDate:(NSDate *)date toDate:(NSDate *)toDate {
    if(date == nil || toDate == nil) {
        return NO;
    }
    NSDateComponents *components1 = [BY_CURRENT_CALENDAR components:BY_DATE_COMPONENTS fromDate:date];
    NSDateComponents *components2 = [BY_CURRENT_CALENDAR components:BY_DATE_COMPONENTS fromDate:toDate];
    return ((components1.year == components2.year)&&
            (components1.month == components2.month)&&
            (components1.day == components2.day));
}

/// 实例方法


// 返回值为NSInteger

-(NSInteger)year {
    return [self year:BY_SYSTEM_TIMEZONE];
}

-(NSInteger)year:(NSTimeZone *)zone {
    NSDateComponents *dateComponents = [BY_CURRENT_CALENDAR components:BY_DATE_COMPONENTS fromDate:self];
    [dateComponents setTimeZone:zone];
    return [dateComponents year];
}

-(NSInteger)month {
    return [self month:BY_SYSTEM_TIMEZONE];
}

-(NSInteger)month:(NSTimeZone *)zone {
    NSDateComponents *dateComponents = [BY_CURRENT_CALENDAR components:BY_DATE_COMPONENTS fromDate:self];
    [dateComponents setTimeZone:zone];
    return [dateComponents month];
}

-(NSInteger)day {
    return [self day:BY_SYSTEM_TIMEZONE];
}

-(NSInteger)day:(NSTimeZone *)zone {
    NSDateComponents *dateComponents = [BY_CURRENT_CALENDAR components:BY_DATE_COMPONENTS fromDate:self];
    [dateComponents setTimeZone:zone];
    return [dateComponents day];
}

-(NSInteger)hour {
    return [self hour:BY_SYSTEM_TIMEZONE];
}

-(NSInteger)hour:(NSTimeZone *)zone {
    return [[NSDate stringWithDate:self formatStr:@"HH" zone:zone] integerValue];
}

-(NSInteger)minute {
    return [self minute:BY_SYSTEM_TIMEZONE];
}

-(NSInteger)minute:(NSTimeZone *)zone {
    return [[NSDate stringWithDate:self formatStr:@"mm" zone:zone] integerValue];
}

-(NSInteger)second {
    return [self second:BY_SYSTEM_TIMEZONE];
}

-(NSInteger)second:(NSTimeZone *)zone {
    return [[NSDate stringWithDate:self formatStr:@"ss" zone:zone] integerValue];
}


#pragma mark - Private


// 返回值为NSDateFormatter

+(NSDateFormatter *)loadDateFormater:(BY_DateFormatterType)type {
    return [NSDate loadDateFormater:type zone:BY_SYSTEM_TIMEZONE];
}

+(NSDateFormatter *)loadDateFormater:(BY_DateFormatterType)type zone:(NSTimeZone *)zone {
    return [self loadDateFormater:type zone:zone local:BY_SYSTEM_LOCALE];
}

+(NSDateFormatter *)loadDateFormater:(BY_DateFormatterType)type zone:(NSTimeZone *)zone local:(NSLocale *)local {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = zone;
    formatter.locale = local;
    NSString *formatStr = @"";
    switch (type) {
        case BY_DateFormatterType_ym:
            formatStr = @"yyyy-MM";
            break;
        case BY_DateFormatterType_ym_cn:
            formatStr = @"yyyy年MM月";
            break;
        case BY_DateFormatterType_ymd:
            formatStr = @"yyyy-MM-dd";
            break;
        case BY_DateFormatterType_ymd_cn:
            formatStr = @"yyyy年MM月dd日";
            break;
        case BY_DateFormatterType_ymdhm:
            formatStr = @"yyyy-MM-dd HH:mm";
            break;
        case BY_DateFormatterType_ymdhm_cn:
            formatStr = @"yyyy年MM月dd日 HH时mm分";
            break;
        case BY_DateFormatterType_ymdhms:
            formatStr = @"yyyy-MM-dd HH:mm:ss";
            break;
        case BY_DateFormatterType_ymdhms_cn:
            formatStr = @"yyyy年MM月dd日 HH时mm分ss秒";
            break;
        case BY_DateFormatterType_md:
            formatStr = @"MM-dd";
            break;
        case BY_DateFormatterType_md_cn:
            formatStr = @"MM月dd日";
            break;
        case BY_DateFormatterType_mdhm:
            formatStr = @"MM-dd HH:mm";
            break;
        case BY_DateFormatterType_mdhm_cn:
            formatStr = @"MM月dd日 HH是mm分";
            break;
        case BY_DateFormatterType_mdhms:
            formatStr = @"MM-dd HH:mm:ss";
            break;
        case BY_DateFormatterType_mdhms_cn:
            formatStr = @"MM月dd日 HH是mm分ss秒";
            break;
        case BY_DateFormatterType_hm:
            formatStr = @"HH:mm";
            break;
        case BY_DateFormatterType_hm_cn:
            formatStr = @"HH时mm分";
            break;
        case BY_DateFormatterType_hms:
            formatStr = @"HH:mm:ss";
            break;
        case BY_DateFormatterType_hms_cn:
            formatStr = @"HH时mm分ss秒";
            break;
        case BY_DateFormatterType_tw_hm:
            formatStr = @"hh:mm";
            break;
        case BY_DateFormatterType_tw_hm_cn:
            formatStr = @"hh时mm分";
            break;
        case BY_DateFormatterType_tw_hms:
            formatStr = @"hh:mm:ss";
            break;
        case BY_DateFormatterType_tw_hms_cn:
            formatStr = @"hh时mm分ss秒";
            break;
        case BY_DateFormatterType_utc:
            formatStr = @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
            break;
    }
    [formatter setDateFormat:formatStr];
    return formatter;
}

+(NSDateFormatter *)loadDateFormaterWithFormatStr:(NSString *)formatStr {
    return [NSDate loadDateFormaterWithFormatStr:formatStr zone:BY_SYSTEM_TIMEZONE];
}

+(NSDateFormatter *)loadDateFormaterWithFormatStr:(NSString *)formatStr zone:(NSTimeZone *)zone {
    return [NSDate loadDateFormaterWithFormatStr:formatStr zone:BY_SYSTEM_TIMEZONE local:BY_SYSTEM_LOCALE];
}

+(NSDateFormatter *)loadDateFormaterWithFormatStr:(NSString *)formatStr zone:(NSTimeZone *)zone local:(NSLocale *)local {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeZone = zone;
    formatter.locale = local;
    [formatter setDateFormat:formatStr];
    return formatter;
}


// 返回值为NSDate

-(NSDate *)dateByAddingDays:(NSInteger)dDays {
    NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + BY_DAY * dDays;
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
    return newDate;
}

-(NSDate *)dateWithType:(BY_DateFormatterType)type {
    NSDateFormatter *fmt = [NSDate loadDateFormater:type];
    NSString *selfStr = [fmt stringFromDate:self];
    return [fmt dateFromString:selfStr];
}


// 返回值为BOOL

// 是否为今天
+(BOOL)isTodayWithDate:(NSDate *)compareDate {
    // 1.获得当前时间的年月日
    NSDateComponents *nowCmps = [BY_CURRENT_CALENDAR components:BY_DATE_COMPONENTS fromDate:[NSDate date]];
    // 2.获得self的年月日
    NSDateComponents *selfCmps = [BY_CURRENT_CALENDAR components:BY_DATE_COMPONENTS fromDate:compareDate];
    return (selfCmps.year == nowCmps.year)&& (selfCmps.month == nowCmps.month)&& (selfCmps.day == nowCmps.day);
}

// 是否为昨天
+(BOOL)isYesterdayCompareWithDate:(NSDate *)compareDate {
    NSDate *nowDate = [[NSDate date] dateWithType:(BY_DateFormatterType_ymd)];
    NSDate *selfDate = [compareDate dateWithType:(BY_DateFormatterType_ymd)];
    // 获得nowDate和selfDate的差距
    NSDateComponents *cmps = [BY_CURRENT_CALENDAR components:NSCalendarUnitDay fromDate:selfDate toDate:nowDate options:0];
    return cmps.day == 1;
}
@end
