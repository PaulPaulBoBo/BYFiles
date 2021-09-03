//
//  NSDate+BY.h
//  BYCategory
//
//  Created by Liu on 2021/8/27.
//

#import <Foundation/Foundation.h>

#define BY_DATE_COMPONENTS (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfMonth | NSCalendarUnitWeekOfYear |  NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal)
#define BY_CURRENT_CALENDAR [NSCalendar currentCalendar]
#define BY_SYSTEM_LOCALE [NSLocale systemLocale]
#define BY_SYSTEM_TIMEZONE [NSTimeZone systemTimeZone] // 系统时区
#define BY_UTC_TIMEZONE [NSTimeZone timeZoneWithAbbreviation:@"UTC"] // UTC时区
#define BY_REFERENCE_DATEINTERVAL [[NSDate date] timeIntervalSinceReferenceDate]

typedef NS_ENUM(NSUInteger, BY_DateFormatterType) {
    BY_DateFormatterType_ym, // yyyy-MM
    BY_DateFormatterType_ym_cn, // yyyy年MM月
    BY_DateFormatterType_ymd, // yyyy-MM-dd
    BY_DateFormatterType_ymd_cn, // yyyy年MM月dd日
    BY_DateFormatterType_ymdhm, // yyyy-MM-dd HH:mm
    BY_DateFormatterType_ymdhm_cn, // yyyy年MM月dd日 HH时mm分
    BY_DateFormatterType_ymdhms, // yyyy-MM-dd HH:mm:ss
    BY_DateFormatterType_ymdhms_cn, // yyyy年MM月dd日 HH时mm分ss秒
    
    BY_DateFormatterType_md, // MM-dd
    BY_DateFormatterType_md_cn, // MM月dd日
    BY_DateFormatterType_mdhm, // MM-dd HH:mm
    BY_DateFormatterType_mdhm_cn, // MM月dd日 HH是mm分
    BY_DateFormatterType_mdhms, // MM-dd HH:mm:ss
    BY_DateFormatterType_mdhms_cn, // MM月dd日 HH是mm分ss秒
    
    BY_DateFormatterType_hm, // HH:mm
    BY_DateFormatterType_hm_cn, // HH时mm分
    BY_DateFormatterType_hms, // HH:mm:ss
    BY_DateFormatterType_hms_cn, // HH时mm分ss秒
    
    BY_DateFormatterType_tw_hm, // hh:mm
    BY_DateFormatterType_tw_hm_cn, // hh时mm分
    BY_DateFormatterType_tw_hms, // hh:mm:ss
    BY_DateFormatterType_tw_hms_cn, // hh时mm分ss秒
    
    BY_DateFormatterType_utc, // yyyy-MM-dd'T'HH:mm:ss.SSS'Z'
};

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (BY)

#pragma mark - 类方法

/// 根据年月日时分秒的NSInteger类型转换为NSDate
/// 该Date依据的日历NSCalendar根据当前系统设置的时区获取，不随用户“系统偏好设置”改变
/// 依据的时区为当前系统设置的时区
/// @param year 年
/// @param month 月
/// @param day 日
/// @param hour 时
/// @param minute 分
/// @param second 秒
+(NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second;

/// 根据时分的NSInteger类型转换为系统时间当天的NSDate
/// 该Date依据的日历NSCalendar根据当前系统设置的时区获取，不随用户“系统偏好设置”改变
/// @param hour 时
/// @param minute 分
+(NSDate *)dateWithHour:(NSInteger)hour minute:(NSInteger)minute;

/// 获取晚于当前时间一天的时间
+(NSDate *)dateTomorrow;

/// 获取早于当前时间一天的时间
+(NSDate *)dateYesterday;

/// 获取晚于当前时间days天的时间
/// @param days 天数
+(NSDate *)dateWithDaysFromNow:(NSInteger)days;

/// 获取早于当前时间days天的时间
/// @param days 天数
+(NSDate *)dateWithDaysBeforeNow:(NSInteger)days;

/// 获取curDate之后days天的时间
/// @param curDate 基准时间
/// @param days 天数
+(NSDate *)dateAfterDays:(NSDate *)curDate days:(NSInteger)days;

/// 获取curDate之前days天的时间
/// @param curDate 基准时间
/// @param days 天数
+(NSDate *)dateBeforeDays:(NSDate *)curDate days:(NSInteger)days;

/// 获取晚于当前时间dHours小时的时间
/// @param dHours 小时数
+(NSDate *)dateWithHoursFromNow:(NSInteger)dHours;

/// 获取早于当前时间dHours小时的时间
/// @param dHours 小时数
+(NSDate *)dateWithHoursBeforeNow:(NSInteger)dHours;

/// 获取晚于当前时间dMinutes分钟的时间
/// @param dMinutes 分钟数
+(NSDate *)dateWithMinutesFromNow:(NSInteger)dMinutes;

/// 获取早于当前时间dMinutes分钟的时间
/// @param dMinutes 分钟数
+(NSDate *)dateWithMinutesBeforeNow:(NSInteger)dMinutes;

/// 根据Date格式化类型type将时间字符串转为NSDate
/// @param string 时间字符串
/// @param type 格式化类型
/// @param zone 时区
+(NSDate *)dateFromString:(NSString *)string type:(BY_DateFormatterType)type zone:(NSTimeZone *)zone;




/// 根据date返回指定格式的时间字符串, 如果下面的枚举值不满足要求，请使用+stringWithDate:formatStr:方法
/// 默认为系统时区
/// @param date 日期
/// @param type 日期格式类型
+(NSString *)stringWithDate:(NSDate *)date type:(BY_DateFormatterType)type;

/// 根据date返回指定格式的时间字符串, 如果下面的枚举值不满足要求，请使用+stringWithDate:formatStr:方法
/// @param date 日期
/// @param type 日期格式类型
/// @param zone 时区
+(NSString *)stringWithDate:(NSDate *)date type:(BY_DateFormatterType)type zone:(NSTimeZone *)zone;

/// 根据date返回指定格式的时间字符串, 如果下面的枚举值不满足要求，请使用+stringWithDate:formatStr:方法
/// @param date 日期
/// @param type 日期格式类型
/// @param zone 时区
/// @param local 地区
+(NSString *)stringWithDate:(NSDate *)date type:(BY_DateFormatterType)type zone:(NSTimeZone *)zone local:(NSLocale *)local;

/// 根据date返回指定格式的时间字符串
/// 默认为系统时区
/// @param date 日期
/// @param formatStr 日期格式字符串
+(NSString *)stringWithDate:(NSDate *)date formatStr:(NSString *)formatStr;

/// 根据date返回指定格式的时间字符串
/// 默认为系统时区
/// @param date 日期
/// @param formatStr 日期格式字符串
/// @param zone 时区
+(NSString *)stringWithDate:(NSDate *)date formatStr:(NSString *)formatStr zone:(NSTimeZone *)zone;

/// 根据date返回指定格式的时间字符串
/// 默认为系统时区
/// @param date 日期
/// @param formatStr 日期格式字符串
/// @param zone 时区
/// @param local 地区
+(NSString *)stringWithDate:(NSDate *)date formatStr:(NSString *)formatStr zone:(NSTimeZone *)zone local:(NSLocale *)local;

/// 获取date在00:00:00时刻的UTC格式时间字符串 例如：2020-10-10T00:00:00.000Z
/// @param date 要转换的日期
+(NSString *)createYearMonthDayZeroDate:(NSDate*)date;

/// 根据timeDate计算与当前时间的时间差 timeDate如果晚于当前时间，返回值中的"前"变为"后"
/// 小于一秒返回"1秒前"；
/// 小于一分钟返回"n秒前"；
/// 大于等于一分钟，小于一小时返回"n分钟前";
/// 大于等于一小时，小于一天返回"n小时前";
/// 大于等于一天返回"n天前";
/// 大于一个月返回"yyyy-MM-dd HH:mm";
/// @param timeDate 要与当前时间比较的日期
+(NSString *)compareCurrentTimeWithDate:(NSDate*)timeDate;

/// 根据timeDate返回格式化的时间字符串
/// 超过一天返回"yyyy-MM-dd HH:mm"
/// 一天内返回"HH:mm"
/// 这里的一天是指timeDate和当前时间之间的时间差为24小时，不以24点为这一天结束
/// @param timeDate 要转化的日期
+(NSString *)transToDayWithDate:(NSDate*)timeDate;

/// 根据startTime和endTime返回以下格式的时间字符串
/// 1. 两个都不为nil时，跨天："yyyy-MM-dd HH:mm 至 yyyy-MM-dd HH:mm"，不跨天："yyyy-MM-dd HH:mm 至 HH:mm"
/// 2. startTime或endTime有一个nil时，返回"yyyy-MM-dd HH:mm"
/// 3. 都为nil，返回空字符串
/// @param startTime 开始时间
/// @param endTime 结束时间 必须晚于开始时间
+(NSString *)transToRangeDateString:(NSDate *)startTime endTime:(NSDate *)endTime;

/// 根据startTime和endTime返回以下格式的时间字符串
/// 不支持跨天的日期 跨天日期请使用transToRangeDateString:endTime:
/// 1. 两个都不为nil时，"HH:mm 至 HH:mm"
/// 2. startTime或endTime有一个nil时，返回"HH:mm"
/// 3. 都为nil，返回空字符串
/// @param startTime 开始时间
/// @param endTime 结束时间 必须晚于开始时间
+(NSString *)transToRangeTimeString:(NSDate *)startTime endTime:(NSDate *)endTime;

/// 根据日期返回特殊格式时间字符串
/// 1. 当天，hasPrefix为YES时返回"上/下午 hh:mm"， hasPrefix为NO时返回"HH:mm"
/// 2. 前一天返回"昨天"
/// 3. 剩余的情况均返回"yyyy-MM-dd"
/// @param date 日期
+(NSString *)stringRelateTimeWithDate:(NSDate *)date hasPrefix:(BOOL)hasPrefix;

/// 根据日期返回以下格式的时间字符串
/// 在昨/今/明天时返回"昨/今/明天 上/下午 hh:mm"
/// 不在昨/今/明天时返回"yyyy-MM-dd HH:mm"
/// @param curDate 日期
+(NSString *)loadCurrentStatusWithDate:(NSDate *)curDate;

/// 根据日期返回以下格式的时间字符串
/// 在昨/今/明天时返回"昨/今/明天 上/下午 hh:mm"
/// 不在昨/今/明天时返回"yyyy-MM-dd HH:mm"
/// @param curDate 日期
/// @param zone 时区
+(NSString *)loadCurrentStatusWithDate:(NSDate *)curDate zone:(NSTimeZone *)zone;

/// 根据date转化为UTC格式的时间字符串 时区为UTC
/// @param date 日期
+(NSString *)transUTCDate:(NSDate *)date;

/// 获取周
/// 默认依据系统时区
/// 格式化为字符串“星期一、星期二...星期日”
/// @param date 日期
+(NSString *)weekday:(NSDate *)date;

/// 获取指定时区周
/// @param date 日期
/// @param zone 时区
+(NSString *)weekdayDate:(NSDate *)date zone:(NSTimeZone *)zone;

/// 获取时分
/// 默认依据系统时区
/// 格式为"HH:mm" 24小时制
/// @param date 日期
+(NSString *)timeHourMinuteDate:(NSDate *)date;

/// 获取指定时区时分
/// 格式为"HH:mm" 24小时制
/// @param date 日期
/// @param zone 时区
+(NSString *)timeHourMinuteDate:(NSDate *)date zone:(NSTimeZone *)zone;

/// 获取带前缀的时分
/// 默认依据系统时区
/// 格式为"上/下午 HH:mm" 12小时制
/// @param date 日期
+(NSString *)timeHourMinuteWithPrefixDate:(NSDate *)date;

/// 获取指定时区带前缀的时分
/// 格式为"上/下午 HH:mm" 12小时制
/// @param date 日期
/// @param zone 时区
+(NSString *)timeHourMinuteWithPrefixDate:(NSDate *)date zone:(NSTimeZone *)zone;

/// 获取带后缀的时分
/// 格式为"HH:mm am/pm" 12小时制
/// 默认依据系统时区
/// @param date 日期
+(NSString *)timeHourMinuteWithSuffixDate:(NSDate *)date;

/// 获取指定时区带后缀的时分
/// 格式为"HH:mm am/pm" 12小时制
/// @param zone 时区
/// @param date 日期
+(NSString *)timeHourMinuteWithSuffixDate:(NSDate *)date zone:(NSTimeZone *)zone;

/// 获取带后缀或后缀的时分
/// 不能既有前缀又有后缀，可以都没有
/// 有前缀：格式为"上/下午 HH:mm" 12小时制；
/// 有后缀：格式为"HH:mm am/pm" 12小时制；
/// 都没有：格式为"HH:mm" 24小时制。
/// @param date 日期
/// @param enablePrefix 是否有前缀 YES-有 NO-没有
/// @param enableSuffix 是否有后缀 YES-有 NO-没有
+(NSString *)timeHourMinuteDate:(NSDate *)date enablePrefix:(BOOL)enablePrefix enableSuffix:(BOOL)enableSuffix;

/// 获取指定时区带后缀或后缀的时分
/// 不能既有前缀又有后缀，可以都没有
/// 有前缀：格式为"上/下午 HH:mm" 12小时制；
/// 有后缀：格式为"HH:mm am/pm" 12小时制；
/// 都没有：格式为"HH:mm" 24小时制。
/// @param date 日期
/// @param enablePrefix 是否有前缀 YES-有 NO-没有
/// @param enableSuffix 是否有后缀 YES-有 NO-没有
+(NSString *)timeHourMinuteDate:(NSDate *)date enablePrefix:(BOOL)enablePrefix enableSuffix:(BOOL)enableSuffix zone:(NSTimeZone *)zone;




/// 计算两个NSDate类型的日期之间相差几天
/// 该Date依据的日历NSCalendar根据当前系统设置的时区获取，不随用户“系统偏好设置”改变
/// @param startDate 起始日期（较早）
/// @param endDate 结束日期（晚于起始日期）
+(NSInteger)daysOffsetBetweenStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;

/// 获取当前时间的时间戳 单位为秒
+(NSInteger)timestamp;




/// 比较两个日期是否是同一天 即年月日是否相同 YES-相同 NO-不同
/// @param date 其中一个日期
/// @param toDate 另一个要比较的日期
+(BOOL)isEqualToDate:(NSDate *)date toDate:(NSDate *)toDate;



#pragma mark - 实例方法

/// 获取年份
-(NSInteger)year;

/// 获取指定时区年份
/// @param zone 时区
-(NSInteger)year:(NSTimeZone *)zone;

/// 获取月份
/// 默认依据系统时区
-(NSInteger)month;

/// 获取指定时区月份
/// @param zone 时区
-(NSInteger)month:(NSTimeZone *)zone;

/// 获取天
/// 默认依据系统时区
-(NSInteger)day;

/// 获取指定时区天
/// @param zone 时区
-(NSInteger)day:(NSTimeZone *)zone;

/// 获取小时
/// 默认依据系统时区
-(NSInteger)hour;

/// 获取指定时区小时
/// @param zone 时区
-(NSInteger)hour:(NSTimeZone *)zone;

/// 获取分钟
/// 默认依据系统时区
-(NSInteger)minute;

/// 获取指定时区分钟
/// @param zone 时区
-(NSInteger)minute:(NSTimeZone *)zone;

/// 获取秒
/// 默认依据系统时区
-(NSInteger)second;

/// 获取指定时区秒
/// @param zone 时区
-(NSInteger)second:(NSTimeZone *)zone;
@end

NS_ASSUME_NONNULL_END
